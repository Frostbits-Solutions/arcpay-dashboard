<script setup lang="ts">
import { supabase } from '@/lib/supabase/supabaseClient'
import router from '@/router'
import { Button } from '@/components/ui/button'
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger} from '@/components/ui/tooltip'
import { CircleUser, Power } from 'lucide-vue-next'
import { useSessionStore } from '@/stores/session'

const session = useSessionStore()

async function logOut() {
  await supabase.auth.signOut()
  await router.push({ name: 'authentication' }) // Redirect to login page after logging out
}
</script>

<template>
  <TooltipProvider :delayDuration="50">
    <Tooltip>
      <TooltipTrigger>
        <Button variant="ghost" class="w-full h-auto flex justify-start items-center p-2.5 text-muted-foreground rounded-md hover:bg-foreground/5 hover:backdrop-blur-lg hover:text-foreground group/link">
          <CircleUser class="shrink-0 w-5 h-5"/>
          <span class="w-[172px] ms-3 font-light invisible group-hover/sidebar:visible truncate">{{ session?.user?.email || 'user@email.com' }}</span>
        </Button>
      </TooltipTrigger>
      <TooltipContent side="top" align="start" class="p-1 w-[230px]" :disable-portal="true">
        <Button variant="ghost" @click="logOut" class="w-full justify-start p-2">
          <Power class="w-4 h-4 me-2"/>
          Logout
        </Button>
      </TooltipContent>
    </Tooltip>
  </TooltipProvider>
</template>

<style scoped>

</style>