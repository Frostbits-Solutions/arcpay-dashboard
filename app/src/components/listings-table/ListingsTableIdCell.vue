<script setup lang="ts">
import type { Row } from '@tanstack/vue-table'
import type { CompositeListing } from '@/models'
import { computed } from 'vue'
import { ArrowUpRight } from 'lucide-vue-next'
import { useNetworksStore } from '@/stores/networks'
import { Button } from '@/components/ui/button'

const props = defineProps<{row: Row<CompositeListing>}>()
const id = computed(() => props.row.original.id)
const networks = useNetworksStore()
</script>

<template>
  <Button variant="ghost" class="justify-start relative gap-1 pr-8" @click="networks.activeClient?.buy(id)">
    <span class="w-48 truncate">{{ id }}</span>
    <ArrowUpRight class="w-4 h-4 text-muted-foreground/20 absolute top-2 right-2"/>
  </Button>
</template>

<style scoped>

</style>