<script setup lang="ts">
import { useAccountsStore } from '@/features/accounts/stores/accounts'
import { Button } from '@/lib/ui/button'
import { Clipboard } from '@/lib/ui/clipboard'
import { Trash2 } from 'lucide-vue-next'
import { Skeleton } from '@/lib/ui/skeleton'
import { 
  removeAccountAddress
} from '@/features/accounts/services/accounts'
import { h } from 'vue'
import ToastError from '@/lib/ui/toast/ToastError.vue'
import ToastCheck from '@/lib/ui/toast/ToastCheck.vue'
import { useToast } from '@/lib/ui/toast'
import OrganizationLinkAddressDialog from '@/features/accounts/components/OrganizationLinkAddressDialog.vue'

const accounts = useAccountsStore()
const { toast } = useToast()

async function onDeleteAccountAddress(address: string) {
  if (accounts.active?.id) {
    const {data, error} = await removeAccountAddress(accounts.active.id, address)
    if (error) {
      toast({
        title: `Error removing address`,
        description: error.message,
        variant: 'destructive',
        action: h(ToastError)
      });
    } else {
      await accounts.fetchAccountAddresses(accounts.active.id)
      toast({
        title: `Address removed`,
        action: h(ToastCheck)
      });
    }
  }
}
</script>

<template>
  <div class="relative mt-6">
    <div class="flex items-center justify-between pb-4">
      <div>
        <h4 class="text-md font-normal">Organization addresses</h4>
        <p class="text-sm text-muted-foreground">Link accounts to your organization to new create listings. Listing created by addresses that are not linked to your organization are considered third party listings.</p>
      </div>
      <OrganizationLinkAddressDialog>
        <Button variant="outline">Link address</Button>
      </OrganizationLinkAddressDialog>
    </div>
    <div class="rounded-lg border border-border overflow-hidden">
      <table class="w-full text-sm text-left rtl:text-right text-muted-foreground">
        <thead class="text-xs text-muted-foreground/50 border-b">
        <tr>
          <th scope="col" class="px-6 py-3 w-[512px]">
            Address
          </th>
          <th scope="col" class="px-6 py-3">
            Name
          </th>
          <th scope="col" class="px-6 py-3 w-16"></th>
        </tr>
        </thead>
        <tbody>
        <template v-if="!accounts.loading">
          <tr v-for="address in accounts.activeSettings.addresses" :key="address.address" class="border-b last:border-b-0 border-border">
            <td class="px-6 py-4">
              <Clipboard :source="address.address" class="text-xs"/>
            </td>
            <td class="px-6 py-4 truncate">
              {{ address.name }}
            </td>
            <td class="px-6 py-4">
              <Button variant="ghost" size="icon" class="size-7 rounded-sm" @click="onDeleteAccountAddress(address.address)">
                <Trash2 class="size-4 text-destructive"/>
              </Button>
            </td>
          </tr>
          <tr v-if="!accounts.activeSettings.addresses?.length">
            <td colspan="4" class="px-6 py-4 text-center text-sm text-muted-foreground">
              No addresses linked
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
  </div>
</template>

<style scoped>

</style>