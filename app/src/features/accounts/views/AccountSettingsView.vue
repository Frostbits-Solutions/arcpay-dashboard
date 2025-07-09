<script setup lang="ts">
import { ScrollArea } from '@/lib/ui/scroll-area'

const sections = {
  general: 'organization-organization-general',
  team: 'organization-organization-users',
  listings: 'organization-organization-listings',
  security: 'organization-organization-security',
}
</script>

<template>
  <main class="flex h-dvh items-stretch pl-16 pt-16">
    <div class="relative h-full w-72 border-r border-border px-4 py-10">
      <ul class="w-full">
        <li>
          <h1 class="mb-4 scroll-m-20 px-2 text-sm font-medium tracking-tight">Organization settings</h1>
        </li>
        <li class="settings-link my-1 w-full" v-for="(route, section) in sections" :key="section">
          <router-link :to="{ name: route }" class="block w-full rounded p-2 text-sm capitalize text-muted-foreground hover:bg-muted">
            {{ section }}
          </router-link>
        </li>
      </ul>
    </div>
    <ScrollArea class="h-full w-full max-w-screen-xl py-0">
      <div class="p-10">
        <router-view />
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
