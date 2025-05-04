<script setup lang="ts">
import type { Row } from '@tanstack/vue-table'
import type { CompositeListing } from '@/models'
import { computed } from 'vue'

const props = defineProps<{row: Row<CompositeListing>}>()
const type = computed(() => props.row.original.type)
</script>

<template>
  <div class="text-muted-foreground uppercase">
    {{ type }}
  </div>
</template>

<style scoped>

</style>