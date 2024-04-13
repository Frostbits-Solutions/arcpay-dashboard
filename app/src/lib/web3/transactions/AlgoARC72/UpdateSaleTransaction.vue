<template>
<div class="two-columns">
  <img :src="PROVIDER_ICONS[web3Store.account.providerId]">
  <div>from:</div>
  <div>{{web3Store.account.address}}</div>
  <button @click="pay">Pay</button>
</div>
</template>

<script setup lang="ts">
import { useWeb3Store } from '@/stores/web3'
import { PROVIDER_ICONS } from '@/lib/web3/constants'
import { longToByteArray } from '@/lib/web3/transactions/utils'

const web3Store = useWeb3Store()
console.log(web3Store.wallet)
async function pay() {
  if (web3Store.provider === null) {
    throw {message: 'no provider initiated'}
  }

  const algosdk = web3Store.provider.algosdk
  const algodClient = web3Store.provider.algodClient

  const suggestedParams = await algodClient.getTransactionParams().do()

  const appArgs = [
    new TextEncoder().encode('update_price'),
    longToByteArray(props.price)]
  const accounts = [fees_address]

  const txn = algosdk.makeApplicationCallTxnFromObject({
    accounts: accounts,
    appArgs: appArgs,
    appIndex: appIndex,
    from: props.from,
    onComplete: algosdk.OnApplicationComplete.NoOpOC,
    suggestedParams
  })

  await web3Store.provider.signTransactions([txn], false)
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

.two-columns > *:nth-child(even) {
  text-align: right;
}
</style>
