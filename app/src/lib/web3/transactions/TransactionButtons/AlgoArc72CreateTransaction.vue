<template>
  <ChoosePrice v-model="price"/>
  <button @click="create">Create</button>
</template>

<script setup lang="ts">
import { useWeb3Store } from '@/stores/web3'
import {
  base64ToArrayBuffer, concatUint8Array,
  encodeAppArgs,
  longToByteArray,
  toHexString
} from '@/lib/web3/transactions/utils'
import { approvalProgram, clearProgram } from '@/lib/web3/transactions/contracts/algoArc72'
import { ref } from 'vue'
import type { Account, CreateTransactionParameters } from '@/lib/web3/types'
import { arc72Schema } from '@/lib/web3/transactions/abi/arc72'
import type { BoxReference } from 'algosdk'
import ChoosePrice from '@/lib/web3/transactions/component/ChoosePrice.vue'

const web3Store = useWeb3Store()
const props = defineProps<{
    account: Account,
    parameters: CreateTransactionParameters
  }>()
const emits = defineEmits(['start', 'nextStep', 'done'])
const price = ref(1)


async function create() {
  try {
    if (web3Store.provider === null) {
      throw { message: 'no provider initiated' }
    }
    emits('start')

    const algosdk = web3Store.provider.algosdk
    const algodClient = web3Store.provider.algodClient

    const suggestedParams = await algodClient.getTransactionParams().do()

    const appArgs = [
      algosdk.decodeAddress(props.account.address).publicKey,
      longToByteArray(props.parameters.nftAppID),
      longToByteArray(props.parameters.nftID),
      longToByteArray(price.value),
      algosdk.decodeAddress(props.parameters.feesAddress).publicKey]

    const txn = algosdk.makeApplicationCreateTxn(
      props.account.address,
      suggestedParams,
      algosdk.OnApplicationComplete.NoOpOC,
      base64ToArrayBuffer(approvalProgram),
      base64ToArrayBuffer(clearProgram),
      0, 0, 7, 7,
      appArgs
    )

    const signedTxn = await web3Store.provider.signTransactions([txn], false)
    console.log(signedTxn)

    emits('nextStep')

    const confirmation = await web3Store.provider.sendRawTransactions(signedTxn)
    emits('nextStep')
    // @ts-ignore
    console.log(confirmation, confirmation['application-index'])

    // @ts-ignore
    const appAddr = algosdk.getApplicationAddress(confirmation['application-index']
    )
    const suggestedParamsFund = await algodClient.getTransactionParams().do()
    const fundingAmount = 100_000 + 10_000

    const fundAppTxn = algosdk.makePaymentTxnWithSuggestedParams(
      props.account.address,
      appAddr,
      fundingAmount,
      undefined,
      undefined,
      suggestedParamsFund,
      undefined,
    )

    const abi = new algosdk.ABIContract(arc72Schema)
    const abiMethod = abi.getMethodByName('arc72_approve')
    const args = [appAddr, props.parameters.nftID]

    const appArgsFund = encodeAppArgs(abiMethod, args)

    const boxes: BoxReference[] = [
      {
        appIndex: 0,
        name: concatUint8Array(new Uint8Array([110]), appArgsFund[2])
      }
    ]

    console.log(boxes.map(x => toHexString(x.name)))

    const obj = {
      suggestedParams: suggestedParams,
      from: props.account.address,
      appIndex: props.parameters.nftAppID,
      appArgs: appArgsFund,
      foreignApps: [props.parameters.nftAppID],
      boxes: boxes,
    }

    const sendTokenTxn = algosdk.makeApplicationCallTxnFromObject({
      ...obj,
      // accounts: accounts,
      onComplete: algosdk.OnApplicationComplete.NoOpOC,
      suggestedParams
    })

    const signedFundAppTxn = await web3Store.provider.signTransactions([fundAppTxn, sendTokenTxn], true)

    emits('nextStep')

    const confirmationSendFund = await web3Store.provider.sendRawTransactions(signedFundAppTxn)
    emits('nextStep')
    emits('done', confirmationSendFund)
  } catch (e) {
    console.error(e)
  }
}
</script>

<style scoped>
</style>
