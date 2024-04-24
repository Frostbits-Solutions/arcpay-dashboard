<script setup lang="ts">
import { ref, defineEmits } from 'vue'
import { useAccountsStore } from '@/stores/accounts'
import Modal from '@/components/common/ModalComponent.vue'
import { useModalsStore } from '@/stores/modals'
import { createAccountApiKey } from '@/lib/supabase/accounts'

const emit = defineEmits(['success'])

const modalName = 'ModalAccountAddKey'
const accounts = useAccountsStore()
const modals = useModalsStore()
const keyName = ref('')
const domain = ref('')

async function handleAddKey() {
  if (accounts?.active?.id) {
    const {data, error} =  await createAccountApiKey(accounts?.active?.id, domain.value, keyName.value)
    if (error) {
      console.error(error)
    } else {
      console.log("key added")
      modals.hideModal(modalName)
      emit('success')
    }
  }
}
</script>

<template>
  <Modal :modal-name="modalName">
    <template #header>
      <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
        Create new API key for {{ accounts?.active?.name }}
      </h3>
    </template>
    <template #body>
      <form class="p-4 md:p-5" @submit.prevent="handleAddKey()">
        <div class="grid gap-4 mb-8 grid-cols-2">
          <div class="col-span-2">
            <label for="name" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">Key name</label>
            <input v-model="keyName" type="text" name="name" id="name" class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-primary-600 focus:border-primary-600 block w-full p-2.5 dark:bg-gray-600 dark:border-gray-500 dark:placeholder-gray-400 dark:text-white dark:focus:ring-primary-500 dark:focus:border-primary-500" placeholder="Type key name" required>
          </div>
          <div class="col-span-2">
            <label for="domain" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">Domain</label>
            <input v-model="domain" type="url" name="domain" id="domain" class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-primary-600 focus:border-primary-600 block w-full p-2.5 dark:bg-gray-600 dark:border-gray-500 dark:placeholder-gray-400 dark:text-white dark:focus:ring-primary-500 dark:focus:border-primary-500" placeholder="Type domain" required>
          </div>
        </div>
        <button type="submit" class="text-white inline-flex items-center bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800">
          Create key
        </button>
      </form>
    </template>
  </Modal>
</template>

<style scoped>
</style>