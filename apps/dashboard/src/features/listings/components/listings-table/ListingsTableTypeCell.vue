<script setup lang="ts">
import type { Row } from '@tanstack/vue-table'
import type { ListingDetail } from '@repo/supabase/models'
import { computed } from 'vue'

const props = defineProps<{ row: Row<ListingDetail> }>()
const type = computed(() => props.row.original.type)
</script>

<template>
  <div class="uppercase text-muted-foreground">
    {{ type }}
  </div>
</template>

<style scoped></style>
