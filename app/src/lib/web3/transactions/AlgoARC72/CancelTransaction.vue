<template>
<div class="two-columns">
  <img :src="PROVIDER_ICONS[web3Store.account.providerId]">
  <div>from:</div>
  <div>{{web3Store.account.address}}</div>
  <button @click="cancel">Cancel</button>
</div>
</template>

<script setup lang="ts">
import { useWeb3Store } from '@/stores/web3'
import { PROVIDER_ICONS } from '@/lib/web3/constants'
import { ref } from 'vue'
import type { Account } from '@/lib/web3/types'

const web3Store = useWeb3Store()
const props = defineProps<{
  account: Account,
}>()

const currentStep = ref(0)
const steps = [
  'Signing transaction',
  'Sending the transaction',
  'Done'
]
async function cancel() {
  if (web3Store.provider === null) {
    throw {message: 'no provider initiated'}
  }

  const algosdk = web3Store.provider.algosdk
  const algodClient = web3Store.provider.algodClient

  const suggestedParams = await algodClient.getTransactionParams().do()

  const parameters = {
    seller: "UVGMQYP246NIXHWFSLBNPFVXJ77HSXNLU3AFP3JQEUVJSTGZIMGJ3JFFZY",
    appIndex: 40424703,
    nftAppID: 29105406,
  }


  const accounts = [
    parameters.seller,
  ]
  const foreignApps = [parameters.appIndex, parameters.nftAppID]

  const appArgs = [new TextEncoder().encode('cancel')]
  const appCallTxn = algosdk.makeApplicationCallTxnFromObject({
    accounts: accounts,
    appArgs: appArgs,
    appIndex: parameters.appIndex,
    from: props.account.address,
    foreignApps: foreignApps,
    onComplete: algosdk.OnApplicationComplete.NoOpOC,
    suggestedParams: suggestedParams
  })

  const signedTxn = await web3Store.provider.signTransactions([appCallTxn], false)
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
