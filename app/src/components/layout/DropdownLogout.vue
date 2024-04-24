<script setup lang="ts">
import DropdownComponent from '@/components/common/DropdownComponent.vue'
import { defineProps } from 'vue'
import IconDisconnect from '@/components/icons/IconDisconnect.vue'
import { supabase } from '@/lib/supabase/supabaseClient'
import router from '@/router'

const props = defineProps({
  toggleEl: {
    type: HTMLElement
  }
})

async function logOut() {
  await supabase.auth.signOut()
  await router.push({ name: 'authentication' }) // Redirect to login page after logging out
}

function hideDropdown(hide: (() => void) | undefined) {
  if (hide) hide()
}

</script>

<template>
  <DropdownComponent :toggle-el="props.toggleEl">
    <template #default="slotProps">
      <button @click="logOut" @mouseleave="hideDropdown(slotProps.hide)" class="flex w-full items-center p-3 text-xs font-medium border-gray-200 rounded-b-lg dark:border-gray-600 hover:bg-gray-100 dark:hover:bg-gray-600 hover:underline">
        <IconDisconnect class="w-4 h-4 me-2"/>
        Logout
      </button>
    </template>
  </DropdownComponent>
</template>

<style scoped>

</style>