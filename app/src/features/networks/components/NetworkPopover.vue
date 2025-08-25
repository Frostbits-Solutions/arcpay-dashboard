<script setup lang="ts">
import { Button } from '@/lib/ui/button'
import { ChevronDown, Check, GlobeLock } from 'lucide-vue-next'
import { Popover, PopoverContent, PopoverTrigger } from '@/lib/ui/popover'
import { useNetworksStore } from '@/features/networks/stores/networks'

const networks = useNetworksStore()
const supportedNetworks = ['algo:mainnet', 'algo:testnet', 'voi:mainnet']
</script>

<template>
  <Popover>
    <PopoverTrigger>
      <Button variant="outline">
        <GlobeLock class="mr-1 h-4 w-4" />
        {{ networks.activeNetwork?.id }}
        <ChevronDown class="ml-4 h-4 w-4" />
      </Button>
    </PopoverTrigger>
    <PopoverContent side="bottom" align="start" class="p-1">
      <ul class="pb-1 text-foreground">
        <li v-for="network in supportedNetworks" :key="network" class="[&:not(:first-child)]:mt-1 [&:not(:last-child)]:mb-1">
          <Button variant="ghost" :class="['w-full justify-between rounded-sm px-2', network === networks.activeNetwork?.id ? 'bg-muted/70' : '']" @click.prevent="networks.setActive(network)">
            <span class="truncate">
              {{ network }}
            </span>
            <Check v-if="network === networks.activeNetwork?.id" class="ml-2 h-4 w-4 shrink-0 text-foreground" />
          </Button>
        </li>
      </ul>
    </PopoverContent>
  </Popover>
</template>

<style scoped></style>
