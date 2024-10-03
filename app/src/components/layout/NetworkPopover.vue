<script setup lang="ts">
import { Button } from '@/components/ui/button'
import { ChevronDown, Check, GlobeLock } from 'lucide-vue-next'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import { useNetworksStore } from '@/stores/networks'
import type { Chain } from '@/models'

const networks = useNetworksStore()
const supportedNetworks = ['algo:mainnet', 'algo:testnet']
</script>

<template>
  <Popover>
    <PopoverTrigger>
      <Button variant="outline">
        <GlobeLock class="w-4 h-4 mr-1"/>
        {{ networks.activeNetwork }}
        <ChevronDown class="w-4 h-4 ml-4"/>
      </Button>
    </PopoverTrigger>
    <PopoverContent side="bottom" align="start" class="p-1">
      <ul class="text-foreground pb-1">
        <li v-for="network in supportedNetworks" :key="network" class="[&:not(:first-child)]:mt-1 [&:not(:last-child)]:mb-1">
          <Button variant="ghost" :class="['w-full justify-between px-2 rounded-sm', network === networks.activeNetwork?'bg-muted/70':'']" @click.prevent="networks.setActive(network as Chain)">
            <span class="truncate">
              {{ network }}
            </span>
            <Check v-if="network === networks.activeNetwork" class="w-4 h-4 shrink-0 ml-2 text-foreground"/>
          </Button>
        </li>
      </ul>
    </PopoverContent>
  </Popover>

</template>

<style scoped>

</style>