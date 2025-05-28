<script setup lang="ts">
import {
  Dialog,
  DialogContent,
  DialogDescription, DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger
} from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { createAccountApiKey, createAccountJwtSecret, deleteAccountApiKey } from '@/lib/supabase/accounts'
import { toTypedSchema } from '@vee-validate/zod'
import * as z from 'zod'
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form'
import { Input } from '@/components/ui/input'
import { useAccountsStore } from '@/stores/accounts'
import { useToast } from '@/components/ui/toast'
import { h, ref } from 'vue'
import ToastCheck from '@/components/ui/toast/ToastCheck.vue'
import ToastError from '@/components/ui/toast/ToastError.vue'
import { JWT_SECRET, PUBLIC_ACCOUNT_KEY } from './utils'

// Define props
const props = defineProps({
  type: {
    type: String,
    required: true,
    validator: (value: string) => [PUBLIC_ACCOUNT_KEY, JWT_SECRET].includes(value),
  },
})

const accounts = useAccountsStore()
const { toast } = useToast()
const open = ref(false)
const showWarning = ref(false)

function openDialog() {
  if (
    props.type === PUBLIC_ACCOUNT_KEY &&
    Array.isArray(accounts.activeSettings.keys) &&
    accounts.activeSettings.keys.length > 0
  ) {
    showWarning.value = true
  } else {
    open.value = true
  }
}

function handleOpenChange(val: boolean) {
  open.value = val
}

function confirmWarning() {
  showWarning.value = false
  open.value = true
}
function cancelWarning() {
  showWarning.value = false
}

// Form schema includes both name for all types
const formSchema = toTypedSchema(z.object({
  name: z.string().min(4).max(50),
}))

async function onSubmit(values: any) {
  if (accounts.active?.id) {
    let response
    if (props.type === PUBLIC_ACCOUNT_KEY) {
      // If a key exists, delete the first one before creating a new one
      if (Array.isArray(accounts.activeSettings.keys) && accounts.activeSettings.keys.length > 0) {
        const existingKey = accounts.activeSettings.keys[0]
        await deleteAccountApiKey(accounts.active.id, existingKey.key)
      }
      response = await createAccountApiKey(accounts.active.id, values.name)
    } else if (props.type === JWT_SECRET) {
      response = await createAccountJwtSecret(accounts.active.id, values.name)
    }
    if (response && 'data' in response && 'error' in response) {
      const { data, error } = response
      if (error) {
        toast({
          title: `Error generating new ${props.type === PUBLIC_ACCOUNT_KEY ? 'API key' : 'JWT secret'}`,
          description: error.message,
          variant: 'destructive',
          action: h(ToastError)
        });
      } else {
        toast({
          title: `New ${props.type === PUBLIC_ACCOUNT_KEY ? 'API key' : 'JWT secret'} generated`,
          description: `You can use this ${props.type === PUBLIC_ACCOUNT_KEY ? 'key' : 'secret'} to authenticate`,
          action: h(ToastCheck)
        });
        if (props.type === PUBLIC_ACCOUNT_KEY) {
          await accounts.fetchAccountKeys(accounts.active.id)
        } else {
          await accounts.fetchAccountSecrets(accounts.active.id)
        }
        open.value = false
      }
    }
  }
}
</script>

<template>
  <!-- Warning Dialog for PUBLIC_ACCOUNT_KEY -->
  <Dialog v-model:open="showWarning">
    <DialogContent>
      <DialogHeader>
        <DialogTitle>Warning: Replace Primary API Key</DialogTitle>
        <DialogDescription>
          Generating a new API key will erase your current primary API key.<br>
          <b>You must update all systems and integrations to use the new key.</b><br>
          Are you sure you want to continue?
        </DialogDescription>
      </DialogHeader>
      <DialogFooter>
        <Button variant="destructive" @click="confirmWarning">Yes, continue</Button>
        <Button variant="outline" @click="cancelWarning">Cancel</Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
  <Dialog v-model:open="open" @update:open="handleOpenChange">
    <template v-if="type === PUBLIC_ACCOUNT_KEY">
      <div @click="openDialog">
        <slot/>
      </div>
    </template>
    <template v-else>
      <DialogTrigger as-child>
        <slot/>
      </DialogTrigger>
    </template>
    <DialogContent>
      <DialogHeader>
        <DialogTitle>New {{ type === PUBLIC_ACCOUNT_KEY ? 'API key' : 'JWT secret' }}</DialogTitle>
        <DialogDescription>
          Generate a new {{ type === PUBLIC_ACCOUNT_KEY ? 'key' : 'secret' }} to authenticate and communicate with the API. 
        </DialogDescription>
      </DialogHeader>
      <div class="py-4">
        <Form id="add-user-form" :validation-schema="formSchema" @submit="onSubmit" class="space-y-6">
          <FormField v-slot="{ componentField }" name="name">
            <FormItem class="flex-1">
              <FormLabel>{{ type === PUBLIC_ACCOUNT_KEY ? 'Key name' : 'Secret name' }}</FormLabel>
              <FormControl>
                <Input type="text" placeholder="name" v-bind="componentField" />
              </FormControl>
              <FormMessage />
            </FormItem>
          </FormField>
        </Form>
      </div>
      <DialogFooter>
        <Button type="submit" form="add-user-form" variant="gradient">
          Generate {{ type === PUBLIC_ACCOUNT_KEY ? 'key' : 'secret' }}
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>

<style scoped>

</style>