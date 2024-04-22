<script setup lang="ts">
import { TransactionModal, TRANSACTION_TYPE, CONVENTION_TYPE  } from '@/lib/web3'
import { ref } from 'vue'

const transactionType = ref(TRANSACTION_TYPE.buy)

const parameters = {
  [TRANSACTION_TYPE.buy]: {
    seller: "UVGMQYP246NIXHWFSLBNPFVXJ77HSXNLU3AFP3JQEUVJSTGZIMGJ3JFFZY",
    appIndex: 40434788,
    nftAppID: 29105406,
    price: 2,
    feesAddress: "UVGMQYP246NIXHWFSLBNPFVXJ77HSXNLU3AFP3JQEUVJSTGZIMGJ3JFFZY",
    nftID: 606,
  },
  [TRANSACTION_TYPE.cancel]: {
    seller: "UVGMQYP246NIXHWFSLBNPFVXJ77HSXNLU3AFP3JQEUVJSTGZIMGJ3JFFZY",
    appIndex: 40432027,
    nftAppID: 29105406,
  },
  [TRANSACTION_TYPE.create]: {
    nftAppID: 29105406,
    nftID: 607,
    feesAddress: "UVGMQYP246NIXHWFSLBNPFVXJ77HSXNLU3AFP3JQEUVJSTGZIMGJ3JFFZY",
  },
  [TRANSACTION_TYPE.update]: {
    appIndex: 40434801,
    feesAddress: "UVGMQYP246NIXHWFSLBNPFVXJ77HSXNLU3AFP3JQEUVJSTGZIMGJ3JFFZY",
  }
}
</script>

<template>
  <main>
    <TransactionModal
      :transactionType="transactionType"
      :conventionType ="CONVENTION_TYPE.AlgoARC72"
      :parameters="parameters[transactionType]"
    />

    <p>Test contract:</p>
    <select v-model="transactionType">
      <option :value="TRANSACTION_TYPE.buy">buy</option>
      <option :value="TRANSACTION_TYPE.create">create</option>
      <option :value="TRANSACTION_TYPE.cancel">cancel</option>
      <option :value="TRANSACTION_TYPE.update">update</option>
    </select>
  </main>
</template>

<style scoped>
main {
  text-align: center;
}
</style>
