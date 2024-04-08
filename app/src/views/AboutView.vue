<template>
  <div class="about">
    <TransactionModal :contract="CONTRACT_ID.pay"/>
  </div>
</template>

<script lang="ts" setup>
import TransactionModal from '@/lib/web3/transactions/TransactionModal.vue'
import { CONTRACT_ID } from '@/lib/web3/transactions/constants'
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
