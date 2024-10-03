<script setup lang="ts">
import type { Row } from '@tanstack/vue-table'
import type { CompositeListing } from '@/models'
import { ArrowUpRight } from 'lucide-vue-next'
import { useNetworksStore } from '@/stores/networks'
import { computed } from 'vue'

const networks = useNetworksStore()
const props = defineProps<{row: Row<CompositeListing>}>()
const listing = computed(() => props.row.original)
const link = computed(() => {
  const prefix = networks?.activeNetwork?.split(':')?.[1] === 'testnet' ? 'testnet.' : ''
  return `https://${prefix}explorer.perawallet.app/asset/${listing.value.asset_id}/`
})
</script>

<template>
  <a :href="link" target="_blank" class="relative whitespace-nowrap rounded-md transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring text-muted-foreground p-2 pr-8 inline-flex items-center font-normal hover:bg-accent hover:text-accent-foreground">
    <span class="text-muted-foreground max-w-48 truncate">{{ listing.name }}</span>
    <span class="text-xs text-muted-foreground opacity-50">(<span class="uppercase">{{ listing.asset_type }}</span> {{ listing.asset_id }})</span>
    <ArrowUpRight class="w-4 h-4 text-muted-foreground/20 absolute top-2 right-2"/>
  </a>
</template>

<style scoped>

</style>