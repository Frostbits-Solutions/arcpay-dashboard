<script setup lang="ts">
import type { HTMLAttributes } from 'vue'
import { cn } from '@repo/shared/utils'

const props = defineProps<{
  class?: HTMLAttributes['class']
}>()
</script>

<template>
  <div class="relative w-full overflow-auto">
    <table :class="cn('border-border w-full caption-bottom text-sm', props.class)">
      <slot />
    </table>
  </div>
</template>
