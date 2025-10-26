<script setup lang="ts">
import { useAccountsStore } from '@/features/accounts/stores/accounts'
import { Button } from '@repo/ui/button'
import { Badge } from '@repo/ui/badge'
import { ChevronDown, HousePlus, Check } from 'lucide-vue-next'
import { Skeleton } from '@repo/ui/skeleton'
import { Popover, PopoverContent, PopoverTrigger } from '@repo/ui/popover'
import OrganizationCreationDialog from '@/features/accounts/components/OrganizationCreationDialog.vue'
import { ScrollArea } from '@repo/ui/scroll-area'

const accounts = useAccountsStore()
</script>

<template>
  <Popover v-if="accounts.all?.length">
    <PopoverTrigger>
      <Button variant="outline">
        <template v-if="accounts.active">
          {{ accounts.active?.name }}
          <Badge variant="secondary" class="ml-1" v-if="accounts.activeSettings?.subscription_tiers?.name">{{ accounts.activeSettings?.subscription_tiers?.name }}</Badge>
          <ChevronDown class="ml-1 h-4 w-4" />
        </template>
        <Skeleton v-else class="mr-4 h-4 w-24" />
      </Button>
    </PopoverTrigger>
    <PopoverContent side="bottom" align="start" class="p-1">
      <ScrollArea class="mb-1 h-48 border-b border-b-border">
        <ul class="pb-1 text-foreground">
          <li v-for="account in accounts.all" :key="account.id" class="[&:not(:first-child)]:mt-1 [&:not(:last-child)]:mb-1">
            <Button variant="ghost" :class="['w-full justify-between rounded-sm px-2', account.id === accounts?.active?.id ? 'bg-muted/70' : '']" @click.prevent="accounts.selectAccount(account.id)">
              <span class="truncate">
                {{ account.name }}
              </span>
              <Check v-if="account.id === accounts?.active?.id" class="ml-2 h-4 w-4 shrink-0 text-foreground" />
            </Button>
          </li>
          <li v-if="!accounts.all.length" class="px-4 py-2 text-xs">Create an organization to get started</li>
        </ul>
      </ScrollArea>
      <OrganizationCreationDialog>
        <Button variant="ghost" class="w-full rounded-sm">
          <HousePlus class="mr-2 h-4 w-4" />
          Create new organization
        </Button>
      </OrganizationCreationDialog>
    </PopoverContent>
  </Popover>
  <OrganizationCreationDialog v-else>
    <Button variant="outline" class="rounded-sm">
      <HousePlus class="mr-2 h-4 w-4" />
      Create new organization
    </Button>
  </OrganizationCreationDialog>
</template>

<style scoped></style>
