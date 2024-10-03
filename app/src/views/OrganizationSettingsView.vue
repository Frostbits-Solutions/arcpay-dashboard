<script setup lang="ts">
import { ScrollArea } from '@/components/ui/scroll-area'

const sections = {
  general: 'organization-organization-general',
  team: 'organization-organization-users',
  integrations: 'organization-organization-integrations',
  listings: 'organization-organization-listings'
}
</script>

<template>
  <main class="h-dvh flex items-stretch pl-16 pt-16">
    <div class="px-4 py-10 border-r border-border h-full w-72 relative">
      <ul class="w-full">
        <li>
          <h1 class="scroll-m-20 text-sm font-medium tracking-tight px-2 mb-4">Organization settings</h1>
        </li>
        <li class="settings-link my-1 w-full" v-for="(route, section) in sections" :key="section">
          <router-link :to="{name: route}" class="text-muted-foreground text-sm hover:bg-muted p-2 rounded w-full block capitalize">
            {{ section }}
          </router-link>
        </li>
      </ul>
    </div>
    <ScrollArea class="max-w-screen-xl w-full h-full py-0">
      <div class="p-10">
        <router-view/>
      </div>
    </ScrollArea>
  </main>
</template>

<style scoped>
:deep(.settings-link .router-link-exact-active) {
  background: hsl(var(--muted));
  color: var(--foreground);
}
</style>