<script setup lang="ts">
import type { HTMLAttributes } from 'vue'
import { cn } from '@repo/shared/utils'

const props = defineProps<{ class?: HTMLAttributes['class'] }>()
</script>
<template>
  <div :class="cn('border-b-foreground relative inline-flex h-5 w-5 flex-col items-center justify-center gap-2', props.class)">
    <i class="animate-spinner-ease-spin absolute h-full w-full rounded-full border-2 border-solid border-b-current border-l-transparent border-r-transparent border-t-transparent" />
    <i class="animate-spinner-linear-spin absolute h-full w-full rounded-full border-2 border-dotted border-b-current border-l-transparent border-r-transparent border-t-transparent" />
  </div>
</template>
