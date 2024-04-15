<template>
<div class="two-columns">
  <img :src="PROVIDER_ICONS[account.providerId]">
  <div>from:</div>
  <div>{{account.address}}</div>
  <div>price:</div>
  <input type="number" v-model="price"/>
  <button @click="create">Create</button>
  {{steps[currentStep]}}
</div>
</template>

<script setup lang="ts">
import { useWeb3Store } from '@/stores/web3'
import { PROVIDER_ICONS } from '@/lib/web3/constants'
import {
  base64ToArrayBuffer, concatUint8Array,
  encodeAppArgs,
  fromHexString,
  longToByteArray,
  toHexString
} from '@/lib/web3/transactions/utils'
import { approvalProgram, clearProgram } from '@/lib/web3/transactions/AlgoARC72/contracts'
import { ref } from 'vue'
import type { Account } from '@/lib/web3/types'
import { arc72Schema } from '@/lib/web3/transactions/AlgoARC72/abi'
import type { BoxReference } from 'algosdk'

const web3Store = useWeb3Store()
const props = defineProps<{
    account: Account,
  }>()

const price = ref(1)

const currentStep = ref(0)
const steps = [
  'Creation of the application',
  'Sending the transaction',
  'Funding the application',
  'Sending the funds',
  'Done'
]


async function create() {
  try {
    if (web3Store.provider === null) {
      throw { message: 'no provider initiated' }
    }

    const algosdk = web3Store.provider.algosdk
    const algodClient = web3Store.provider.algodClient

    const parameters = {
      nftAppID: 29105406,
      nftID: 584,
      feesAddress: "UVGMQYP246NIXHWFSLBNPFVXJ77HSXNLU3AFP3JQEUVJSTGZIMGJ3JFFZY",
      receiverAddress: "6J4RO7U2WYQWOGWXQOZUTBBA46W4QSFL5HTHJWC5BZR53RSYRAOPAY7KPM"
    }

    const suggestedParams = await algodClient.getTransactionParams().do()

    const appArgs = [
      algosdk.decodeAddress(props.account.address).publicKey,
      longToByteArray(parameters.nftAppID),
      longToByteArray(parameters.nftID),
      longToByteArray(price.value),
      algosdk.decodeAddress(parameters.feesAddress).publicKey]

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

    currentStep.value++

    const confirmation = await web3Store.provider.sendRawTransactions(signedTxn)
    currentStep.value++
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
    const args = [appAddr, parameters.nftID]

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
      appIndex: parameters.nftAppID,
      appArgs: appArgsFund,
      foreignApps: [parameters.nftAppID],
      boxes: boxes,
    }

    const sendTokenTxn = algosdk.makeApplicationCallTxnFromObject({
      ...obj,
      // accounts: accounts,
      onComplete: algosdk.OnApplicationComplete.NoOpOC,
      suggestedParams
    })

    const signedFundAppTxn = await web3Store.provider.signTransactions([fundAppTxn, sendTokenTxn], true)

    currentStep.value++

    const confirmationSendFund = await web3Store.provider.sendRawTransactions(signedFundAppTxn)
    currentStep.value++
    console.log(confirmationSendFund)
  } catch (e) {
    console.error(e)
  }
}
</script>

<style scoped>
img {
  border-radius: 50%;
  width: 50px;
  height: 50px;
  grid-column: span 2;
  margin: auto;
}

.two-columns {
  display: grid;
  grid-template-columns: auto auto;
  grid-gap: 10px;
}

.two-columns > div:nth-child(even) {
  text-align: right;
}

.two-columns button {
  grid-column: span 2;
  width: 100px;
  margin: auto;
}
</style>
