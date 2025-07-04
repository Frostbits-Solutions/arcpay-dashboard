<script setup lang="ts">
import { ref } from 'vue'
import {House, LayoutGrid, Plus, Cog, Book } from 'lucide-vue-next'
import { useDark, useToggle } from '@vueuse/core'
import { Button } from '@/lib/ui/button'
import LogoutPopover from '@/features/auth/components/LogoutPopover.vue'
import { useAccountsStore } from '@/features/accounts/stores/accounts'
import { useNetworksStore } from '@/features/network/stores/networks'

const isDark = useDark({
  selector: '#app',
  valueDark: 'dark'
})

const toggleDark = useToggle(isDark)
const account = useAccountsStore()
const networks = useNetworksStore()
const expanded = ref(false)

function onCreateClick() {
  console.log('Call arcpay SDK')
}

function onMouseLeave() {
  setTimeout(() => {
    expanded.value = false
  }, 50)
} 
</script>

<template>
  <aside id="sidebar" class="group/sidebar fixed top-0 left-0 z-40 w-16 aria-expanded:w-64 h-screen transition-[width]" aria-label="Sidebar" :aria-expanded="expanded" @mouseenter="expanded = true" @mouseleave="onMouseLeave">
    <div class="h-full px-3 py-4 border-r border-r-border group-aria-expanded/sidebar:border-r-transparent group-aria-expanded/sidebar:bg-background/50 group-aria-expanded/sidebar:backdrop-blur-md flex flex-col justify-between text-sm" style="scrollbar-width: none;">
      <div>
        <ul class="space-y-2 font-medium">
          <li>
            <Button variant="ghost" size="icon" class="flex mb-6 hover:bg-foreground size-10" @click="toggleDark()">
              <img src="../../../assets/logo.png" alt="arcpay logo" class="h-8"/>
            </Button>
          </li>
          <li>
            <RouterLink to="/dashboard" class="flex justify-start items-center p-2.5 text-muted-foreground rounded-md hover:bg-foreground/5 hover:backdrop-blur-lg hover:text-foreground group/link">
              <House class="shrink-0 w-5 h-5"/>
              <span class="ms-3 font-light hidden group-aria-expanded/sidebar:block truncate">Home</span>
            </RouterLink>
          </li>
          <li>
            <RouterLink to="/listings" class="flex justify-start items-center p-2.5 text-muted-foreground rounded-md hover:bg-foreground/5 hover:backdrop-blur-lg hover:text-foreground group/link">
              <LayoutGrid class="shrink-0 w-5 h-5"/>
              <span class="ms-3 font-light hidden group-aria-expanded/sidebar:block truncate">Listings</span>
            </RouterLink>
          </li>
          <li v-if="account.active?.name">
            <Button variant="ghost" class="w-full h-auto flex justify-start items-center p-2.5 text-muted-foreground rounded-md hover:bg-foreground/5 hover:backdrop-blur-lg hover:text-foreground group/link" @click="onCreateClick">
              <Plus class="shrink-0 w-5 h-5"/>
              <span class="ms-3 font-light hidden group-aria-expanded/sidebar:block truncate">New listing</span>
            </Button>
          </li>
        </ul>
      </div>
      <ul class="space-y-2 font-medium">
        <li>
          <a href="https://docs.arcpay.dev" class="flex justify-start items-center p-2.5 text-muted-foreground rounded-md hover:bg-foreground/5 hover:backdrop-blur-lg hover:text-foreground group/link" target="_blank">
            <Book class="shrink-0 w-5 h-5"/>
            <span class="ms-3 font-light hidden group-aria-expanded/sidebar:block truncate">Documentation</span>
          </a>
        </li>
        <li v-if="account.active?.name">
          <RouterLink :to="`/organization/${account.active.name}/settings`" class="flex justify-start items-center p-2.5 text-muted-foreground rounded-md hover:bg-foreground/5 hover:backdrop-blur-lg hover:text-foreground group/link">
            <Cog class="shrink-0 w-5 h-5"/>
            <span class="ms-3 font-light hidden group-aria-expanded/sidebar:block truncate">Settings</span>
          </RouterLink>
        </li>
        <li>
          <LogoutPopover/>
        </li>
      </ul>
    </div>
  </aside>
</template>

<style scoped>
#sidebar :deep(.router-link-active) {
  background: hsl(var(--muted));
  color: var(--foreground);
}
</style>