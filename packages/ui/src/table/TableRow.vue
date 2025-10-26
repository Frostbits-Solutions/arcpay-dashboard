<script setup lang="ts">
import type { HTMLAttributes } from 'vue'
import { cn } from '@repo/shared/utils'

const props = defineProps<{
  class?: HTMLAttributes['class']
}>()
</script>

<template>
  <tr :class="cn('border-border hover:bg-muted/50 data-[state=selected]:bg-muted border-b transition-colors', props.class)">
    <slot />
  </tr>
</template>
