<script setup lang="ts">
import type { Row } from '@tanstack/vue-table'
import type { Transaction } from '@/lib/supabase/models'
import { computed } from 'vue'
import { ArrowUpRight } from 'lucide-vue-next'
import { Button } from '@repo/ui/button'
import { useNetworksStore } from '@/features/networks/stores/networks'

const networks = useNetworksStore()
const props = defineProps<{ row: Row<Transaction> }>()
const listing = computed(() => props.row.original.listings)
</script>

<template>
  <Button variant="ghost" class="relative justify-start gap-1 pr-8" @click="console.log('ARCPAY SDK Buy')">
    <span class="max-w-48 truncate text-muted-foreground">{{ listing?.name }}</span>
    <span class="text-xs text-muted-foreground opacity-50">({{ listing?.app_id }})</span>
    <ArrowUpRight class="absolute right-2 top-2 h-4 w-4 text-muted-foreground/20" />
  </Button>
</template>

<style scoped></style>
