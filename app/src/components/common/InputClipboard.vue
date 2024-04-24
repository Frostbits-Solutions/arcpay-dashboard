<script setup lang="ts">
import { defineProps, onMounted } from 'vue'
import { CopyClipboard, Tooltip } from 'flowbite'

const props = defineProps({
  id: String,
  value: String
})

function showSuccess($defaultEl: HTMLElement, $successEl: HTMLElement) {
  $defaultEl.classList.add('hidden');
  $successEl.classList.remove('hidden');
}

function resetToDefault($defaultEl: HTMLElement, $successEl: HTMLElement) {
  $defaultEl.classList.remove('hidden');
  $successEl.classList.add('hidden');
}

onMounted(() => {
  if (props.id) {
    const clipboardEl = document.getElementById(props.id) as HTMLInputElement
    const tooltipEl = document.getElementById(`tooltip-${props.id}`)
    const defaultMessageEl = document.getElementById(`default-tooltip-message-${props.id}`)
    const successMessageEl = document.getElementById(`success-tooltip-message-${props.id}`)
    const defaultIconEl = document.getElementById(`default-icon-${props.id}`)
    const successIconEl = document.getElementById(`success-icon-${props.id}`)

    const tooltip = new Tooltip(tooltipEl, defaultIconEl)

    const clipboard = new CopyClipboard(defaultIconEl, clipboardEl)
    clipboard.updateOnCopyCallback(() => {
      if (defaultMessageEl && defaultIconEl && successMessageEl && successIconEl){
        showSuccess(defaultMessageEl, successMessageEl);
        showSuccess(defaultIconEl, successIconEl);
        tooltip.show();

        // reset to default state
        setTimeout(() => {
          resetToDefault(defaultMessageEl, successMessageEl);
          resetToDefault(defaultIconEl, successIconEl);
          tooltip.hide();
        }, 2000);
      }
    })
  }
})
</script>

<template>
  <div class="relative">
    <input :id="id" type="text" class="truncate bg-gray-50 border border-gray-300 text-gray-500 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 pr-10 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-gray-400 dark:focus:ring-blue-500 dark:focus:border-blue-500" :value="props.value" disabled readonly>
    <button :data-copy-to-clipboard-target="id" :data-tooltip-target="`tooltip-${id}`" class="absolute end-2 top-1/2 -translate-y-1/2 text-gray-500 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg p-2 inline-flex items-center justify-center">
      <span :id="`default-icon-${id}`">
        <svg class="w-3.5 h-3.5" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 18 20">
          <path d="M16 1h-3.278A1.992 1.992 0 0 0 11 0H7a1.993 1.993 0 0 0-1.722 1H2a2 2 0 0 0-2 2v15a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V3a2 2 0 0 0-2-2Zm-3 14H5a1 1 0 0 1 0-2h8a1 1 0 0 1 0 2Zm0-4H5a1 1 0 0 1 0-2h8a1 1 0 1 1 0 2Zm0-5H5a1 1 0 0 1 0-2h2V2h4v2h2a1 1 0 1 1 0 2Z"/>
        </svg>
      </span>
      <span :id="`success-icon-${id}`" class="hidden inline-flex items-center">
        <svg class="w-3.5 h-3.5 text-blue-700 dark:text-blue-500" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 16 12">
          <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 5.917 5.724 10.5 15 1.5"/>
        </svg>
      </span>
    </button>
    <div :id="`tooltip-${id}`" role="tooltip" class="absolute z-10 invisible inline-block px-3 py-2 text-sm font-medium text-white transition-opacity duration-300 bg-gray-900 rounded-lg shadow-sm opacity-0 tooltip dark:bg-gray-700">
      <span :id="`default-tooltip-message-${id}`">Copy to clipboard</span>
      <span :id="`success-tooltip-message-${id}`" class="hidden">Copied!</span>
      <div class="tooltip-arrow" data-popper-arrow></div>
    </div>
  </div>
</template>

<style scoped>

</style>