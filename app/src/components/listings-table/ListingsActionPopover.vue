<script setup lang="ts">
import {EllipsisVertical, Trash2, ShieldBan} from 'lucide-vue-next'
import { Button } from '@/components/ui/button'
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from '@/components/ui/popover'
import { useNetworksStore } from '@/stores/networks'

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
      <Button variant="ghost" class="w-full justify-start" @click="networks?.activeClient?.cancel(id)">
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