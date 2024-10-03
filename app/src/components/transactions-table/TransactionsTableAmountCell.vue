<script setup lang="ts">
import type { Row } from '@tanstack/vue-table'
import type { TransactionWithListings } from '@/models'
import { useCurrenciesStore } from '@/stores/currencies'
import { computed } from 'vue'

const props = defineProps<{row: Row<TransactionWithListings>}>()
const currencies = useCurrenciesStore()
const currency = computed(() => {
  const id = props.row.original.currency || '0'
  return currencies.list.find(currency => currency.id === id)
})
const amount = computed(() => {
  if (currency.value && props.row.original.amount) return props.row.original.amount / 10 ** currency.value.decimals
  return 0
})
</script>

<template>
  <div :class="['text-muted-foreground font-bold', amount?'':'opacity-40']">
    {{ amount }} <span class="text-xs uppercase">{{ currency?.ticker }}</span>
  </div>
</template>

<style scoped>

</style>