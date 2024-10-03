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
import { createAccountApiKey } from '@/lib/supabase/accounts'
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

const accounts = useAccountsStore()
const {toast} = useToast()
const open = ref(false)

const formSchema = toTypedSchema(z.object({
  name: z.string().min(4).max(50),
  origin: z.string().url(),
}))

async function onSubmit(values: any) {
  if (accounts.active?.id) {
    const {data, error} =  await createAccountApiKey(accounts.active.id, values.origin, values.name)
    if (error) {
      toast({
        title: `Error generating new key`,
        description: error.message,
        variant: 'destructive',
        action: h(ToastError)
      });
    } else {
      toast({
        title: `New API key generated`,
        description: `You can use this key to authenticate with the API`,
        action: h(ToastCheck)
      });
      await accounts.fetchAccountKeys(accounts.active.id)
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
        <DialogTitle>New API key</DialogTitle>
        <DialogDescription>
          Generate a new key to authenticate with the API. Origin must match the domain of the requests.
        </DialogDescription>
      </DialogHeader>
      <div class="py-4">
        <Form id="add-user-form" :validation-schema="formSchema" @submit="onSubmit" class="space-y-6">
          <FormField v-slot="{ componentField }" name="name">
            <FormItem class="flex-1">
              <FormLabel>Key name</FormLabel>
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
          Generate key
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>

<style scoped>

</style>