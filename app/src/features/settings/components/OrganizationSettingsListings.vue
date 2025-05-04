<script setup lang="ts">

import { useAccountsStore } from '@/features/shared/stores/accounts'
import { Button } from '@/lib/ui/button'
import { Clipboard } from '@/lib/ui/clipboard'
import { Trash2 } from 'lucide-vue-next'
import { Skeleton } from '@/lib/ui/skeleton'
import { 
  deleteAccountApiKey, 
  removeAccountAddress, 
  updateAccountChainsParameters, 
  createAccountChainsParameters 
} from '@/features/settings/services/accounts'
import { h, ref, watch, type Ref } from 'vue'
import ToastError from '@/lib/ui/toast/ToastError.vue'
import ToastCheck from '@/lib/ui/toast/ToastCheck.vue'
import { useToast } from '@/lib/ui/toast'
import OrganizationLinkAddressDialog from '@/features/settings/components/OrganizationLinkAddressDialog.vue'
import { Badge } from '@/lib/ui/badge'
import { Switch } from '@/lib/ui/switch'
import { Form, FormControl, FormDescription, FormField, FormItem, FormLabel, FormMessage } from '@/lib/ui/form'
import { Input } from '@/lib/ui/input'
import { toTypedSchema } from '@vee-validate/zod'
import { useForm } from 'vee-validate';
import * as z from 'zod'
import type { Chain, AccountsChainsParameter } from '@/models'
import { useNetworksStore } from '@/features/network/stores/networks'

const accounts = useAccountsStore()
const network = useNetworksStore()

const { toast } = useToast()

const hasProSubscription : Ref<boolean> = ref(accounts.activeSettings.subscription?.allow_secondary_listings ?? false)
const chains : Ref<Chain[]> = ref(network.networks)
const activeChainTab = ref(0)

const formSchema = toTypedSchema(z.object({
  enable_secondary: z.boolean().optional(),
  secondary_percentage_fee: z
    .number()
    .min(0, "Percentage must be at least 0.00%")
    .max(50, "Percentage must be at most 50.00%"),
  secondary_fee_address: z.string().regex(/^0x[a-fA-F0-9]{40}$/, "Invalid chain address") // Regex for Ethereum-like addresses
}))

const activeChainParameter: Ref<AccountsChainsParameter>= ref({
          account_id: 0,
          created_at: '',
          chain_id: '',
          enable_secondary: false,
          secondary_fee_address: null,
          secondary_percentage_fee: 0,
        })

const form = useForm({
  validationSchema: formSchema,
});

async function onDeleteAccountAddress(address: string) {
  if (accounts.active?.id) {
    const {data, error} = await removeAccountAddress(accounts.active.id, address)
    if (error) {
      toast({
        title: `Error removing address`,
        description: error.message,
        variant: 'destructive',
        action: h(ToastError)
      });
    } else {
      await accounts.fetchAccountAddresses(accounts.active.id)
      toast({
        title: `Address removed`,
        action: h(ToastCheck)
      });
    }
  }
}

function updateChainParamFormValues() {
  const selectedChain = chains.value[activeChainTab.value];
  if (!selectedChain || !accounts.active || !accounts.activeSettings.chainsParameters) return;

  // Find the chain parameter for the selected chain
  const chainParameter = accounts.activeSettings.chainsParameters.find(
    (c) => c.chain_id === selectedChain.id
  );

  // Update the activeChainParameter based on the found chain parameter or set default values
  activeChainParameter.value = chainParameter
    ? { ...chainParameter, account_id: accounts.active.id }
    : {
        account_id: accounts.active.id,
        created_at: '',
        chain_id: selectedChain.id,
        enable_secondary: false,
        secondary_fee_address: null,
        secondary_percentage_fee: 0,
      };

  // Reset the form with the updated activeChainParameter values
  form.resetForm({
    values: {
      enable_secondary: activeChainParameter.value.enable_secondary,
      secondary_fee_address: activeChainParameter.value.secondary_fee_address ?? '',
      secondary_percentage_fee: activeChainParameter.value.secondary_percentage_fee,
    },
  });
}

const onChainParamFormSubmit = form.handleSubmit(async (values) => {
  if (!hasProSubscription.value || !accounts.active?.id || !accounts.activeSettings.chainsParameters) return;

  const accountId = activeChainParameter.value.account_id;
  const chainId = chains.value[activeChainTab.value].id;

  // Check if chain parameter already exists
  const existingChainParameter = accounts.activeSettings.chainsParameters.find(
    (c) => c.chain_id === chainId
  );

  const apiCall = existingChainParameter
    ? updateAccountChainsParameters // Update if exists
    : createAccountChainsParameters; // Create if not exists

  // Call the appropriate API
  const { data, error } = await apiCall(
    accountId,
    chainId,
    values.enable_secondary ?? false,
    values.secondary_fee_address ?? "",
    values.secondary_percentage_fee
  );

  if(error) {
    // Show error toast
    toast({
      title: `Error ${existingChainParameter ? "updating" : "creating"} chain parameter`,
      description: error.message,
      variant: "destructive",
      action: h(ToastError),
    });
    return;
  }
  
  // Update local state with the new/updated chain parameters
  if (data) accounts.activeSettings.chainsParameters = data;

  // Show success toast
  toast({
    title: `${existingChainParameter ? "Updated" : "Created"} chain parameter for ${chainId}`,
    action: h(ToastCheck),
  });
});

watch(
  () => accounts,
  () => {
    updateChainParamFormValues();
  },
  { deep: true }
);

watch(
  activeChainTab,
  () => {
    updateChainParamFormValues();
  },
  { immediate: true }
);
</script>

