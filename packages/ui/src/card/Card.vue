<script setup lang="ts">
import type { HTMLAttributes } from 'vue'
import { cn } from '@repo/shared/utils'

const props = defineProps<{
  class?: HTMLAttributes['class']
}>()
</script>

<template>
  <div :class="cn('border-border bg-card text-card-foreground rounded-xl border shadow', props.class)">
    <slot />
  </div>
</template>
