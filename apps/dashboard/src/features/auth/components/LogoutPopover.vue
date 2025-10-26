<script setup lang="ts">
import { supabase } from '@/lib/supabase/supabaseClient'
import router from '@/features/app/router'
import { Button } from '@repo/ui/button'
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from '@repo/ui/tooltip'
import { CircleUser, Power } from 'lucide-vue-next'
import { useSessionStore } from '@/features/auth/stores/session'

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
        <Button
          variant="ghost"
          class="group/link flex h-auto w-full items-center justify-start rounded-md p-2.5 text-muted-foreground hover:bg-foreground/5 hover:text-foreground hover:backdrop-blur-lg"
        >
          <CircleUser class="h-5 w-5 shrink-0" />
          <span class="ms-3 hidden w-[172px] truncate font-light group-aria-expanded/sidebar:block">{{ session?.user?.email || 'user@email.com' }}</span>
        </Button>
      </TooltipTrigger>
      <TooltipContent side="right" align="end" class="w-[230px] p-1" :disable-portal="true">
        <Button variant="ghost" @click="logOut" class="w-full justify-start p-2">
          <Power class="me-2 h-4 w-4" />
          Logout
        </Button>
      </TooltipContent>
    </Tooltip>
  </TooltipProvider>
</template>

<style scoped></style>
