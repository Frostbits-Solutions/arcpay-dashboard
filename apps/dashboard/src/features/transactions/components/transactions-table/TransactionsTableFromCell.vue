<script setup lang="ts">
import type { Row } from '@tanstack/vue-table'
import type { Transaction } from '@/lib/supabase/models'
import { computed } from 'vue'
import { Jazzicon } from '@repo/ui/jazzicon'
import { ArrowUpRight } from 'lucide-vue-next'
import { useNetworksStore } from '@/features/networks/stores/networks'

const props = defineProps<{ row: Row<Transaction> }>()
const networks = useNetworksStore()
const from = computed(() => props.row.original.from_address)
const link = computed(() => {
  const prefix = networks?.activeNetwork?.netid === 'testnet' ? 'testnet.' : ''
  return `https://${prefix}explorer.perawallet.app/address/${from.value}/`
})
</script>

<template>
  <a
    :href="link"
    target="_blank"
    class="relative inline-flex items-center whitespace-nowrap rounded-md p-2 pr-8 font-normal text-muted-foreground transition-colors hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
  >
    <Jazzicon :diameter="20" :address="`0x${from}`" class="mr-2 mt-1" /> <span class="w-48 truncate">{{ from }}</span>
    <ArrowUpRight class="absolute right-2 top-2 h-4 w-4 text-muted-foreground/20" />
  </a>
</template>

<style scoped></style>
