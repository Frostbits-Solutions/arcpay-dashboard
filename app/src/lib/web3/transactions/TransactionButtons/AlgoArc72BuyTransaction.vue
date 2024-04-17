<template>
  <button @click="buy">buy</button>
</template>

<script setup lang="ts">
import type { Account, BuyTransactionParameters } from '@/lib/web3/types'
import type { BoxReference } from 'algosdk'
import { useWeb3Store } from '@/stores/web3'
import { concatUint8Array, encodeAppArgs, longToByteArray, toHexString } from '@/lib/web3/transactions/utils'
import { arc72Schema } from '@/lib/web3/transactions/abi/arc72'

const web3Store = useWeb3Store()
const props = defineProps<{
  account: Account,
  parameters: BuyTransactionParameters
}>()
const emits = defineEmits(['start', 'nextStep', 'done'])

async function buy() {
  if (web3Store.provider === null) {
    throw {message: 'no provider initiated'}
  }
  emits('start')
  const algosdk = web3Store.provider.algosdk
  const algodClient = web3Store.provider.algodClient

  const suggestedParams = await algodClient.getTransactionParams().do()

  const appAddress = algosdk.getApplicationAddress(props.parameters.appIndex)

  const accounts = [
    props.parameters.seller,
    props.parameters.feesAddress,
  ]
  const foreignApps = [props.parameters.nftAppID]

  const preValidateAppArgs = [new TextEncoder().encode('pre_validate')]
  const preValidateTxn = algosdk.makeApplicationCallTxnFromObject({
    accounts: accounts,
    appArgs: preValidateAppArgs,
    appIndex: props.parameters.appIndex,
    from: props.account.address,
    foreignApps: foreignApps,
    onComplete: algosdk.OnApplicationComplete.NoOpOC,
    suggestedParams: suggestedParams
  })

  const payTxn = algosdk.makePaymentTxnWithSuggestedParams(
    props.account.address,
    appAddress,
    props.parameters.price,
    undefined, undefined,
    suggestedParams)

  const appArgs = [new TextEncoder().encode('buy')]

  const abi = new algosdk.ABIContract(arc72Schema)
  const abiMethod = abi.getMethodByName('arc72_transferFrom')
  const encodedElements = encodeAppArgs(abiMethod, [props.account.address, appAddress, props.parameters.nftID])
  const boxes: BoxReference[] = [
    {
      appIndex: 0,
      name: concatUint8Array(new Uint8Array([110]), encodedElements[3])
    },
    {
      appIndex: 0,
      name: concatUint8Array(encodedElements[1],encodedElements[1])
    },
    {
      appIndex: 0,
      name: concatUint8Array(new Uint8Array([98]), encodedElements[1])
    },
    {
      appIndex: 0,
      name: concatUint8Array(new Uint8Array([98]), encodedElements[2])
    }
  ]
  console.log(boxes.map(x => toHexString(x.name)))
  const appCallTxn = algosdk.makeApplicationCallTxnFromObject({
    appArgs: appArgs,
    appIndex: props.parameters.appIndex,
    from: props.account.address,
    foreignApps: foreignApps,
    onComplete: algosdk.OnApplicationComplete.NoOpOC,
    suggestedParams: suggestedParams,
    boxes
  })

  const signedTxn = await web3Store.provider.signTransactions([preValidateTxn, payTxn, appCallTxn], true)
  emits('nextStep')

  const confirmationSendTxn = await web3Store.provider.sendRawTransactions(signedTxn)
  emits('nextStep')
  emits('done', confirmationSendTxn)
}
</script>

<style scoped>
</style>
