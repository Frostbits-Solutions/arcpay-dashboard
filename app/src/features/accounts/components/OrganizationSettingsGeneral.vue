<script setup lang="ts">
import { Form, FormControl, FormDescription, FormField, FormItem, FormLabel, FormMessage } from '@/lib/ui/form'
import { Input } from '@/lib/ui/input'
import { toTypedSchema } from '@vee-validate/zod'
import * as z from 'zod'
import { useAccountsStore } from '@/features/accounts/stores/accounts'
import { Button } from '@/lib/ui/button'
import { deleteAccount, updateAccount } from '@/services/accounts'
import { h, computed } from 'vue'
import ToastCheck from '@/lib/ui/toast/ToastCheck.vue'
import { useToast } from '@/lib/ui/toast'
import ToastError from '@/lib/ui/toast/ToastError.vue'
import { Users, ArrowUpRight, Key, Package } from 'lucide-vue-next'
import { Clipboard } from '@/lib/ui/clipboard'
import OrganizationSettingsListingsAddress from '@/features/accounts/components/OrganizationSettingsAddress.vue'

const { toast } = useToast()
const accounts = useAccountsStore()
const formSchema = toTypedSchema(
  z.object({
    name: z.string().min(4).max(50).optional(),
    website: z.string().url().optional(),
  })
)

const quickLinks = [
  { name: 'Get started with Arcpay SDK', icon: Package, to: { name: 'organization-organization-listings' } },
  { name: 'Invite new team members', icon: Users, to: { name: 'organization-organization-users' } },
  { name: 'Manage account security', icon: Key, to: { name: 'organization-organization-security' } },
  // {name: 'Billing and subscription', icon: Receipt, to: {name: 'organization-organization-general'}},
]

const isPro = computed(() => accounts.activeSettings.subscription_tiers?.name === 'pro')

async function onSubmit(values: any) {
  if (accounts.active?.id) {
    const { data, error } = await updateAccount(accounts.active.id, { name: values?.name })
    if (error) {
      toast({
        title: `Error updating organization`,
        description: error.message,
        variant: 'destructive',
        action: h(ToastError),
      })
    } else {
      accounts.active.name = values?.name || accounts.active.name
      await accounts.fetchAccountSettings(accounts.active.id)
      toast({
        title: `Organization updated`,
        action: h(ToastCheck),
      })
    }
  }
}

async function onDelete(values: any) {
  if (accounts.active?.id) {
    const { data, error } = await deleteAccount(accounts.active.id)
    if (error) {
      toast({
        title: `Error deleting organization`,
        description: error.message,
        variant: 'destructive',
        action: h(ToastError),
      })
    } else {
      await accounts.fetchAll()
      accounts.selectAccount(accounts.all[0]?.id)
      toast({
        title: `Organization deleted`,
        action: h(ToastCheck),
      })
    }
  }
}
</script>

<template>
  <h2 class="text-2xl font-bold dark:text-white">{{ accounts.active?.name }}</h2>
  <ul class="my-10 grid grid-cols-6 gap-4">
    <li v-for="(link, index) in quickLinks" :key="index">
      <router-link :to="link.to" class="relative flex h-24 items-center justify-center rounded-lg border border-border p-4 text-sm">
        <component :is="link.icon" class="mr-4 h-8 w-8" />
        {{ link.name }}
        <ArrowUpRight class="absolute right-2 top-2 h-4 w-4 text-border" />
      </router-link>
    </li>
  </ul>
  <div :class="['mb-2 mt-10 rounded-lg p-2 p-[1px]', isPro ? 'bg-gradient' : 'bg-border']">
    <div class="flex items-center justify-between rounded-lg bg-background p-4">
      <div>
        <h4 class="text-md font-normal">Subscription</h4>
        <p class="text-sm text-muted-foreground">
          This organization is currently on the
          <span :class="['font-bold uppercase', isPro ? 'bg-gradient bg-clip-text text-transparent' : 'text-primary']">{{ accounts.activeSettings.subscription_tiers?.name }}</span> plan.<br />
        </p>
      </div>
      <Button variant="gradient" class="mt-2" v-if="isPro">Manage</Button>
      <Button variant="gradient" class="mt-2" v-else>Upgrade to Pro</Button>
    </div>
  </div>
  <div class="rounded-lg border border-border p-4">
    <Form id="general-form" :validation-schema="formSchema" @submit="onSubmit" class="space-y-6">
      <FormField name="id">
        <FormItem>
          <FormLabel>Organization ID</FormLabel>
          <FormControl>
            <div><Clipboard :source="accounts.active?.id.toString() || ''" class="text-xs" /></div>
          </FormControl>
          <FormDescription> This is your organization ID. It is used to identify your organization when using the Arcpay SDK or the Arcpay API.</FormDescription>
          <FormMessage />
        </FormItem>
      </FormField>
      <FormField v-slot="{ componentField }" name="name">
        <FormItem>
          <FormLabel>Organization name</FormLabel>
          <FormControl>
            <Input type="text" :placeholder="accounts?.active?.name" v-bind="componentField" />
          </FormControl>
          <FormDescription> Organization name must be unique and between 4 and 50 characters. Leave empty to keep the current name. </FormDescription>
          <FormMessage />
        </FormItem>
      </FormField>
      <div class="flex justify-end">
        <Button variant="outline" type="submit"> Save </Button>
      </div>
    </Form>
  </div>
  <OrganizationSettingsListingsAddress />
  <div class="mt-10 flex items-center justify-between rounded-lg border border-destructive bg-destructive/20 p-4">
    <div>
      <h4 class="text-md font-normal text-destructive">Delete organization</h4>
      <p class="text-sm text-destructive">This action cannot be undone. This will permanently delete your organization and all its data.</p>
    </div>
    <Button variant="destructive" class="mt-2" @click="onDelete">Delete organization</Button>
  </div>
</template>

<style scoped></style>
