<template>
  <BuyTransaction
    :account="account"
    v-if="transaction === TRANSACTION_TYPE.buy"
  />
  <CancelTransaction
    :account="account"
    v-else-if="transaction === TRANSACTION_TYPE.cancel"
  />
  <CreateSaleTransaction
    :account="account"
    v-else-if="transaction === TRANSACTION_TYPE.create"
  />
  <UpdateSaleTransaction
    :account="account"
    v-else-if="transaction === TRANSACTION_TYPE.update"
  />
</template>

<script setup lang="ts">
import BuyTransaction from '@/lib/web3/transactions/AlgoARC72/BuyTransaction.vue'
import CreateSaleTransaction from '@/lib/web3/transactions/AlgoARC72/CreateSaleTransaction.vue'
import UpdateSaleTransaction from '@/lib/web3/transactions/AlgoARC72/UpdateSaleTransaction.vue'
import CancelTransaction from '@/lib/web3/transactions/AlgoARC72/CancelTransaction.vue'
import { TRANSACTION_TYPE } from '@/lib/web3/transactions/constants'
import type { Account } from '@/lib/web3/types'

defineProps<{
  account: Account,
  transaction: TRANSACTION_TYPE
}>()

</script>

<style scoped>

</style>
