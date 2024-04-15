<script setup lang="ts">
import TransactionModal from '@/lib/web3/transactions/TransactionModal.vue'
import { TRANSACTION_TYPE, CONVENTION_TYPE } from '@/lib/web3/transactions/constants'
import { ref } from 'vue'

const transactionType = ref(TRANSACTION_TYPE.buy)
</script>

<template>
  <main>
    <TransactionModal :transactionType="transactionType"
                      :conventionType ="CONVENTION_TYPE.AlgoARC72"/>

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
