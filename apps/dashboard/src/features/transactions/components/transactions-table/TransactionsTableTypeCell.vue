<script setup lang="ts">
import type { Row } from '@tanstack/vue-table'
import type { Transaction } from '@repo/supabase/models'
import { computed } from 'vue'
import { Badge } from '@repo/ui/badge'

const props = defineProps<{ row: Row<Transaction> }>()
const type = computed(() => props.row.original.type)
</script>

<template>
  <div class="w-24">
    <Badge v-if="['create', 'fund'].includes(type)" class="bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-300">
      <span class="me-1 h-2 w-2 rounded-full bg-purple-500"></span>
      {{ type }}
    </Badge>
    <Badge v-if="['bid', 'buy', 'close'].includes(type)" class="bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300">
      <span class="me-1 h-2 w-2 rounded-full bg-green-500"></span>
      {{ type }}
    </Badge>
    <Badge v-if="['cancel'].includes(type)" class="bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300">
      <span class="me-1 h-2 w-2 rounded-full bg-red-500"></span>
      {{ type }}
    </Badge>
  </div>
</template>

<style scoped></style>
