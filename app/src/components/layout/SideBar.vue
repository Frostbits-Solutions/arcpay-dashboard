<script setup lang="ts">
import IconHome from '@/components/icons/IconHome.vue'
import IconGrid from '@/components/icons/IconGrid.vue'
import { useSessionStore } from '@/stores/session'
import IconUserCircle from '@/components/icons/IconUserCircle.vue'
import IconCog from '@/components/icons/IconCog.vue'
import IconPlus from '@/components/icons/IconPlus.vue'
import DropdownLogout from '@/components/layout/DropdownLogout.vue'
import { ref } from 'vue'

const session = useSessionStore()
const logOutToggle = ref(undefined)
</script>

<template>
  <button data-drawer-target="sidebar" data-drawer-toggle="sidebar" aria-controls="sidebar" type="button" class="inline-flex items-center p-2 mt-2 ms-3 text-sm text-gray-500 rounded-lg sm:hidden hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-200 dark:text-gray-400 dark:hover:bg-gray-700 dark:focus:ring-gray-600">
    <span class="sr-only">Open sidebar</span>
    <svg class="w-6 h-6" aria-hidden="true" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
      <path clip-rule="evenodd" fill-rule="evenodd" d="M2 4.75A.75.75 0 012.75 4h14.5a.75.75 0 010 1.5H2.75A.75.75 0 012 4.75zm0 10.5a.75.75 0 01.75-.75h7.5a.75.75 0 010 1.5h-7.5a.75.75 0 01-.75-.75zM2 10a.75.75 0 01.75-.75h14.5a.75.75 0 010 1.5H2.75A.75.75 0 012 10z"></path>
    </svg>
  </button>

  <aside id="sidebar" class="group/sidebar fixed top-0 left-0 z-40 w-16 hover:w-48 h-screen -translate-x-full sm:translate-x-0 transition-[width]" aria-label="Sidebar">
    <div class="h-full px-3 py-4 overflow-y-auto overflow-x-hidden bg-gray-100 dark:bg-gray-800 flex flex-col justify-between text-sm">
      <div>
        <ul class="space-y-2 font-medium">
          <li class="px-2"><img src="@/assets/logo.png" alt="arc pay logo" class="w-6 h-6 mb-4 mt-1"/></li>
          <li>
            <RouterLink to="/dashboard" class="flex justify-start items-center  p-2 text-gray-500 rounded-lg hover:bg-gray-200 hover:text-gray-900 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white group/link">
              <IconHome class="shrink-0 w-6 h-6 text-gray-500 transition duration-75 dark:text-gray-400 group-hover/link:text-gray-900 dark:group-hover/link:text-white" />
              <span class="ms-3 font-light invisible group-hover/sidebar:visible truncate">Home</span>
            </RouterLink>
          </li>
        </ul>
        <ul class="pt-4 mt-4 space-y-2 font-medium border-t border-gray-200 dark:border-gray-700">
          <li>
            <RouterLink to="/listings" class="flex justify-start items-center  p-2 text-gray-500 rounded-lg hover:bg-gray-200 hover:text-gray-900 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white group/link">
              <IconGrid class="shrink-0 w-6 h-6 text-gray-500 transition duration-75 dark:text-gray-400 group-hover/link:text-gray-900 dark:group-hover/link:text-white" />
              <span class="ms-3 font-light invisible group-hover/sidebar:visible truncate">Listings</span>
            </RouterLink>
          </li>
          <li>
            <RouterLink to="/listings/new" class="flex justify-start items-center  p-2 text-gray-500 rounded-lg hover:bg-gray-200 hover:text-gray-900 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white group/link">
              <IconPlus class="shrink-0 w-6 h-6 text-gray-500 transition duration-75 dark:text-gray-400 group-hover/link:text-gray-900 dark:group-hover/link:text-white" />
              <span class="ms-3 font-light invisible group-hover/sidebar:visible truncate">New listing</span>
            </RouterLink>
          </li>
        </ul>
      </div>
      <ul class="space-y-2 font-medium">
        <li>
          <RouterLink to="/dashboard/account/settings" class="flex justify-start items-center p-2 text-gray-500 rounded-lg hover:bg-gray-200 hover:text-gray-900 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white group/link">
            <IconCog class="shrink-0 w-6 h-6 text-gray-500 transition duration-75 dark:text-gray-400 group-hover/link:text-gray-900 dark:group-hover/link:text-white" />
            <span class="ms-3 font-light invisible group-hover/sidebar:visible truncate">Settings</span>
          </RouterLink>
        </li>
        <li>
          <button ref="logOutToggle" class="flex justify-start items-center p-2 w-full text-gray-500 rounded-lg hover:bg-gray-200 hover:text-gray-900 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white group/link">
            <IconUserCircle class="shrink-0 w-6 h-6 text-gray-500 transition duration-75 dark:text-gray-400 group-hover/link:text-gray-900 dark:group-hover/link:text-white" />
            <span class="ms-3 font-light invisible group-hover/sidebar:visible truncate">{{ session?.user?.email || 'user@email.com' }}</span>
          </button>
        </li>
      </ul>
    </div>
    <DropdownLogout :toggle-el="logOutToggle" placement="right" />
  </aside>
</template>

<style scoped>

</style>