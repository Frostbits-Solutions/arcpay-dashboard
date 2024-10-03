<script setup lang="ts">
import type { Row } from '@tanstack/vue-table'
import type { CompositeListing } from '@/models'
import { computed } from 'vue'
import Jazzicon from '@/components/ui/jazzicon/Jazzicon.vue'
import { ArrowUpRight } from 'lucide-vue-next'
import { useNetworksStore } from '@/stores/networks'

const props = defineProps<{row: Row<CompositeListing>}>()
const networks = useNetworksStore()
const address = computed(() => props.row.original.seller_address)
const link = computed(() => {
  const prefix = networks?.activeNetwork?.split(':')?.[1] === 'testnet' ? 'testnet.' : ''
  return `https://${prefix}explorer.perawallet.app/address/${address.value}/`
})
</script>

<template>
  <a :href="link" target="_blank" class="relative whitespace-nowrap rounded-md transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring text-muted-foreground p-2 pr-8 inline-flex items-center font-normal hover:bg-accent hover:text-accent-foreground">
    <Jazzicon :diameter="20" :address="`0x${address}`" class="mr-2 mt-1"/> <span class="w-48 truncate">{{ address }}</span>
    <ArrowUpRight class="w-4 h-4 text-muted-foreground/20 absolute top-2 right-2"/>
  </a>
</template>

<style scoped>

</style>