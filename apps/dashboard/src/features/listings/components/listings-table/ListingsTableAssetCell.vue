<script setup lang="ts">
import type { Row } from '@tanstack/vue-table'
import type { CompositeListing } from '@repo/supabase/models'
import { ArrowUpRight } from 'lucide-vue-next'
import { useNetworksStore } from '@/features/networks/stores/networks'
import { computed } from 'vue'

const networks = useNetworksStore()
const props = defineProps<{ row: Row<CompositeListing> }>()
const listing = computed(() => props.row.original)
const link = computed(() => {
  const prefix = networks?.activeNetwork?.netid === 'testnet' ? 'testnet.' : ''
  return `https://${prefix}explorer.perawallet.app/asset/${listing.value.asset_id}/`
})
</script>

<template>
  <a
    :href="link"
    target="_blank"
    class="relative inline-flex items-center whitespace-nowrap rounded-md p-2 pr-8 font-normal text-muted-foreground transition-colors hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
  >
    <span class="max-w-48 truncate text-muted-foreground">{{ listing.name }}</span>
    <span class="text-xs text-muted-foreground opacity-50"
      >(<span class="uppercase">{{ listing.asset_type }}</span> {{ listing.asset_id }})</span
    >
    <ArrowUpRight class="absolute right-2 top-2 h-4 w-4 text-muted-foreground/20" />
  </a>
</template>

<style scoped></style>
