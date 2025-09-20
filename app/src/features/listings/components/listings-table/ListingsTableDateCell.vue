<script setup lang="ts">
import type { Row } from '@tanstack/vue-table'
import type { Transaction } from '@/lib/supabase/models'
import { computed } from 'vue'
import { formatDate } from '@/lib/utils'

const props = defineProps<{ row: Row<Transaction> }>()
const date = computed(() => formatDate(props.row.original.created_at))
</script>

<template>
  <div class="text-xs text-muted-foreground">
    {{ date }}
  </div>
</template>

<style scoped></style>
