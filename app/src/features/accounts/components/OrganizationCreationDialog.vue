<script setup lang="ts">
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from '@/lib/ui/dialog'
import { Button } from '@/lib/ui/button'
import { useSessionStore } from '@/features/auth/stores/session'
import { createAccount } from '@/services/accounts'
import { toTypedSchema } from '@vee-validate/zod'
import * as z from 'zod'
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from '@/lib/ui/form'
import { Input } from '@/lib/ui/input'
import { useAccountsStore } from '@/features/accounts/stores/accounts'
import { useToast } from '@/lib/ui/toast'
import { h, ref } from 'vue'
import ToastCheck from '@/lib/ui/toast/ToastCheck.vue'
import ToastError from '@/lib/ui/toast/ToastError.vue'

const accounts = useAccountsStore()
const { toast } = useToast()
const open = ref(false)

const formSchema = toTypedSchema(
  z.object({
    name: z.string().min(4).max(50),
  })
)

async function onSubmit(values: any) {
  const session = useSessionStore()
  if (session?.user?.email) {
    const { data, error } = await createAccount(values.name)
    if (error) {
      toast({
        title: `Error creating organization`,
        description: error.message,
        variant: 'destructive',
        action: h(ToastError),
      })
    } else {
      toast({
        title: `Organization created`,
        description: `Access ${values.name} from the organization dropdown`,
        action: h(ToastCheck),
      })
      await accounts.fetchAll()
      open.value = false
    }
  }
}
</script>

<template>
  <Dialog v-model:open="open">
    <DialogTrigger as-child>
      <slot />
    </DialogTrigger>
    <DialogContent>
      <DialogHeader>
        <DialogTitle>New organization</DialogTitle>
        <DialogDescription> Create a new organization to manage your listings and integrations. </DialogDescription>
      </DialogHeader>
      <div>
        <Form id="organization-form" :validation-schema="formSchema" @submit="onSubmit">
          <FormField v-slot="{ componentField }" name="name">
            <FormItem>
              <FormLabel>Organization name</FormLabel>
              <FormControl>
                <Input type="text" placeholder="name" v-bind="componentField" />
              </FormControl>
              <FormMessage />
            </FormItem>
          </FormField>
        </Form>
      </div>
      <DialogFooter>
        <Button type="submit" form="organization-form" variant="gradient"> Create organization </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>

<style scoped></style>
