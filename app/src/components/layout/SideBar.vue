<script setup lang="ts">
import {House, LayoutGrid, Plus, Cog } from 'lucide-vue-next'
import { useDark, useToggle } from '@vueuse/core'
import { Button } from '@/components/ui/button'
import LogoutPopover from '@/components/layout/LogoutPopover.vue'
import { useAccountsStore } from '@/stores/accounts'
import { useNetworksStore } from '@/stores/networks'

const isDark = useDark({
  selector: '#app',
  valueDark: 'dark'
})

const toggleDark = useToggle(isDark)
const account = useAccountsStore()
const networks = useNetworksStore()

function onCreateClick() {
  networks.activeClient?.toggleDarkMode(isDark.value)
  networks.activeClient?.create({accountId: account.active?.id})
}
</script>

<template>
  <aside id="sidebar" class="group/sidebar fixed top-0 left-0 z-40 w-16 hover:w-64 h-screen transition-[width]" aria-label="Sidebar">
    <div class="h-full px-3 py-4 overflow-y-auto overflow-x-hidden border-r border-r-border hover:border-r-transparent hover:bg-background/50 backdrop-blur-md flex flex-col justify-between text-sm">
      <div>
        <ul class="space-y-2 font-medium">
          <li>
            <Button variant="ghost" class="flex px-2 py-2 h-auto mb-6 -mt-0.5 -ml-[1px] hover:bg-foreground" @click="toggleDark()">
              <img src="@/assets/logo.png" alt="arcpay logo" class="w-6 h-6"/>
            </Button>
          </li>
          <li>
            <RouterLink to="/dashboard" class="flex justify-start items-center p-2.5 text-muted-foreground rounded-md hover:bg-foreground/5 hover:backdrop-blur-lg hover:text-foreground group/link">
              <House class="shrink-0 w-5 h-5"/>
              <span class="ms-3 font-light invisible group-hover/sidebar:visible truncate">Home</span>
            </RouterLink>
          </li>
          <li>
            <RouterLink to="/listings" class="flex justify-start items-center p-2.5 text-muted-foreground rounded-md hover:bg-foreground/5 hover:backdrop-blur-lg hover:text-foreground group/link">
              <LayoutGrid class="shrink-0 w-5 h-5"/>
              <span class="ms-3 font-light invisible group-hover/sidebar:visible truncate">Listings</span>
            </RouterLink>
          </li>
          <li v-if="account.active?.name">
            <Button variant="ghost" class="w-full h-auto flex justify-start items-center p-2.5 text-muted-foreground rounded-md hover:bg-foreground/5 hover:backdrop-blur-lg hover:text-foreground group/link" @click="onCreateClick">
              <Plus class="shrink-0 w-5 h-5"/>
              <span class="ms-3 font-light invisible group-hover/sidebar:visible truncate">New listing</span>
            </Button>
          </li>
        </ul>
      </div>
      <ul class="space-y-2 font-medium">
        <li v-if="account.active?.name">
          <RouterLink :to="`/organization/${account.active.name}/settings`" class="flex justify-start items-center p-2.5 text-muted-foreground rounded-md hover:bg-foreground/5 hover:backdrop-blur-lg hover:text-foreground group/link">
            <Cog class="shrink-0 w-5 h-5"/>
            <span class="ms-3 font-light invisible group-hover/sidebar:visible truncate">Settings</span>
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