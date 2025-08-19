<script setup lang="ts">
import { Search, House, Trash2 } from 'lucide-vue-next'
import { Input } from '@/lib/ui/input'
import { Button } from '@/lib/ui/button'
import { useAccountsStore } from '@/features/accounts/stores/accounts'
import { computed, h, ref } from 'vue'
import { Skeleton } from '@/lib/ui/skeleton'
import ToastError from '@/lib/ui/toast/ToastError.vue'
import ToastCheck from '@/lib/ui/toast/ToastCheck.vue'
import { removeAccountUser } from '@/services/accounts'
import { useToast } from '@/lib/ui/toast'
import OrganizationAddUsersDialog from '@/features/accounts/components/OrganizationAddUsersDialog.vue'
import type { Tables } from '@/lib/supabase/database.types'

const { toast } = useToast()
const accounts = useAccountsStore()
const searchTerm = ref<string>('')

const filteredUsers = computed(() => {
  type User = Omit<Tables<'accounts_users_association'>, 'account_id'>
  const roleValue = { owner: 1, admin: 2, member: 3 }
  return accounts.activeSettings?.users?.filter((user) => user.user_email.includes(searchTerm.value)).sort((a: User, b: User) => roleValue[a.role] - roleValue[b.role]) || []
})

async function onDelete(email: string) {
  if (accounts.active?.id) {
    const { data, error } = await removeAccountUser(accounts.active.id, email)
    if (error) {
      toast({
        title: `Error removing team member`,
        description: error.message,
        variant: 'destructive',
        action: h(ToastError),
      })
    } else {
      await accounts.fetchAccountUsers(accounts.active.id)
      toast({
        title: `Team member removed`,
        action: h(ToastCheck),
      })
    }
  }
}
</script>

<template>
  <h2 class="text-2xl font-bold dark:text-white">Users</h2>
  <p class="text-sm text-muted-foreground">Users can login to the organization's account to create and manage listings. Only owner and admins can change the organization settings.</p>
  <div class="relative mt-10">
    <div class="mb-6 flex items-center justify-between">
      <div class="relative w-full max-w-sm items-center">
        <Input id="search" type="text" placeholder="Search..." class="pl-10" v-model:model-value="searchTerm" />
        <span class="absolute inset-y-0 start-0 flex items-center justify-center px-2">
          <Search class="size-5 text-muted-foreground" />
        </span>
      </div>
      <OrganizationAddUsersDialog>
        <Button variant="outline">Invite member</Button>
      </OrganizationAddUsersDialog>
    </div>
    <div class="overflow-hidden rounded-lg border border-border">
      <table class="w-full text-left text-sm text-muted-foreground rtl:text-right">
        <thead class="border-b text-xs text-muted-foreground/50">
          <tr>
            <th scope="col" class="px-6 py-3">Email</th>
            <th scope="col" class="w-12 px-6 py-3">Role</th>
            <th class="w-9"></th>
          </tr>
        </thead>
        <tbody>
          <template v-if="!accounts.loading">
            <tr v-for="user in filteredUsers" :key="user.user_email" class="border-b border-border last:border-b-0">
              <td class="px-6 py-4">
                {{ user.user_email }}
              </td>
              <td class="px-6 py-4">
                <span v-if="user.role === 'owner'" class="me-2 rounded-full bg-red-100 px-2.5 py-0.5 text-xs font-medium text-red-600 dark:bg-red-900 dark:text-red-300">Owner</span>
                <span v-if="user.role === 'admin'" class="me-2 rounded-full bg-yellow-100 px-2.5 py-0.5 text-xs font-medium text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300">Admin</span>
                <span v-if="user.role === 'member'" class="me-2 rounded-full bg-green-100 px-2.5 py-0.5 text-xs font-medium text-green-800 dark:bg-green-900 dark:text-green-300">Member</span>
              </td>
              <td class="px-6 py-4">
                <Button variant="ghost" size="icon" class="size-7 rounded-sm" @click="onDelete(user.user_email)">
                  <Trash2 class="size-4 text-destructive" />
                </Button>
              </td>
            </tr>
            <tr v-if="!filteredUsers?.length">
              <td class="col-span-2 px-6 py-4">No results</td>
            </tr>
          </template>
          <tr v-else>
            <td class="px-6 py-4">
              <Skeleton class="h-4 w-48" />
            </td>
            <td class="px-6 py-4">
              <Skeleton class="h-5 w-16" />
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<style scoped></style>
