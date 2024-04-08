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

const web3Store = useWeb3Store()
console.log(web3Store.wallet)
async function pay() {
  if (web3Store.provider === null) {
    throw {message: 'no provider initiated'}
  }
  await web3Store.provider.signTransactions([], false)
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
