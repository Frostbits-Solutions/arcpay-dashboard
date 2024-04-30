<script setup lang="ts">
import { ref, defineEmits } from 'vue'
import Modal from '@/components/common/ModalComponent.vue'
import { useModalsStore } from '@/stores/modals'

const emit = defineEmits(['success'])

const modalName = 'ModalSecondaryMarketFees'
const modals = useModalsStore()
const percentage = ref('1.5')

async function handleSubmit() {
  console.log("fees updated")
  modals.hideModal(modalName)
  emit('success')
}
</script>

<template>
  <Modal :modal-name="modalName">
    <template #header>
      <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
        Secondary market fees
      </h3>
    </template>
    <template #body>
      <form class="p-4 md:p-5" @submit.prevent="handleSubmit()">
        <div class="grid gap-4 mb-8 grid-cols-2">
          <div class="col-span-2">
            <label for="domain" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">Fees percentage</label>
            <input v-model="percentage" type="number" min="0" max="100" name="percentage" id="percentage" class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-primary-600 focus:border-primary-600 block w-full p-2.5 dark:bg-gray-600 dark:border-gray-500 dark:placeholder-gray-400 dark:text-white dark:focus:ring-primary-500 dark:focus:border-primary-500" placeholder="%" required>
          </div>
        </div>
        <button type="submit" class="text-white inline-flex items-center bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800">
          Add fees
        </button>
      </form>
    </template>
  </Modal>
</template>

<style scoped>
</style>