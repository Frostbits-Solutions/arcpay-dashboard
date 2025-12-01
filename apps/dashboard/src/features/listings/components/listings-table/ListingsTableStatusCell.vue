<script setup lang="ts">
import type { Row } from '@tanstack/vue-table'
import type { Listing } from '@repo/supabase/models'
import { computed } from 'vue'
import { Badge } from '@repo/ui/badge'

const props = defineProps<{ row: Row<Listing> }>()
const status = computed(() => props.row.original.status || 'pending')
</script>

<template>
  <div class="w-24">
    <Badge v-if="['active'].includes(status)" class="bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-300">
      <span class="me-1 h-2 w-2 rounded-full bg-purple-500"></span>
      {{ status }}
    </Badge>
    <Badge v-if="['closed'].includes(status)" class="bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300">
      <span class="me-1 h-2 w-2 rounded-full bg-green-500"></span>
      {{ status }}
    </Badge>
    <Badge v-if="['cancelled'].includes(status)" class="bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300">
      <span class="me-1 h-2 w-2 rounded-full bg-red-500"></span>
      {{ status }}
    </Badge>
    <Badge v-if="['pending'].includes(status)" class="bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-300">
      <span class="me-1 h-2 w-2 rounded-full bg-gray-500"></span>
      {{ status }}
    </Badge>
  </div>
</template>

<style scoped></style>
