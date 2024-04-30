<script setup lang="ts">
import { ref, defineEmits } from 'vue'
import { useAccountsStore } from '@/stores/accounts'
import Modal from '@/components/common/ModalComponent.vue'
import { useModalsStore } from '@/stores/modals'
import { addAccountUser } from '@/lib/supabase/accounts'

const emit = defineEmits(['success'])

const modalName = 'ModalAccountAddUser'
const accounts = useAccountsStore()
const modals = useModalsStore()
const userEmail = ref('')
const userRole = ref<'member' | 'admin'>('member')

async function handleAddUser() {
  if (typeof accounts?.active?.id !== 'undefined') {
    const {data, error} =  await addAccountUser(accounts.active.id, userEmail.value, userRole.value)
    if (error) {
      console.error(error)
    } else {
      console.log("user added")
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
        Add user to {{ accounts?.active?.name }}
      </h3>
    </template>
    <template #body>
      <form class="p-4 md:p-5" @submit.prevent="handleAddUser()">
        <div class="grid gap-4 mb-8 grid-cols-2">
          <div class="col-span-2">
            <label for="name" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">Email</label>
            <input v-model="userEmail" type="email" name="mail" id="mail" class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-primary-600 focus:border-primary-600 block w-full p-2.5 dark:bg-gray-600 dark:border-gray-500 dark:placeholder-gray-400 dark:text-white dark:focus:ring-primary-500 dark:focus:border-primary-500" placeholder="Type user email" required>
          </div>
          <div class="col-span-2">
            <label for="roles" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">Role</label>
            <select v-model="userRole" id="roles" class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" required>
              <option value="admin">Admin</option>
              <option value="member">Member</option>
            </select>
          </div>
        </div>
        <button type="submit" class="text-white inline-flex items-center bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800">
          Add user
        </button>
      </form>
    </template>
  </Modal>
</template>

<style scoped>
</style>