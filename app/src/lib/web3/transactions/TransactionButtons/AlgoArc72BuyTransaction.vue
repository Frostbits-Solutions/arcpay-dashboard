<template>
  <button @click="buy">buy</button>
</template>

<script setup lang="ts">
import { useWeb3Store } from '@/stores/web3'
import type { Account, BuyTransactionParameters } from '@/lib/web3/types'

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

  const accounts = [
    props.parameters.seller,
    props.parameters.feesAddress,
    props.account.address,
  ]
  const foreignApps = [props.parameters.appIndex, props.parameters.nftAppID]

  const payTxn = algosdk.makePaymentTxnWithSuggestedParams(
    props.account.address,
    props.parameters.seller,
    props.parameters.price,
    undefined, undefined,
    suggestedParams)

  const appArgs = [new TextEncoder().encode('buy')]
  const appCallTxn = algosdk.makeApplicationCallTxnFromObject({
    accounts: accounts,
    appArgs: appArgs,
    appIndex: props.parameters.appIndex,
    from: props.account.address,
    foreignApps: foreignApps,
    onComplete: algosdk.OnApplicationComplete.NoOpOC,
    suggestedParams: suggestedParams
  })

  const signedTxn = await web3Store.provider.signTransactions([payTxn, appCallTxn], true)
  emits('nextStep')

  const confirmationSendTxn = await web3Store.provider.sendRawTransactions(signedTxn)
  emits('nextStep')
  emits('done', confirmationSendTxn)
}
</script>

<style scoped>
</style>
