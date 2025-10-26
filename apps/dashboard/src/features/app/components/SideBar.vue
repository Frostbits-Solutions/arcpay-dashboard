<script setup lang="ts">
import { ref } from 'vue'
import { House, LayoutGrid, Plus, Cog, Book } from 'lucide-vue-next'
import { useDark, useToggle } from '@vueuse/core'
import { Button } from '@repo/ui/button'
import LogoutPopover from '@/features/auth/components/LogoutPopover.vue'
import { useAccountsStore } from '@/features/accounts/stores/accounts'
import { useNetworksStore } from '@/features/networks/stores/networks'
import logo from '@repo/ui/assets/logo.png'

const isDark = useDark({
  selector: '#app',
  valueDark: 'dark',
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
  <aside
    id="sidebar"
    class="group/sidebar fixed left-0 top-0 z-40 h-screen w-16 transition-[width] aria-expanded:w-64"
    aria-label="Sidebar"
    :aria-expanded="expanded"
    @mouseenter="expanded = true"
    @mouseleave="onMouseLeave"
  >
    <div
      class="flex h-full flex-col justify-between border-r border-r-border px-3 py-4 text-sm group-aria-expanded/sidebar:border-r-transparent group-aria-expanded/sidebar:bg-background/50 group-aria-expanded/sidebar:backdrop-blur-md"
      style="scrollbar-width: none"
    >
      <div>
        <ul class="space-y-2 font-medium">
          <li>
            <Button variant="ghost" size="icon" class="mb-6 flex size-10 hover:bg-foreground" @click="toggleDark()">
              <img :src="logo" alt="arcpay logo" class="h-8" />
            </Button>
          </li>
          <li>
            <RouterLink to="/dashboard" class="group/link flex items-center justify-start rounded-md p-2.5 text-muted-foreground hover:bg-foreground/5 hover:text-foreground hover:backdrop-blur-lg">
              <House class="h-5 w-5 shrink-0" />
              <span class="ms-3 hidden truncate font-light group-aria-expanded/sidebar:block">Home</span>
            </RouterLink>
          </li>
          <li>
            <RouterLink to="/listings" class="group/link flex items-center justify-start rounded-md p-2.5 text-muted-foreground hover:bg-foreground/5 hover:text-foreground hover:backdrop-blur-lg">
              <LayoutGrid class="h-5 w-5 shrink-0" />
              <span class="ms-3 hidden truncate font-light group-aria-expanded/sidebar:block">Listings</span>
            </RouterLink>
          </li>
          <li v-if="account.active?.name">
            <Button
              variant="ghost"
              class="group/link flex h-auto w-full items-center justify-start rounded-md p-2.5 text-muted-foreground hover:bg-foreground/5 hover:text-foreground hover:backdrop-blur-lg"
              @click="onCreateClick"
            >
              <Plus class="h-5 w-5 shrink-0" />
              <span class="ms-3 hidden truncate font-light group-aria-expanded/sidebar:block">New listing</span>
            </Button>
          </li>
        </ul>
      </div>
      <ul class="space-y-2 font-medium">
        <li>
          <a
            href="https://docs.arcpay.dev"
            class="group/link flex items-center justify-start rounded-md p-2.5 text-muted-foreground hover:bg-foreground/5 hover:text-foreground hover:backdrop-blur-lg"
            target="_blank"
          >
            <Book class="h-5 w-5 shrink-0" />
            <span class="ms-3 hidden truncate font-light group-aria-expanded/sidebar:block">Documentation</span>
          </a>
        </li>
        <li v-if="account.active?.name">
          <RouterLink
            :to="`/organization/${account.active.name}/settings`"
            class="group/link flex items-center justify-start rounded-md p-2.5 text-muted-foreground hover:bg-foreground/5 hover:text-foreground hover:backdrop-blur-lg"
          >
            <Cog class="h-5 w-5 shrink-0" />
            <span class="ms-3 hidden truncate font-light group-aria-expanded/sidebar:block">Settings</span>
          </RouterLink>
        </li>
        <li>
          <LogoutPopover />
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
