<script setup lang="ts">
import type { Row } from '@tanstack/vue-table'
import type { ListingDetail } from '@repo/supabase/models'
import { computed } from 'vue'
import ListingsShareButton from '@/features/listings/components/listings-table/ListingsShareButton.vue'
import ListingsSettingsPopover from '@/features/listings/components/listings-table/ListingsActionPopover.vue'

const props = defineProps<{ row: Row<ListingDetail> }>()
const id = computed(() => props.row.original.id)
</script>

<template>
  <ListingsShareButton v-if="id" :id="id" />
  <ListingsSettingsPopover v-if="id" :id="id" />
</template>

<style scoped></style>
