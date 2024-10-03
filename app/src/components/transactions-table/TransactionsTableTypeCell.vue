<script setup lang="ts">
import type { Row } from '@tanstack/vue-table'
import type { TransactionWithListings } from '@/models'
import { computed } from 'vue'
import { Badge } from '@/components/ui/badge'

const props = defineProps<{row: Row<TransactionWithListings>}>()
const type = computed(() => props.row.original.type)
</script>

<template>
  <div class="w-24">
    <Badge v-if="['create', 'fund'].includes(type)" class="bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-300">
      <span class="w-2 h-2 me-1 bg-purple-500 rounded-full"></span>
      {{ type }}
    </Badge>
    <Badge v-if="['bid', 'buy', 'close'].includes(type)" class="bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300">
      <span class="w-2 h-2 me-1 bg-green-500 rounded-full"></span>
      {{ type }}
    </Badge>
    <Badge v-if="['cancel'].includes(type)" class="bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300">
      <span class="w-2 h-2 me-1 bg-red-500 rounded-full"></span>
      {{ type }}
    </Badge>
  </div>
</template>

<style scoped>

</style>