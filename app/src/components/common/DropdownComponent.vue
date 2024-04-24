<script setup lang="ts">
import { ref, defineProps, onMounted, nextTick } from 'vue'
import { Dropdown } from 'flowbite'
import type { DropdownOptions } from 'flowbite';

const props = defineProps({
  toggleEl: {
    type: HTMLElement
  },
  placement: {
    default: 'auto'
  }
})
const dropdown = ref<Dropdown | null>(null)
const dropdownEl = ref<HTMLElement | null>(null)

onMounted(() => {
  nextTick(() => {
    dropdown.value = new Dropdown(dropdownEl.value, props.toggleEl, {
      placement: props.placement as DropdownOptions['placement']
    })
    if (dropdown.value) {
      dropdown.value.init()
    }
  })
})
</script>

<template>
  <div ref="dropdownEl" class="z-30 hidden bg-white rounded-lg shadow w-60 dark:bg-gray-700">
    <slot :hide="() => { dropdown?.hide() }"></slot>
  </div>
</template>

<style scoped>

</style>