<script setup lang="ts">
import type { HTMLAttributes } from 'vue'
import { cn } from '@/lib/utils'

const props = defineProps<{class?:HTMLAttributes['class']}>()
</script>
<template>
  <div :class="cn('w-5 h-5 relative inline-flex flex-col gap-2 items-center justify-center border-b-foreground', props.class)">
    <i class="absolute w-full h-full rounded-full animate-spinner-ease-spin border-2 border-solid border-t-transparent border-l-transparent border-r-transparent border-b-current"/>
    <i class="absolute w-full h-full rounded-full animate-spinner-linear-spin border-2 border-dotted border-t-transparent border-l-transparent border-r-transparent border-b-current" />
  </div>
</template>