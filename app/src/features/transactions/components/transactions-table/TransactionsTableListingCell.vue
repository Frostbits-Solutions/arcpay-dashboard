<script setup lang="ts">
import type { Row } from '@tanstack/vue-table'
import type { Transaction } from '@/models'
import { computed } from 'vue'
import { ArrowUpRight } from 'lucide-vue-next'
import { Button } from '@/lib/ui/button'
import { useNetworksStore } from '@/features/network/stores/networks'

const networks = useNetworksStore()
const props = defineProps<{row: Row<Transaction>}>()
const listing = computed(() => props.row.original.listings)

</script>

<template>
  <Button variant="ghost" class="justify-start relative gap-1 pr-8" @click="console.log('ARCPAY DSK Buy')">
    <span class="text-muted-foreground max-w-48 truncate">{{ listing?.name }}</span>
    <span class="text-xs text-muted-foreground opacity-50">({{ listing?.app_id }})</span>
    <ArrowUpRight class="w-4 h-4 text-muted-foreground/20 absolute top-2 right-2"/>
  </Button>

</template>

<style scoped>

</style>