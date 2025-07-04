<script setup lang="ts">
import {EllipsisVertical, Trash2, ShieldBan} from 'lucide-vue-next'
import { Button } from '@/lib/ui/button'
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from '@/lib/ui/popover'
import { useNetworksStore } from '@/features/network/stores/networks'

const networks = useNetworksStore()
const props = defineProps<{id: string}>()
</script>

<template>
  <Popover>
    <PopoverTrigger>
      <Button variant="ghost" size="icon">
        <EllipsisVertical class="size-4 text-muted-foreground"/>
      </Button>
    </PopoverTrigger>
    <PopoverContent class="p-1">
      <Button variant="ghost" class="w-full justify-start" @click="console.log('Arcpay SDK - Cancel')">
        <Trash2 class="size-4 mr-2"/>
        Cancel
      </Button>
      <!--<Button variant="ghost" class="w-full justify-start">
        <ShieldBan class="size-4 mr-2"/>
        Banish
      </Button>-->
    </PopoverContent>
  </Popover>
</template>

<style scoped>

</style>