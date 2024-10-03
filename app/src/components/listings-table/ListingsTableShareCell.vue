<script setup lang="ts">
import type { Row } from '@tanstack/vue-table'
import type { CompositeListing } from '@/models'
import { computed, h } from 'vue'
import { useNetworksStore } from '@/stores/networks'
import { Button } from '@/components/ui/button'
import { Share2, Check } from 'lucide-vue-next'
import { useToast } from '@/components/ui/toast'
import { useClipboard } from '@vueuse/core'
import ToastCheck from '@/components/ui/toast/ToastCheck.vue'

const props = defineProps<{row: Row<CompositeListing>}>()
const id = computed(() => props.row.original.id)
const networks = useNetworksStore()
const link = computed(() => {
  return `${window.origin}${import.meta.env.BASE_URL}${networks?.activeNetwork}/listing/${id.value}/`
})

const { toast } = useToast()
const { copy, copied, isSupported } = useClipboard({ source: link.value })

function onClick() {
  copy(link.value)
  toast({
    title: `Copied to clipboard!`,
    action: h(ToastCheck)
  });
}
</script>

<template>
  <Button variant="ghost" size="icon" @click="onClick">
    <template v-if="isSupported">
      <Share2 v-if="!copied" class="size-4 text-muted-foreground"/>
      <Check v-else class="size-4"/>
    </template>

  </Button>
</template>

<style scoped>

</style>