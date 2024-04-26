<script setup lang="ts">
import { ref } from 'vue'
import IconChevronSort from '@/components/icons/IconChevronSort.vue'
import { useAccountsStore } from '@/stores/accounts'
import AccountsNavDropdown from '@/components/account/DropdownAccountsNav.vue'
import NewAccountModal from '@/components/account/NewAccountModal.vue'


const accounts = useAccountsStore()
const dropdownToggle = ref(undefined)
</script>

<template>
  <nav class="bg-white dark:bg-gray-900 flex flex-wrap items-center justify-between fixed w-full z-20 top-0 left-O pl-20 py-4 pr-4 border-b border-gray-200 dark:border-gray-700 box-border">
    <button ref="dropdownToggle" type="button" class="flex items-center text-gray-900 bg-white border border-gray-300 focus:outline-none hover:bg-gray-100 focus:ring-4 focus:ring-gray-100 font-medium rounded-lg text-xs px-2.5 py-1.5 dark:bg-gray-800 dark:text-white dark:border-gray-600 dark:hover:bg-gray-700 dark:hover:border-gray-600 dark:focus:ring-gray-700">
      <template v-if="accounts.active">
        {{ accounts.active.name }}
        <span class="ms-2 bg-gray-100 text-gray-800 text-xs font-medium px-2.5 py-0.5 rounded-xl dark:bg-gray-700 dark:text-gray-400 border border-gray-500">free</span>
      </template>
      <div v-else class="h-4 bg-gray-200 rounded-full dark:bg-gray-700 w-24 mr-4 animate-pulse"></div>
      <IconChevronSort class="w-4 h-4 ms-2"/>
    </button>
  </nav>
  <AccountsNavDropdown :toggle-el="dropdownToggle"/>
  <NewAccountModal/>
</template>

<style scoped>

</style>