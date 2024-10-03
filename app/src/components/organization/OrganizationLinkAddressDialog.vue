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
import { addAccountAddress } from '@/lib/supabase/accounts'
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
import { Select, SelectContent, SelectGroup, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'

const accounts = useAccountsStore()
const {toast} = useToast()
const open = ref(false)

const formSchema = toTypedSchema(z.object({
  name: z.string().min(4).max(50),
  address: z.string().length(58)
}))

async function onSubmit(values: any) {
  if (accounts.active?.id) {
    const {data, error} =  await addAccountAddress(accounts.active.id, values.address, values.name)
    if (error) {
      toast({
        title: `Error linking address`,
        description: error.message,
        variant: 'destructive',
        action: h(ToastError)
      });
    } else {
      toast({
        title: `Address linked`,
        description: `You can now use it to create new listings`,
        action: h(ToastCheck)
      });
      await accounts.fetchAccountAddresses(accounts.active.id)
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
        <DialogTitle>Link address</DialogTitle>
        <DialogDescription>
          Link an address to your organization to create new listings. Listing created by addresses that are not linked to your organization are considered third party listings.
        </DialogDescription>
      </DialogHeader>
      <div class="py-4">
        <Form id="link-address-form" :validation-schema="formSchema" @submit="onSubmit" class="space-y-6">
          <FormField v-slot="{ componentField }" name="address">
            <FormItem class="flex-1">
              <FormLabel>Address</FormLabel>
              <FormControl>
                <Input type="text" placeholder="address" v-bind="componentField" />
              </FormControl>
              <FormMessage />
            </FormItem>
          </FormField>
          <FormField v-slot="{ componentField }" name="name">
            <FormItem class="flex-1">
              <FormLabel>Address label</FormLabel>
              <FormControl>
                <Input type="text" placeholder="label" v-bind="componentField" />
              </FormControl>
              <FormMessage />
            </FormItem>
          </FormField>
        </Form>
      </div>
      <DialogFooter>
        <Button type="submit" form="link-address-form" variant="gradient">
          Link address
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>

<style scoped>

</style>