<script setup lang="ts">
import type { Row } from '@tanstack/vue-table'
import type { CompositeListing } from '@/models'
import { computed } from 'vue'
import ListingsShareButton from '@/components/listings-table/ListingsShareButton.vue'
import ListingsSettingsPopover from '@/components/listings-table/ListingsActionPopover.vue'

const props = defineProps<{row: Row<CompositeListing>}>()
const id = computed(() => props.row.original.id)
</script>

<template>
  <ListingsShareButton :id="id"/>
  <ListingsSettingsPopover :id="id"/>
</template>

<style scoped>

</style>