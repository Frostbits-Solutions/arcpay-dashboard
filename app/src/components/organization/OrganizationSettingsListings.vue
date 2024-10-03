<script setup lang="ts">

import { useAccountsStore } from '@/stores/accounts'
import { Button } from '@/components/ui/button'
import { Clipboard } from '@/components/ui/clipboard'
import { Trash2 } from 'lucide-vue-next'
import { Skeleton } from '@/components/ui/skeleton'
import { deleteAccountApiKey, removeAccountAddress } from '@/lib/supabase/accounts'
import { h } from 'vue'
import ToastError from '@/components/ui/toast/ToastError.vue'
import ToastCheck from '@/components/ui/toast/ToastCheck.vue'
import { useToast } from '@/components/ui/toast'
import OrganizationLinkAddressDialog from '@/components/organization/OrganizationLinkAddressDialog.vue'
import { Badge } from '@/components/ui/badge'
import { Switch } from '@/components/ui/switch'
import { Form, FormControl, FormDescription, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form'
import { Input } from '@/components/ui/input'
import { toTypedSchema } from '@vee-validate/zod'
import * as z from 'zod'

const accounts = useAccountsStore()
const { toast } = useToast()
async function onDelete(address: string) {
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

const formSchema = toTypedSchema(z.object({
  fees: z.number().min(0).max(50)
}))
</script>

<template>
  <h2 class="text-2xl font-bold dark:text-white">Listings</h2>
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
        <thead class="text-xs text-muted-foreground/50 uppercase bg-muted/50">
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
              <Button variant="ghost" size="icon" class="size-7 rounded-sm" @click="onDelete(address.address)">
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
    <div class="border border-border bg-muted/50 rounded-lg p-4 mt-6">
      <div class="flex items-center justify-between">
        <div>
          <h4 class="text-md font-normal">Third party listings <Badge variant="gradient">PRO</Badge></h4>
          <p class="text-sm text-muted-foreground">
            Allow third party listings to be created by addresses that are not linked to your organization. Your organization collects fees on each third party listing sold.
          </p>
        </div>
        <Switch :default-checked="true" :disabled="true"/>
      </div>
      <Form id="listings-form" :validation-schema="formSchema" class="space-y-6 mt-6">
        <FormField v-slot="{ componentField }" name="fees">
          <FormItem>
            <FormLabel>Third party listings fees</FormLabel>
            <FormControl>
              <Input type="number" placeholder="1%" v-bind="componentField" disabled/>
            </FormControl>
            <FormDescription>
              Percentage fees collected on each third party listing sold. Must be between 0 and 100.
            </FormDescription>
            <FormMessage />
          </FormItem>
        </FormField>
        <div class="flex justify-end">
          <Button variant="outline"  type="submit" disabled>
            Save
          </Button>
        </div>
      </Form>
    </div>
  </div>
</template>

<style scoped>

</style>