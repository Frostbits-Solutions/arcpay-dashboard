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
import { addAccountUser } from '@/lib/supabase/accounts'
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
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
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
  email: z.string({
    required_error: 'Email is required',
  }).email(),
  role: z.enum(['admin', 'member']),
}))

async function onSubmit(values: any) {
  if (accounts.active?.id) {
    const {data, error} =  await addAccountUser(accounts.active.id, values.email, values.role)
    if (error) {
      toast({
        title: `Error inviting member`,
        description: error.message,
        variant: 'destructive',
        action: h(ToastError)
      });
    } else {
      toast({
        title: `New member added`,
        description: `The will automatically see the organization next time they log-in`,
        action: h(ToastCheck)
      });
      await accounts.fetchAccountUsers(accounts.active.id)
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
        <DialogTitle>Invite team member</DialogTitle>
        <DialogDescription>
          Invite a new team member to manage the organization.
        </DialogDescription>
      </DialogHeader>
      <div class="py-4">
        <Form id="add-user-form" :validation-schema="formSchema" @submit="onSubmit" class="flex items-start gap-2">
          <FormField v-slot="{ componentField }" name="email">
            <FormItem class="flex-1">
              <FormLabel>Email</FormLabel>
              <FormControl>
                <Input type="email" placeholder="email" v-bind="componentField" />
              </FormControl>
              <FormMessage />
            </FormItem>
          </FormField>
          <FormField v-slot="{ componentField }" name="role">
            <FormItem>
              <FormLabel>Role</FormLabel>
              <Select v-bind="componentField">
                <FormControl>
                  <SelectTrigger class="w-36">
                    <SelectValue placeholder="Select a role" />
                  </SelectTrigger>
                </FormControl>
                <SelectContent>
                  <SelectGroup>
                    <SelectItem value="admin">
                      admin
                    </SelectItem>
                    <SelectItem value="member">
                      member
                    </SelectItem>
                  </SelectGroup>
                </SelectContent>
              </Select>
            </FormItem>
          </FormField>
        </Form>
      </div>
      <DialogFooter>
        <Button type="submit" form="add-user-form" variant="gradient">
          Add member
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>

<style scoped>

</style>