<script setup lang="ts">
import { useAccountsStore } from '@/stores/accounts'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { ChevronDown, HousePlus, Check } from 'lucide-vue-next'
import { Skeleton } from '@/components/ui/skeleton'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import OrganizationCreationDialog from '@/components/organization/OrganizationCreationDialog.vue'
import { ScrollArea } from '@/components/ui/scroll-area'

const accounts = useAccountsStore()
</script>

<template>
  <Popover v-if="accounts.all?.length">
    <PopoverTrigger>
      <Button variant="outline">
        <template v-if="accounts.active">
          {{ accounts.active?.name || 'Create an organization' }}
          <Badge variant="secondary" class="ml-1">{{ accounts.activeSettings?.subscription?.name || 'free' }}</Badge>
          <ChevronDown class="w-4 h-4 ml-1"/>
        </template>
        <Skeleton v-else class="h-4 w-24 mr-4"/>
      </Button>
    </PopoverTrigger>
    <PopoverContent side="bottom" align="start" class="p-1">
      <ScrollArea class="h-48 border-b border-b-border mb-1">
        <ul class="text-foreground pb-1">
          <li v-for="account in accounts.all" :key="account.id" class="[&:not(:first-child)]:mt-1 [&:not(:last-child)]:mb-1">
            <Button variant="ghost" :class="['w-full justify-between px-2 rounded-sm', account.id === accounts?.active?.id?'bg-muted/70':'']" @click.prevent="accounts.selectAccount(account.id)">
            <span class="truncate">
                {{ account.name }}
            </span>
              <Check v-if="account.id === accounts?.active?.id" class="w-4 h-4 shrink-0 ml-2 text-foreground"/>
            </Button>
          </li>
          <li v-if="!accounts.all.length" class="px-4 py-2 text-xs">
            Create an organization to get started
          </li>
        </ul>
      </ScrollArea>
      <OrganizationCreationDialog>
        <Button variant="ghost" class="w-full rounded-sm">
          <HousePlus class="w-4 h-4 mr-2"/>
          Create new organization
        </Button>
      </OrganizationCreationDialog>
    </PopoverContent>
  </Popover>
  <OrganizationCreationDialog v-else>
    <Button variant="outline" class="rounded-sm">
      <HousePlus class="w-4 h-4 mr-2"/>
      Create new organization
    </Button>
  </OrganizationCreationDialog>
</template>

<style scoped>

</style>