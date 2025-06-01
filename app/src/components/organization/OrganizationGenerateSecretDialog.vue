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
import { createAccountJwtSecret } from '@/lib/supabase/accounts'
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
const { toast } = useToast()
const open = ref(false)

function handleOpenChange(val: boolean) {
  open.value = val
}

// Form schema includes only name for JWT secret
const formSchema = toTypedSchema(z.object({
  name: z.string().min(4).max(50),
}))

async function onSubmit(values: any) {
  if (accounts.active?.id) {
    const response = await createAccountJwtSecret(accounts.active.id, values.name)
    if (response && 'data' in response && 'error' in response) {
      const { data, error } = response
      if (error) {
        toast({
          title: `Error generating new JWT secret`,
          description: error.message,
          variant: 'destructive',
          action: h(ToastError)
        });
      } else {
        toast({
          title: `New JWT secret generated`,
          description: `You can use this secret to authenticate`,
          action: h(ToastCheck)
        });
        await accounts.fetchAccountSecrets(accounts.active.id)
        open.value = false
      }
    }
  }
}
</script>

<template>
  <Dialog v-model:open="open" @update:open="handleOpenChange">
    <DialogTrigger as-child>
      <slot/>
    </DialogTrigger>
    <DialogContent>
      <DialogHeader>
        <DialogTitle>New JWT secret</DialogTitle>
        <DialogDescription>
          Generate a new secret to authenticate and communicate with the API. 
        </DialogDescription>
      </DialogHeader>
      <div class="py-4">
        <Form id="add-user-form" :validation-schema="formSchema" @submit="onSubmit" class="space-y-6">
          <FormField v-slot="{ componentField }" name="name">
            <FormItem class="flex-1">
              <FormLabel>Secret name</FormLabel>
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
          Generate secret
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>

<style scoped>

</style>