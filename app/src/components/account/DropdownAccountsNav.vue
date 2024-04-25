<script setup lang="ts">
import IconCheck from '@/components/icons/IconCheck.vue'
import IconPlus from '@/components/icons/IconPlus.vue'
import DropdownComponent from '@/components/common/DropdownComponent.vue'
import { defineProps } from 'vue'
import { useAccountsStore } from '@/stores/accounts'
import { useModalsStore } from '@/stores/modals'

const props = defineProps({
  toggleEl: {
    type: HTMLElement
  }
})

const accounts = useAccountsStore()
const modals = useModalsStore()

function showCreateAccountModal(hide: (() => void) | undefined) {
  if (hide) hide()
  modals.showModal("NewAccountModal")
}

</script>

<template>
  <DropdownComponent :toggle-el="props.toggleEl" placement="bottom-start">
    <template #default="slotProps">
        <ul class="max-h-48 py-2 overflow-y-auto text-gray-700 dark:text-gray-200" aria-labelledby="dropdownUsersButton">
          <li v-for="account in accounts.all" :key="account.id">
            <a @click.prevent="accounts.selectAccount(account.id)" href="#" class="flex items-center justify-between px-4 py-2 text-xs hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">
              <span class="truncate">
                {{ account.name }}
              </span>
              <IconCheck v-if="account.id === accounts?.active?.id" class="w-4 h-4 shrink-0 ml-2"/>
            </a>
          </li>
          <li v-if="!accounts.all.length" class="px-4 py-2 text-xs">
            Create an organization to get started
          </li>
        </ul>
        <button @click="showCreateAccountModal(slotProps?.hide)" class="flex w-full items-center p-3 text-xs font-medium text-blue-600 border-t border-gray-200 rounded-b-lg dark:border-gray-600 hover:bg-gray-100 dark:hover:bg-gray-600 dark:text-blue-500 hover:underline">
          <IconPlus class="w-4 h-4 me-2"/>
          Create new organization
        </button>
    </template>
  </DropdownComponent>
</template>

<style scoped>

</style>