<template>
  <button @click="cancel">Cancel</button>
</template>

<script setup lang="ts">
import { useWeb3Store } from '@/stores/web3'
import type { Account, CancelTransactionParameters } from '@/lib/web3/types'

const web3Store = useWeb3Store()
const props = defineProps<{
  account: Account,
  parameters: CancelTransactionParameters
}>()
const emits = defineEmits(['start', 'nextStep', 'done'])
async function cancel() {
  if (web3Store.provider === null) {
    throw {message: 'no provider initiated'}
  }
  emits('start')
  const algosdk = web3Store.provider.algosdk
  const algodClient = web3Store.provider.algodClient

  const suggestedParams = await algodClient.getTransactionParams().do()

  const accounts = [
    props.parameters.seller,
  ]
  const foreignApps = [props.parameters.appIndex, props.parameters.nftAppID]

  const appArgs = [new TextEncoder().encode('cancel')]
  const appCallTxn = algosdk.makeApplicationCallTxnFromObject({
    accounts: accounts,
    appArgs: appArgs,
    appIndex: props.parameters.appIndex,
    from: props.account.address,
    foreignApps: foreignApps,
    onComplete: algosdk.OnApplicationComplete.NoOpOC,
    suggestedParams: suggestedParams
  })

  const signedTxn = await web3Store.provider.signTransactions([appCallTxn], false)
  emits('nextStep')

  const confirmationSendTxn = await web3Store.provider.sendRawTransactions(signedTxn)
  emits('nextStep')
  emits('done', confirmationSendTxn)
}
</script>

<style scoped>
</style>
