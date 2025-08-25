<script setup lang="ts">
import type { Row } from '@tanstack/vue-table'
import type { Transaction } from '@/models'
import { computed } from 'vue'
import { useNetworksStore } from '@/features/networks/stores/networks'

const props = defineProps<{ row: Row<Transaction> }>()
const networks = useNetworksStore()
const currency = computed(() => {
  const id = props.row.original.currency || '0'
  return networks.activeNetwork?.currencies.find((currency) => currency.id === id)
})
const amount = computed(() => {
  if (currency.value && props.row.original.amount) return props.row.original.amount / 10 ** currency.value.decimals
  return 0
})
</script>

<template>
  <div :class="['font-bold text-muted-foreground', amount ? '' : 'opacity-40']">
    {{ amount }} <span class="text-xs uppercase">{{ currency?.ticker }}</span>
  </div>
</template>

<style scoped></style>
