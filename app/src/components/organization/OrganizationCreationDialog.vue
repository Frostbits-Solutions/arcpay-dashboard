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
import { useSessionStore } from '@/stores/session'
import { createAccount } from '@/lib/supabase/accounts'
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
}))

async function onSubmit(values: any) {
  const session = useSessionStore()
  if (session?.user?.email) {
    const {data, error} =  await createAccount(values.name, session.user.email)
    if (error) {
      toast({
        title: `Error creating organization`,
        description: error.message,
        variant: 'destructive',
        action: h(ToastError)
      });
    } else {
      toast({
        title: `Organization created`,
        description: `Access ${values.name} from the organization dropdown`,
        action: h(ToastCheck)
      });
      await accounts.fetchAll()
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
          <DialogTitle>New organization</DialogTitle>
          <DialogDescription>
            Create a new organization to manage your listings and integrations.
          </DialogDescription>
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
          <Button type="submit" form="organization-form" variant="gradient">
            Create organization
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
</template>

<style scoped>

</style>