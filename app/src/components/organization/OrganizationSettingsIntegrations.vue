<script setup lang="ts">

import { useAccountsStore } from '@/stores/accounts'
import { Button } from '@/components/ui/button'
import { ArrowUpRight, Trash2, Package } from 'lucide-vue-next'
import { deleteAccountApiKey, removeAccountUser } from '@/lib/supabase/accounts'
import { h } from 'vue'
import ToastError from '@/components/ui/toast/ToastError.vue'
import ToastCheck from '@/components/ui/toast/ToastCheck.vue'
import { useToast } from '@/components/ui/toast'
import { Skeleton } from '@/components/ui/skeleton'
import { Clipboard } from '@/components/ui/clipboard'
import OrganizationGenerateKeyDialog from '@/components/organization/OrganizationGenerateKeyDialog.vue'

const accounts = useAccountsStore()
const { toast } = useToast()

async function onDelete(key: string) {
  if (accounts.active?.id) {
    const {data, error} = await deleteAccountApiKey(accounts.active.id, key)
    if (error) {
      toast({
        title: `Error deleting API key`,
        description: error.message,
        variant: 'destructive',
        action: h(ToastError)
      });
    } else {
      await accounts.fetchAccountKeys(accounts.active.id)
      toast({
        title: `API key deleted`,
        action: h(ToastCheck)
      });
    }
  }
}
</script>

<template>
  <h2 class="text-2xl font-bold dark:text-white">Integrations</h2>
  <div class="relative mt-6">
    <div class="flex items-end justify-between pb-4 gap-10">
      <div>
        <h4 class="text-md font-normal">API Keys</h4>
        <p class="text-sm text-muted-foreground">API keys can be used for advanced integration to interact with our API. To prevent malicious use of your keys, you must specify the origin to allow for each key. HTTP requests that don't have a matching Origin header will be blocked.</p>
      </div>
      <OrganizationGenerateKeyDialog>
        <Button variant="outline">Generate new key</Button>
      </OrganizationGenerateKeyDialog>
    </div>
    <div class="rounded-lg border border-border overflow-hidden">
      <table class="w-full text-sm text-left rtl:text-right text-muted-foreground">
        <thead class="text-xs text-muted-foreground/50 uppercase bg-muted/50">
          <tr>
            <th scope="col" class="px-6 py-3">
              Key
            </th>
            <th scope="col" class="px-6 py-3">
              Allowed Origin
            </th>
            <th scope="col" class="px-6 py-3">
              Name
            </th>
            <th scope="col" class="w-16">
            </th>
          </tr>
        </thead>
        <tbody>
        <template v-if="!accounts.loading">
          <tr v-for="key in accounts.activeSettings.keys" :key="key.key" class="border-b last:border-b-0 border-border">
            <td class="px-6 py-4">
              <Clipboard :source="key.key" class="min-w-64"/>
            </td>
            <td class="px-6 py-4 truncate">
              {{ key.origin }}
            </td>
            <td class="px-6 py-4 truncate">
              {{ key.name }}
            </td>
            <td class="px-6 py-4">
              <Button variant="ghost" size="icon" class="size-7 rounded-sm" @click="onDelete(key.key)">
                <Trash2 class="size-4 text-destructive"/>
              </Button>
            </td>
          </tr>
          <tr v-if="!accounts.activeSettings.keys?.length">
            <td colspan="4" class="px-6 py-4 text-center text-sm text-muted-foreground">
              No API key
            </td>
          </tr>
        </template>
        <tr v-else>
          <td class="px-6 py-4">
            <Skeleton class="h-4 w-48"/>
          </td>
          <td class="px-6 py-4">
            <Skeleton class="h-4 w-48"/>
          </td>
          <td class="px-6 py-4">
            <Skeleton class="h-4 w-28"/>
          </td>
          <td class="px-6 py-4">
            <Skeleton class="h-5 w-8"/>
          </td>
        </tr>
        </tbody>
      </table>
    </div>
    <a href="https://www.npmjs.com/package/arcpay-sdk" target="_blank" class="border border-border rounded-lg h-16 flex items-center justify-start p-4 relative text-sm bg-muted/50 mt-6">
      <Package class="w-6 h-6 mr-4"/>
      Arcpay SDK npm package
      <ArrowUpRight class="w-4 h-4 text-border absolute top-2 right-2"/>
    </a>
  </div>
</template>

<style scoped>

</style>