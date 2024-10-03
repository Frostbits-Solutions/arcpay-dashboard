<script setup lang="ts">
import { useClipboard } from '@vueuse/core'
import { Button } from '@/components/ui/button'
import { Clipboard, ClipboardCheck } from 'lucide-vue-next'
import { h, type HTMLAttributes } from 'vue'
import { cn } from '@/lib/utils'
import { useToast } from '@/components/ui/toast'
import ToastCheck from '@/components/ui/toast/ToastCheck.vue'

const props = defineProps<{
  source: string,
  class?:HTMLAttributes['class']
}>()
const { toast } = useToast()
const { copy, copied, isSupported } = useClipboard({ source: props.source })

function onClick() {
  copy(props.source)
  toast({
    title: `Copied to clipboard!`,
    action: h(ToastCheck)
  });
}
</script>

<template>
  <Button variant="outline"  @click="onClick" :class="cn('p-4 h-12', props.class)">
    {{ source }}
    <template v-if="isSupported">
      <Clipboard v-if="!copied" class="size-4 ms-2"/>
      <ClipboardCheck v-else class="size-4 ms-2"/>
    </template>
  </Button>
</template>

<style scoped>

</style>