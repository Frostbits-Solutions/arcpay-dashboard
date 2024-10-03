<script setup lang="ts">
import type { Row } from '@tanstack/vue-table'
import type { CompositeListing } from '@/models'
import { computed } from 'vue'
import { Badge } from '@/components/ui/badge'

const props = defineProps<{row: Row<CompositeListing>}>()
const status = computed(() => props.row.original.status)
</script>

<template>
  <div class="w-24">
    <Badge v-if="['active'].includes(status)" class="bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-300">
      <span class="w-2 h-2 me-1 bg-purple-500 rounded-full"></span>
      {{ status }}
    </Badge>
    <Badge v-if="['closed'].includes(status)" class="bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300">
      <span class="w-2 h-2 me-1 bg-green-500 rounded-full"></span>
      {{ status }}
    </Badge>
    <Badge v-if="['cancelled'].includes(status)" class="bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300">
      <span class="w-2 h-2 me-1 bg-red-500 rounded-full"></span>
      {{ status }}
    </Badge>
    <Badge v-if="['pending'].includes(status)" class="bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-300">
      <span class="w-2 h-2 me-1 bg-gray-500 rounded-full"></span>
      {{ status }}
    </Badge>
  </div>
</template>

<style scoped>

</style>