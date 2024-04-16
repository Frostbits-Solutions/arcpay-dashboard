<template>
  <ChoosePrice v-model="price"/>
  <button @click="update">Update</button>
</template>

<script setup lang="ts">
import { useWeb3Store } from '@/stores/web3'
import { longToByteArray } from '@/lib/web3/transactions/utils'
import { ref } from 'vue'
import type { Account, UpdateTransactionParameters } from '@/lib/web3/types'

const web3Store = useWeb3Store()

const props = defineProps<{
  account: Account,
  parameters: UpdateTransactionParameters
}>()
const emits = defineEmits(['start', 'nextStep', 'done'])
const price = ref(1)
async function update() {
  if (web3Store.provider === null) {
    throw {message: 'no provider initiated'}
  }

  emits('start')
  const algosdk = web3Store.provider.algosdk
  const algodClient = web3Store.provider.algodClient

  const suggestedParams = await algodClient.getTransactionParams().do()

  const appArgs = [
    new TextEncoder().encode('update_price'),
    longToByteArray(price.value)]
  const accounts = [props.parameters.feesAddress]

  const txn = algosdk.makeApplicationCallTxnFromObject({
    accounts: accounts,
    appArgs: appArgs,
    appIndex: props.parameters.appIndex,
    from: props.account.address,
    onComplete: algosdk.OnApplicationComplete.NoOpOC,
    suggestedParams
  })
  emits('nextStep')

  const signedTxn = await web3Store.provider.signTransactions([txn], false)
  emits('nextStep')

  const confirmationSendTxn = await web3Store.provider.sendRawTransactions(signedTxn)
  emits('nextStep')
  emits('done', confirmationSendTxn)
}
</script>

<style scoped>
</style>
