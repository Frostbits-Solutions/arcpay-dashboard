<template>
<div class="two-columns">
  <img :src="PROVIDER_ICONS[web3Store.account.providerId]">
  <div>from:</div>
  <div>{{web3Store.account.address}}</div>
  <div>price:</div>
  <input type="number" v-model="price"/>
  <button @click="update">Update</button>
  {{steps[currentStep]}}
</div>
</template>

<script setup lang="ts">
import { useWeb3Store } from '@/stores/web3'
import { PROVIDER_ICONS } from '@/lib/web3/constants'
import { longToByteArray } from '@/lib/web3/transactions/utils'
import { ref } from 'vue'
import type { Account } from '@/lib/web3/types'

const web3Store = useWeb3Store()

const props = defineProps<{
  account: Account,
}>()

const price = ref(1)
const currentStep = ref(0)
const steps = [
  'Input price',
  'Signing update',
  'Sending the transaction',
  'Done'
]

async function update() {
  if (web3Store.provider === null) {
    throw {message: 'no provider initiated'}
  }
  const parameters = {
    appIndex: 40424703,
    feesAddress: "UVGMQYP246NIXHWFSLBNPFVXJ77HSXNLU3AFP3JQEUVJSTGZIMGJ3JFFZY",
  }

  const algosdk = web3Store.provider.algosdk
  const algodClient = web3Store.provider.algodClient

  const suggestedParams = await algodClient.getTransactionParams().do()

  const appArgs = [
    new TextEncoder().encode('update_price'),
    longToByteArray(price.value)]
  const accounts = [parameters.feesAddress]

  const txn = algosdk.makeApplicationCallTxnFromObject({
    accounts: accounts,
    appArgs: appArgs,
    appIndex: parameters.appIndex,
    from: props.account.address,
    onComplete: algosdk.OnApplicationComplete.NoOpOC,
    suggestedParams
  })
  currentStep.value++

  const signedTxn = await web3Store.provider.signTransactions([txn], false)
  currentStep.value++

  const confirmationSendFund = await web3Store.provider.sendRawTransactions(signedTxn)
  currentStep.value++
  console.log(confirmationSendFund)
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
