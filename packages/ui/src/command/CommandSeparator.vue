<script lang="ts" setup>
import { computed, type HTMLAttributes } from 'vue'
import type { ComboboxSeparatorProps } from 'radix-vue'
import { ComboboxSeparator } from 'radix-vue'
import { cn } from '@repo/shared/utils'

const props = defineProps<ComboboxSeparatorProps & { class?: HTMLAttributes['class'] }>()

const delegatedProps = computed(() => {
  const { class: _, ...delegated } = props

  return delegated
})
</script>

<template>
  <ComboboxSeparator :class="cn('bg-border -mx-1 h-px', props.class)" v-bind="delegatedProps">
    <slot />
  </ComboboxSeparator>
</template>
