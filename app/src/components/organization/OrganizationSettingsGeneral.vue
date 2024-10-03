<script setup lang="ts">
import SettingsCard from '@/components/organization/SettingsCard.vue'
import { Form, FormControl, FormDescription, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form'
import { Input } from '@/components/ui/input'
import { toTypedSchema } from '@vee-validate/zod'
import * as z from 'zod'
import { useAccountsStore } from '@/stores/accounts'
import { Button } from '@/components/ui/button'
import { deleteAccount, updateAccount } from '@/lib/supabase/accounts'
import { h } from 'vue'
import ToastCheck from '@/components/ui/toast/ToastCheck.vue'
import { useToast } from '@/components/ui/toast'
import ToastError from '@/components/ui/toast/ToastError.vue'
import { Skeleton } from '@/components/ui/skeleton'
import { Users, ArrowUpRight, Key, WalletMinimal, Receipt } from 'lucide-vue-next'

const {toast} = useToast()
const accounts = useAccountsStore()
const formSchema = toTypedSchema(z.object({
  name: z.string().min(4).max(50).optional(),
  website: z.string().url().optional(),
}))

const quickLinks = [
  {name: 'Invite new team members', icon: Users, to: {name: 'organization-organization-users'}},
  {name: 'Generate new API key', icon: Key, to: {name: 'organization-organization-integrations'}},
  {name: 'Link address to organization', icon: WalletMinimal, to: {name: 'organization-organization-listings'}},
  // {name: 'Billing and subscription', icon: Receipt, to: {name: 'organization-organization-general'}},
]

async function onSubmit(values: any) {
  if (accounts.active?.id) {
    const {data, error} = await updateAccount(accounts.active.id, values?.name, values?.website)
    if (error) {
      toast({
        title: `Error updating organization`,
        description: error.message,
        variant: 'destructive',
        action: h(ToastError)
      });
    } else {
      toast({
        title: `Organization updated`,
        action: h(ToastCheck)
      });
    }
  }
}

async function onDelete(values: any) {
  if (accounts.active?.id) {
    const {data, error} = await deleteAccount(accounts.active.id)
    if (error) {
      toast({
        title: `Error deleting organization`,
        description: error.message,
        variant: 'destructive',
        action: h(ToastError)
      });
    } else {
      await accounts.fetchAll()
      accounts.selectAccount(accounts.all[0]?.id)
      toast({
        title: `Organization deleted`,
        action: h(ToastCheck)
      });
    }
  }
}
</script>

<template>
  <h2 class="text-2xl font-bold dark:text-white">General</h2>
  <ul class="grid grid-cols-6 gap-4 my-10">
    <li v-for="(link, index) in quickLinks" :key="index">
      <router-link :to="link.to" class="border border-border rounded-lg h-24 flex items-center justify-center p-4 relative text-sm">
        <component :is="link.icon" class="w-8 h-8 mr-4"/>
        {{ link.name }}
        <ArrowUpRight class="w-4 h-4 text-border absolute top-2 right-2"/>
      </router-link>
    </li>
  </ul>
  <div class="border border-border bg-muted/50 rounded-lg p-4 flex items-center justify-between mt-10 mb-4">
    <div>
      <h4 class="text-md font-normal">Subscription</h4>
      <p class="text-sm text-muted-foreground">
        This organization is currently on the <span class="uppercase font-bold text-primary">{{accounts.activeSettings.subscription?.name}}</span> plan.<br>
      </p>
    </div>
    <Button variant="gradient" class="mt-2">Upgrade to Pro</Button>
  </div>
  <SettingsCard>
    <Form id="general-form" :validation-schema="formSchema" @submit="onSubmit" class="space-y-6">
      <FormField v-slot="{ componentField }" name="name">
        <FormItem>
          <FormLabel>Organization name</FormLabel>
          <FormControl>
            <Input type="text" :placeholder="accounts?.active?.name" v-bind="componentField" />
          </FormControl>
          <FormDescription>
            Organization name must be unique and between 4 and 50 characters. Leave empty to keep the current name.
          </FormDescription>
          <FormMessage />
        </FormItem>
      </FormField>
      <FormField v-slot="{ componentField }" name="website">
        <FormItem>
          <FormLabel>Website</FormLabel>
          <FormControl>
            <Skeleton class="w-full h-9" v-if="accounts?.loading"/>
            <Input v-else type="text" :placeholder="accounts?.activeSettings?.settings?.website" v-bind="componentField" />
          </FormControl>
          <FormDescription>
            Optional, social media or website URL.
          </FormDescription>
          <FormMessage />
        </FormItem>
      </FormField>
      <div class="flex justify-end">
        <Button variant="outline"  type="submit">
          Save
        </Button>
      </div>
    </Form>
  </SettingsCard>
  <div class="border border-destructive bg-destructive/20 rounded-lg p-4 flex items-center justify-between mt-10">
    <div>
      <h4 class="text-md font-normal text-destructive">Delete organization</h4>
      <p class="text-sm text-destructive">This action cannot be undone. This will permanently delete your organization and all its data.</p>
    </div>
    <Button variant="destructive" class="mt-2" @click="onDelete">Delete organization</Button>
  </div>
</template>

<style scoped>
</style>