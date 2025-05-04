<script setup lang="ts">
import type { Row } from '@tanstack/vue-table'
import type { TransactionWithListings } from '@/models'
import { computed } from 'vue'
import { formatDate } from '@/lib/utils'

const props = defineProps<{row: Row<TransactionWithListings>}>()
const date = computed(() => formatDate(props.row.original.created_at))
</script>

<template>
  <div class="text-xs text-muted-foreground">
    {{ date}}
  </div>
</template>

<style scoped>

</style>