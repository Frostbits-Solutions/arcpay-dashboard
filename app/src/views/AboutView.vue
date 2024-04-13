<template>
  <div class="about">
    <TransactionModal :transactionType="TRANSACTION_TYPE.buy"
                      :conventionType ="CONVENTION_TYPE.AlgoARC72"/>
  </div>
</template>

<script lang="ts" setup>
import TransactionModal from '@/lib/web3/transactions/TransactionModal.vue'
import { TRANSACTION_TYPE, CONVENTION_TYPE } from '@/lib/web3/transactions/constants'
</script>

<style>
@media (min-width: 1024px) {
  .about {
    min-height: 100vh;
    display: flex;
    align-items: center;
  }
}
</style>
