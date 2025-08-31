<script setup lang="ts">
import { useAccountsStore } from '@/features/accounts/stores/accounts'
import { Button } from '@/lib/ui/button'
import { updateAccountNetworksParameters, createAccountNetworksParameters } from '@/services/accounts'
import { h, ref, watch, type Ref, computed } from 'vue'
import ToastError from '@/lib/ui/toast/ToastError.vue'
import ToastCheck from '@/lib/ui/toast/ToastCheck.vue'
import { useToast } from '@/lib/ui/toast'
import { Badge } from '@/lib/ui/badge'
import { Switch } from '@/lib/ui/switch'
import { FormControl, FormDescription, FormField, FormItem, FormLabel, FormMessage } from '@/lib/ui/form'
import { Input } from '@/lib/ui/input'
import { toTypedSchema } from '@vee-validate/zod'
import { useForm } from 'vee-validate'
import * as z from 'zod'
import type { AccountNetworkParameter } from '@/models'

const accounts = useAccountsStore()
const { toast } = useToast()

const props = defineProps({
  selectedNetwork: {
    type: String,
    required: true,
  },
})

const hasProSubscription = computed<boolean>(() => accounts.activeSettings.subscription_tiers?.allow_secondary_listings ?? false)
const selectedNetworkParameter: Ref<AccountNetworkParameter> = ref({
  account_id: '',
  created_at: '',
  network_id: '',
  enable_secondary: false,
  secondary_fee_address: null,
  secondary_percentage_fee: 0,
})

const formSchema = toTypedSchema(
  z.object({
    enable_secondary: z.boolean().optional(),
    secondary_percentage_fee: z.number().min(0, 'Percentage must be at least 0.00%').max(50, 'Percentage must be at most 50.00%'),
    // TODO (GH-30) - Update the regex to match algo addresses
    secondary_fee_address: z.string().regex(/^0x[a-fA-F0-9]{40}$/, 'Invalid network address'), // Regex for Ethereum-like addresses
  })
)

const form = useForm({
  validationSchema: formSchema,
})

function resetForm() {
  const selectedNetwork = props.selectedNetwork
  if (!selectedNetwork || !accounts.active || !accounts.activeSettings.networksParameters) return

  // Find the network parameter for the selected network
  const networkParameter = accounts.activeSettings.networksParameters.find((c) => c.network_id === selectedNetwork)

  // Update the selectedNetworkParameter based on the found network parameter or set default values
  selectedNetworkParameter.value = networkParameter
    ? { ...networkParameter, account_id: accounts.active.id }
    : {
        account_id: accounts.active.id,
        created_at: '',
        network_id: selectedNetwork,
        enable_secondary: false,
        secondary_fee_address: null,
        secondary_percentage_fee: 0,
      }

  // Reset the form with the updated selectedNetworkParameter values
  form.resetForm({
    values: {
      enable_secondary: selectedNetworkParameter.value.enable_secondary,
      secondary_fee_address: selectedNetworkParameter.value.secondary_fee_address ?? '',
      secondary_percentage_fee: selectedNetworkParameter.value.secondary_percentage_fee,
    },
  })
}

const onNetworkParamFormSubmit = form.handleSubmit(async (values) => {
  if (!hasProSubscription.value || !accounts.active?.id || !accounts.activeSettings.networksParameters) return

  const accountId = selectedNetworkParameter.value.account_id
  const networkId = props.selectedNetwork

  // Check if network parameter already exists
  const existingNetworkParameter = accounts.activeSettings.networksParameters.find((c) => c.network_id === networkId)

  const apiCall = existingNetworkParameter
    ? updateAccountNetworksParameters // Update if exists
    : createAccountNetworksParameters // Create if not exists

  // Call the appropriate API
  const { data, error } = await apiCall(accountId, networkId, values.enable_secondary ?? false, values.secondary_fee_address ?? '', values.secondary_percentage_fee)

  if (error) {
    // Show error toast
    toast({
      title: `Error ${existingNetworkParameter ? 'updating' : 'creating'} network parameter`,
      description: error.message,
      variant: 'destructive',
      action: h(ToastError),
    })
    return
  }

  // Update local state with the new/updated network parameters
  if (data) accounts.activeSettings.networksParameters = data

  // Show success toast
  toast({
    title: `${existingNetworkParameter ? 'Updated' : 'Created'} network parameter for ${networkId}`,
    action: h(ToastCheck),
  })
})

