<template>
<div>
  <div class="loading-bar-container" :style="`width: ${maxBarWidth}px`">
    <div class="loading-bar" :style="`width: ${width}px`"/>
  </div>
  {{steps[currentStep]}}
</div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  steps: Array<string>,
  currentStep: number
}>()

const maxBarWidth = 200

const width = computed(() => maxBarWidth * (props.currentStep + 1)/props.steps.length)
</script>

<style scoped>
.loading-bar-container {
  height: 10px;
  border-radius: 10px;
  border: 1px solid var(--color-background-mute);
  margin: auto;
  overflow-y: hidden;
}

.loading-bar {
  height: inherit;
  width: 0;
  background: var(--accent);
}
</style>
