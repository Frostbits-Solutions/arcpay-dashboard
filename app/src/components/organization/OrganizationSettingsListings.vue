<script setup lang="ts">

import { useAccountsStore } from '@/stores/accounts'
import { Button } from '@/components/ui/button'
import { Clipboard } from '@/components/ui/clipboard'
import { Trash2 } from 'lucide-vue-next'
import { Skeleton } from '@/components/ui/skeleton'
import { deleteAccountApiKey, removeAccountAddress } from '@/lib/supabase/accounts'
import { h, ref } from 'vue'
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
import { onMounted } from 'vue'

const accounts = useAccountsStore()
const hasProSubscription = ref(accounts.activeSettings.subscription.allow_secondary_listings)
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


onMounted(() => {
  console.log(hasProSubscription.value)
})

const formSchema = toTypedSchema(z.object({
  fees: z.number().min(0).max(50),
  blockchainAddress: z.string().regex(/^0x[a-fA-F0-9]{40}$/, "Invalid chain address") // Regex for Ethereum-like addresses
}))
</script>

<template>
  <div>
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
        <Switch :v-bind="hasProSubscription" :disabled="true"/>
      </div>
      <Form v-if="hasProSubscription" id="listings-form" :validation-schema="formSchema" class="space-y-6 mt-6">
        <FormField v-slot="{ componentField }" name="fees">
          <FormItem>
            <div class="flex items-center justify-between">
              <div>
              <FormLabel>Enable secondary listing</FormLabel>
              <FormDescription>
                Allow fees on secondary listings for this chain.
              </FormDescription>
              </div>
              <FormControl>
              <Switch />
              </FormControl>
            </div>
          </FormItem>
          <FormField v-slot="{ field, errors }" name="blockchainAddress">
          <FormItem>
            <div class="flex items-center justify-between">
              <div>
                <FormLabel>Secondary fee address</FormLabel>
          
                <FormDescription>
                  Address that will receive the fees from secondary listings.
                </FormDescription>
                <FormMessage v-if="errors" class="text-xs mt-2">{{ errors }}</FormMessage>

              </div>
              <FormControl>
                <Input v-bind="field" placeholder="Enter chain address" class="w-1/2 truncate" />
              </FormControl>
            </div>
          </FormItem>
        </FormField>
          <FormField v-slot="{ field, errors }" name="fees">
            <FormItem>
              <div class="flex items-center justify-between">
                <div>
                  <FormLabel>Fee Percentage</FormLabel>
                  <FormDescription>
                    Enter the percentage fee (0.00% to 50.00%).
                  </FormDescription>
                  <FormMessage v-if="errors" class="text-xs mt-2">{{ errors }}</FormMessage>
                </div>
                <FormControl>
                    <div class="flex items-center">
                    <Input v-bind="field" type="number" placeholder="X.XX" min="0" max="50" class="w-1/8" />
                    <span class="ml-2 text-muted-foreground">%</span>
                    </div>
                </FormControl>
              </div>
            </FormItem>
          </FormField>
        </FormField>
        <div class="flex justify-end">
          <Button variant="outline"  type="submit" disabled>
            Save
          </Button>
        </div>
      </Form>
      <div>
        <p class="text-sm text-muted-foreground pt-8">
          This feature is available exclusively for PRO subscribers. Upgrade to PRO to enable third party listings and collect fees on each sale.
        </p>
      </div>
    </div>
  </div>
</div>
</template>

<style scoped>

</style>