<script setup lang="ts">
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from '@repo/ui/dialog'
import { Button } from '@repo/ui/button'
import { addAccountAddress } from '@/services/accounts'
import { toTypedSchema } from '@vee-validate/zod'
import * as z from 'zod'
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from '@repo/ui/form'
import { Input } from '@repo/ui/input'
import { useAccountsStore } from '@/features/accounts/stores/accounts'
import { useToast } from '@repo/ui/toast'
import { h, ref } from 'vue'
import { ToastCheck } from '@repo/ui/toast'
import { errorHandler } from '@/lib/errorHandler'

const accounts = useAccountsStore()
const { toast } = useToast()
const open = ref(false)

const formSchema = toTypedSchema(
  z.object({
    name: z.string().min(4).max(50),
    address: z.string().length(58),
  })
)

async function onSubmit(values: any) {
  if (accounts.active?.id) {
    const { data, error } = await addAccountAddress(accounts.active.id, values.address, values.name)
    if (error) {
      errorHandler(error, 'Error linking address')
    } else {
      toast({
        title: `Address linked`,
        description: `You can now use it to create new listings`,
        action: h(ToastCheck),
      })
      await accounts.fetchAccountAddresses(accounts.active.id)
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
        <Button type="submit" form="link-address-form" variant="gradient"> Link address </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>

<style scoped></style>
