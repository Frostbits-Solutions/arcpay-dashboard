<template>
<div class="two-columns">
  <img :src="PROVIDER_ICONS[account.providerId]">
  <input type="number" v-model="price"/>
  <div>{{account.address}}</div>
  <button @click="pay">Pay</button>
</div>
</template>

<script setup lang="ts">
import { useWeb3Store } from '@/stores/web3'
import { PROVIDER_ICONS } from '@/lib/web3/constants'
import { base64ToArrayBuffer, longToByteArray } from '@/lib/web3/transactions/utils'
import { approvalProgram, clearProgram } from '@/lib/web3/transactions/AlgoARC72/contracts'
import { ref } from 'vue'
import type { Account } from '@/lib/web3/types'

const web3Store = useWeb3Store()
const props = defineProps<{
    account: Account,
  }>()

const price = ref(0)

async function pay() {
  if (web3Store.provider === null) {
    throw {message: 'no provider initiated'}
  }

  const algosdk = web3Store.provider.algosdk
  const algodClient = web3Store.provider.algodClient

  const parameters = {
    nftAppID: 37855788,
    nftID: 1,
    feesAddress: ""
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
    0,0,7,7,
    appArgs
  )

  const signedTxn = await web3Store.provider.signTransactions([txn], false)

  const confirmation = web3Store.provider.sendRawTransactions(signedTxn)
  console.log(confirmation)
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