<template>
  <div>
  <h2 class="text-2xl font-bold dark:text-white">Listings</h2>
  <div class="relative mt-6">
    <div class="flex items-center justify-between pb-4">
      <div>
        <h4 class="text-md font-normal">Organization addresses</h4>
        <p class="text-sm text-muted-foreground">Link accounts to your organization to new create listings. Listing created by addresses that are not linked to your organization are considered third party listings.</p>
      </div>
      <OrganizationLinkAddressDialog>
        <Button variant="outline">Link address</Button>
      </OrganizationLinkAddressDialog>
    </div>
    <div class="rounded-lg border border-border overflow-hidden">
      <table class="w-full text-sm text-left rtl:text-right text-muted-foreground">
        <thead class="text-xs text-muted-foreground/50 uppercase bg-muted/50">
        <tr>
          <th scope="col" class="px-6 py-3 w-[512px]">
            Address
          </th>
          <th scope="col" class="px-6 py-3">
            Name
          </th>
          <th scope="col" class="px-6 py-3 w-16"></th>
        </tr>
        </thead>
        <tbody>
        <template v-if="!accounts.loading">
          <tr v-for="address in accounts.activeSettings.addresses" :key="address.address" class="border-b last:border-b-0 border-border">
            <td class="px-6 py-4">
              <Clipboard :source="address.address" class="text-xs"/>
            </td>
            <td class="px-6 py-4 truncate">
              {{ address.name }}
            </td>
            <td class="px-6 py-4">
              <Button variant="ghost" size="icon" class="size-7 rounded-sm" @click="onDeleteAccountAddress(address.address)">
                <Trash2 class="size-4 text-destructive"/>
              </Button>
            </td>
          </tr>
          <tr v-if="!accounts.activeSettings.addresses?.length">
            <td colspan="4" class="px-6 py-4 text-center text-sm text-muted-foreground">
              No addresses linked
            </td>
          </tr>
        </template>
        <tr v-else>
          <td class="px-6 py-4">
            <Skeleton class="h-4 w-48"/>
          </td>
          <td class="px-6 py-4">
            <Skeleton class="h-4 w-48"/>
          </td>
          <td class="px-6 py-4">
            <Skeleton class="h-4 w-28"/>
          </td>
          <td class="px-6 py-4">
            <Skeleton class="h-5 w-8"/>
          </td>
        </tr>
        </tbody>
      </table>
    </div>
    <div class="border border-border bg-muted/50 rounded-lg p-4 mt-6">
      <div class="flex items-center justify-between">
        <div>
          <h4 class="text-md font-normal">Third party listings <Badge variant="gradient">PRO</Badge></h4>
          <p class="text-sm text-muted-foreground">
            Allow third party listings to be created by addresses that are not linked to your organization. Your organization collects fees on each third party listing sold.
          </p>
        </div>
        <Switch :default-checked="hasProSubscription" :disabled="true"/>
      </div>
      <div v-if="hasProSubscription" >
        <div class="flex border-b border-border pt-8">
          <button
            v-for="(chain, index) in chains"
            :key="chain.id"
            @click="activeChainTab = index"
            :class="[
              'px-4 py-2 text-sm',
              activeChainTab === index ? 'border-b-2 border-primary text-primary' : 'text-muted-foreground',
            ]"
          >
            {{ chain.id }}
          </button>
        </div>
        <form  
          id="chains-parameters-form" 
          class="space-y-6 mt-6"
          @submit="onChainParamFormSubmit"
        >
          <div>
            <div v-for="(chain, index) in chains" :key="chain.id" v-show="activeChainTab === index" class="mt-4">
              <!-- Enable Secondary Listing -->
              <FormField v-slot="{ value, handleChange }" name="enable_secondary">
                <FormItem>
                  <div class="flex items-center justify-between px-4 py-4">
                    <div>
                      <FormLabel>Enable secondary listing for {{ chain.id }}</FormLabel>
                      <FormDescription>
                        Allow fees on secondary listings for this chain.
                      </FormDescription>
                    </div>
                    <FormControl>
                      <Switch
                        @update:checked="handleChange"	
                        :checked="value"
                      />
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
                      <FormDescription>
                        Address that will receive the fees from secondary listings.
                      </FormDescription>
                      <FormMessage v-if="errors" class="text-xs mt-2">{{ errors }}</FormMessage>
                    </div>
                    <FormControl>
                      <Input
                        type="text"
                        v-bind="componentField"
                        placeholder="0x..."
                        class="w-1/2 truncate"
                      />
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
                      <FormDescription>
                        Enter the percentage fee (0.00% to 50.00%).
                      </FormDescription>
                      <FormMessage v-if="errors" class="text-xs mt-2">{{ errors }}</FormMessage>
                    </div>
                    <FormControl>
                      <div class="flex items-center">
                        <Input
                          v-bind="componentField"
                          type="number"
                          step="0.01"
                          min="0"
                          max="50"
                          class="w-1/8"
                        />
                        <span class="ml-2 text-muted-foreground">%</span>
                      </div>
                    </FormControl>
                  </div>
                </FormItem>
              </FormField>
            </div>
          </div>
          <div class="flex justify-end">
            <Button variant="outline" type="submit" form="chains-parameters-form">
              Save
            </Button>
          </div>
        </form >
      </div>
      <div v-else>
        <p class="text-sm text-muted-foreground pt-8">
          This feature is available exclusively for PRO subscribers. Upgrade to PRO to enable third party listings and collect fees on each sale.
        </p> 
      </div>
    </div>
  </div>
</div>
</template>

<style scoped>

</style>