watch(
  () => accounts.active?.id,
  () => {
    resetForm()
  }
)

watch(
  () => props.selectedNetwork,
  () => {
    resetForm()
  },
  { immediate: true }
)
</script>

<template>
  <div class="relative mt-6">
    <div class="rounded-lg border border-border bg-muted/50 p-4">
      <div class="flex items-center justify-between">
        <div>
          <h4 class="text-md font-normal">Third party listings <Badge variant="gradient">PRO</Badge></h4>
          <p class="text-sm text-muted-foreground">
            Allow third party listings to be created by addresses that are not linked to your organization. Your organization collects fees on each third party listing sold.<br />
            <template v-if="!hasProSubscription || accounts.loading">Upgrade to PRO to enable third party listings and collect fees on each sale.</template>
          </p>
        </div>
      </div>
    </div>
    <div v-if="hasProSubscription && !accounts.loading" class="mt-2 rounded-lg border border-border p-4" v-motion-fade>
      <form id="networks-parameters-form" class="space-y-6" @submit="onNetworkParamFormSubmit">
        <div>
          <!-- Enable Secondary Listing -->
          <FormField v-slot="{ value, handleChange }" name="enable_secondary">
            <FormItem>
              <div class="flex items-center justify-between px-4 py-4">
                <div>
                  <FormLabel>Enable secondary listing for {{ props.selectedNetwork }}</FormLabel>
                  <FormDescription> Allow fees on secondary listings for this network. </FormDescription>
                </div>
                <FormControl>
                  <Switch @update:checked="handleChange" :checked="value" />
                </FormControl>
              </div>
            </FormItem>
          </FormField>

          <!-- Secondary Fee Address -->
          <FormField v-slot="{ componentField, errors }" name="secondary_fee_address">
            <FormItem>
              <div class="flex items-center justify-between px-4 py-4">
                <div>
                  <FormLabel>Secondary fee address</FormLabel>
                  <FormDescription> Address that will receive the fees from secondary listings. </FormDescription>
                  <FormMessage v-if="errors" class="mt-2 text-xs">{{ errors }}</FormMessage>
                </div>
                <FormControl>
                  <Input type="text" v-bind="componentField" placeholder="0x..." class="w-1/2 truncate" />
                </FormControl>
              </div>
            </FormItem>
          </FormField>

          <!-- Fee Percentage -->
          <FormField v-slot="{ componentField, errors }" name="secondary_percentage_fee">
            <FormItem>
              <div class="flex items-center justify-between px-4 py-4">
                <div>
                  <FormLabel>Fee Percentage</FormLabel>
                  <FormDescription> Enter the percentage fee (0.00% to 50.00%). </FormDescription>
                  <FormMessage v-if="errors" class="mt-2 text-xs">{{ errors }}</FormMessage>
                </div>
                <FormControl>
                  <div class="flex items-center">
                    <Input v-bind="componentField" type="number" step="0.01" min="0" max="50" class="w-1/8" />
                    <span class="ml-2 text-muted-foreground">%</span>
                  </div>
                </FormControl>
              </div>
            </FormItem>
          </FormField>
        </div>
        <div class="flex justify-end">
          <Button variant="outline" type="submit" form="networks-parameters-form"> Save </Button>
        </div>
      </form>
    </div>
  </div>
</template>

<style scoped></style>
