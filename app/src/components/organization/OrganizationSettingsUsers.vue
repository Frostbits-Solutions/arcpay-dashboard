<script setup lang="ts">
import { Search, House, Trash2 } from 'lucide-vue-next'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import { useAccountsStore } from '@/stores/accounts'
import { computed, h, ref } from 'vue'
import { Skeleton } from '@/components/ui/skeleton'
import ToastError from '@/components/ui/toast/ToastError.vue'
import ToastCheck from '@/components/ui/toast/ToastCheck.vue'
import { removeAccountUser } from '@/lib/supabase/accounts'
import { useToast } from '@/components/ui/toast'
import OrganizationAddUsersDialog from '@/components/organization/OrganizationAddUsersDialog.vue'

const {toast} = useToast()
const accounts = useAccountsStore()
const searchTerm = ref<string>('')
const filteredUsers = computed(() => {
  return accounts.activeSettings?.users?.filter(user => user.user_email.includes(searchTerm.value))
})

async function onDelete(email: string) {
  if (accounts.active?.id) {
    const {data, error} = await removeAccountUser(accounts.active.id, email)
    if (error) {
      toast({
        title: `Error removing team member`,
        description: error.message,
        variant: 'destructive',
        action: h(ToastError)
      });
    } else {
      await accounts.fetchAccountUsers(accounts.active.id)
      toast({
        title: `Team member removed`,
        action: h(ToastCheck)
      });
    }
  }
}
</script>

<template>
  <h2 class="text-2xl font-bold dark:text-white">Users</h2>
  <p class="text-sm text-muted-foreground">Users can login to the organization's account to create and manage listings. Only owner and admins can change the organization settings.</p>
  <div class="relative mt-10">
    <div class="flex items-center justify-between mb-6">
      <div class="relative w-full max-w-sm items-center">
        <Input id="search" type="text" placeholder="Search..." class="pl-10" v-model:model-value="searchTerm"/>
        <span class="absolute start-0 inset-y-0 flex items-center justify-center px-2">
          <Search class="size-5 text-muted-foreground" />
        </span>
      </div>
      <OrganizationAddUsersDialog>
        <Button variant="outline">Invite member</Button>
      </OrganizationAddUsersDialog>
    </div>
    <div v-if="accounts.activeSettings?.settings" class="border border-border bg-muted/50 rounded-lg p-4 flex items-center justify-between my-4">
      <div>
        <p class="text-sm text-muted-foreground">
          <House class="size-5 inline-block mr-2"/> Owner: <span class="text-foreground font-medium">{{accounts.activeSettings.settings.owner_email}}</span>
        </p>
      </div>
    </div>
    <Skeleton v-else class="h-14 my-4"/>
    <div class="rounded-lg border border-border overflow-hidden">
      <table class="w-full text-sm text-left rtl:text-right text-muted-foreground">
        <thead class="text-xs text-muted-foreground/50 uppercase bg-muted/50">
        <tr>
          <th scope="col" class="px-6 py-3">
            Email
          </th>
          <th scope="col" class="px-6 py-3 w-12">
            Role
          </th>
          <th class="w-9"></th>
        </tr>
        </thead>
        <tbody>
        <template v-if="!accounts.loading">
          <tr v-for="user in filteredUsers" :key="user.user_email" class="border-b last:border-b-0 border-border">
            <td class="px-6 py-4">
              {{ user.user_email }}
            </td>
            <td class="px-6 py-4">
              <span v-if="user.role === 'admin'" class="bg-yellow-100 text-yellow-800 text-xs font-medium me-2 px-2.5 py-0.5 rounded-full dark:bg-yellow-900 dark:text-yellow-300">Admin</span>
              <span v-if="user.role === 'member'" class="bg-green-100 text-green-800 text-xs font-medium me-2 px-2.5 py-0.5 rounded-full dark:bg-green-900 dark:text-green-300">Member</span>
            </td>
            <td class="px-6 py-4">
              <Button variant="ghost" size="icon" class="size-7 rounded-sm" @click="onDelete(user.user_email)">
                <Trash2 class="size-4 text-destructive"/>
              </Button>
            </td>
          </tr>
          <tr v-if="!filteredUsers?.length">
            <td class="px-6 py-4 col-span-2">
              No results
            </td>
          </tr>
        </template>
        <tr v-else>
          <td class="px-6 py-4">
            <Skeleton class="w-48 h-4"/>
          </td>
          <td class="px-6 py-4">
            <Skeleton class="w-16 h-5"/>
          </td>
        </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<style scoped>

</style>