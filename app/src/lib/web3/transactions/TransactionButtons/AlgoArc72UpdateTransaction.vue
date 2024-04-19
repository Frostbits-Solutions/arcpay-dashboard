<template>
  <ChoosePrice v-model="price"/>
  <button @click="update">Update</button>
</template>

<script setup lang="ts">
import { useWeb3Store } from '@/stores/web3'
import { longToByteArray } from '@/lib/web3/transactions/utils'
import { ref } from 'vue'
import type { Account, UpdateTransactionParameters } from '@/lib/web3/types'
import { Transaction } from '@/lib/web3/transactions/transaction'
import _algosdk from 'algosdk'

const web3Store = useWeb3Store()

const props = defineProps<{
  account: Account,
  parameters: UpdateTransactionParameters
}>()
const emits = defineEmits(['start', 'nextStep', 'done', 'error'])
const price = ref(1)
async function update() {
  try {
    if (web3Store.provider === null) {
      throw { message: 'no provider initiated' }
    }

    emits('start')
    const algosdk = web3Store.provider.algosdk
    const algodClient = web3Store.provider.algodClient as _algosdk.Algodv2

    const suggestedParams = await algodClient.getTransactionParams().do()

    const appArgs = [
      new TextEncoder().encode('update_price'),
      longToByteArray(price.value)]
    const accounts = [props.parameters.feesAddress]

    const appCallObj = {
      appIndex: props.parameters.appIndex,
      from: props.account.address,
      onComplete: algosdk.OnApplicationComplete.NoOpOC,
      appArgs,
      accounts,
      suggestedParams
    }
    const txns = await new Transaction({appCalls: [appCallObj]}).createTxns(algosdk, algodClient)
    emits('nextStep')

    const signedTxn = await web3Store.provider.signTransactions(txns, false)
    emits('nextStep')

    const confirmationSendTxn = await web3Store.provider.sendRawTransactions(signedTxn)
    emits('done', confirmationSendTxn)
  } catch (e) {
    emits('error', e)
  }
}
</script>

<style scoped>
</style>
