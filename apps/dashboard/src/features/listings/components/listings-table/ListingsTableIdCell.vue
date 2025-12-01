<script setup lang="ts">
import type { Row } from '@tanstack/vue-table'
import type { ListingDetail } from '@repo/supabase/models'
import { computed } from 'vue'
import { ArrowUpRight } from 'lucide-vue-next'
import { useNetworksStore } from '@/features/networks/stores/networks'
import { Button } from '@repo/ui/button'

const props = defineProps<{ row: Row<ListingDetail> }>()
const id = computed(() => props.row.original.id)
const networks = useNetworksStore()
</script>

<template>
  <Button variant="ghost" class="relative justify-start gap-1 pr-8" @click="console.log('Arcpay SDK - View Listing')">
    <span class="w-48 truncate">{{ id }}</span>
    <ArrowUpRight class="absolute right-2 top-2 h-4 w-4 text-muted-foreground/20" />
  </Button>
</template>

<style scoped></style>
