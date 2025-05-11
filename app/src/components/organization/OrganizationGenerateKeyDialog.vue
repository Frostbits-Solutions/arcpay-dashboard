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
import { createAccountApiKey, createAccountJwtSecret } from '@/lib/supabase/accounts'
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
import { JWT_SECRET, API_KEY } from './utils'

// Define props
const props = defineProps({
  type: {
    type: String,
    required: true,
    validator: (value: string) => [API_KEY, JWT_SECRET].includes(value),
  },
})

const accounts = useAccountsStore()
const { toast } = useToast()
const open = ref(false)

// Form schema includes both name and origin for all types
const formSchema = toTypedSchema(z.object({
  name: z.string().min(4).max(50),
  origin: z.string().url(),
}))

async function onSubmit(values: any) {
  if (accounts.active?.id) {
    let response
    if (props.type === API_KEY) {
      response = await createAccountApiKey(accounts.active.id, values.origin, values.name)
    } else if (props.type === JWT_SECRET) {
      response = await createAccountJwtSecret(accounts.active.id, values.origin, values.name)
    }

    const { data, error } = response
    if (error) {
      toast({
        title: `Error generating new ${props.type === API_KEY ? 'API key' : 'JWT secret'}`,
        description: error.message,
        variant: 'destructive',
        action: h(ToastError)
      });
    } else {
      toast({
        title: `New ${props.type === API_KEY ? 'API key' : 'JWT secret'} generated`,
        description: `You can use this ${props.type === API_KEY ? 'key' : 'secret'} to authenticate`,
        action: h(ToastCheck)
      });
      if (props.type === API_KEY) {
        await accounts.fetchAccountKeys(accounts.active.id)
      } else {
        await accounts.fetchAccountSecrets(accounts.active.id)
      }
      open.value = false
    }
  }
}
</script>

<template>
  <Dialog v-model:open="open">
    <DialogTrigger as-child>
      <slot/>
    </DialogTrigger>
    <DialogContent>
      <DialogHeader>
        <DialogTitle>New {{ type === API_KEY ? 'API key' : 'JWT secret' }}</DialogTitle>
        <DialogDescription>
          Generate a new {{ type === API_KEY ? 'key' : 'secret' }} to authenticate and communicate with the API. 
          Origin must match the domain of the requests.
        </DialogDescription>
      </DialogHeader>
      <div class="py-4">
        <Form id="add-user-form" :validation-schema="formSchema" @submit="onSubmit" class="space-y-6">
          <FormField v-slot="{ componentField }" name="name">
            <FormItem class="flex-1">
              <FormLabel>{{ type === API_KEY ? 'Key name' : 'Secret name' }}</FormLabel>
              <FormControl>
                <Input type="text" placeholder="name" v-bind="componentField" />
              </FormControl>
              <FormMessage />
            </FormItem>
          </FormField>
          <FormField v-slot="{ componentField }" name="origin">
            <FormItem class="flex-1">
              <FormLabel>Allowed origin</FormLabel>
              <FormControl>
                <Input type="url" placeholder="origin" v-bind="componentField" />
              </FormControl>
              <FormMessage />
            </FormItem>
          </FormField>
        </Form>
      </div>
      <DialogFooter>
        <Button type="submit" form="add-user-form" variant="gradient">
          Generate {{ type === API_KEY ? 'key' : 'secret' }}
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>

<style scoped>

</style>