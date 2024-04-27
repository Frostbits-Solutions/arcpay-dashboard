<template>
  <input
    type="number"
    :value="props.modelValue"
    :min="min"
    :max="max"
    @input="emit('update:modelValue', $event.target.value)"
  />
</template>

<script setup lang="ts">
const maxInt = Math.pow(10, 1000)

const props = defineProps<{
  modelValue: number,
  min: {
    type: number,
    required: false,
    default: 0
  },
  max: {
    type: number,
    required: false,
    default: maxInt
  },
}>()
const emit = defineEmits(['update:modelValue'])
</script>

<style scoped>

</style>
