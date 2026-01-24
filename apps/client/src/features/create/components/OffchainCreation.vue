<script setup lang="ts">
import CurrencySelectionCombobox from "@/components/ListingCreation/CurrencySelectionCombobox.vue";
import {
  NumberField,
  NumberFieldContent,
  NumberFieldDecrement,
  NumberFieldIncrement,
  NumberFieldInput,
} from "@repo/ui/number-field";
import { Label } from "@repo/ui/label";
import { computed, onMounted, ref } from "vue";
import { Button } from "@repo/ui/button";
import type { WalletAccount } from "@txnlab/use-wallet";
import type { CreateListingOptions, ListingCreationParams } from "@/lib/app";

const emit = defineEmits<{
  (e: "action:create-listing", params: ListingCreationParams): void;
}>();
const props = defineProps<{
  args: {
    account: WalletAccount;
    options: CreateListingOptions;
  };
}>();
const currencySelectorRef = ref<typeof CurrencySelectionCombobox | null>(null);
const price = ref<number>(100);
const listingParams = computed(() => {
  return {
    type: "sale",
    price: price.value,
    currency: currencySelectorRef.value?.selectedCurrency,
    asset: {
      id: props.args.options?.assetId,
      name: props.args.options?.listingName,
      description: "",
      thumbnail: props.args.options?.thumbnailUrl,
      type: "offchain",
      thumbnailMIMEType: "image/png",
      properties: {},
    },
  };
});

function createListing() {
  if (listingParams.value) {
    emit("action:create-listing", {
      ...listingParams.value,
    } as ListingCreationParams);
  }
}

onMounted(() => {
  if (!props.args.options?.assetId)
    throw new Error("Asset ID is required to create offchain listing");
  if (!props.args.options?.listingName)
    throw new Error("Listing name is required to create offchain listing");
});
</script>

<template>
  <div class="mt-2">
    <h2 class="font-medium text-sm mt-6 mb-2">
      {{ args.options?.listingName }}
    </h2>
    <div
      class="w-[333px] h-[333px] relative rounded-3xl p-0 overflow-hidden bg-background shadow-2xl border border-border transition mb-6"
      v-if="args.options?.thumbnailUrl"
    >
      <img
        :alt="args.options?.assetId"
        :src="args.options.thumbnailUrl"
        class="w-[333px] h-[333px] object-cover absolute top-0 left-0 z-0"
      />
    </div>
    <Label class="mb-1 text-xs text-muted-foreground" for="price"
      >Asking price</Label
    >
    <div class="flex gap-1 items-center mt-2">
      <NumberField
        id="price"
        :format-options="{
          style: 'decimal',
          minimumFractionDigits: 2,
        }"
        :model-value="price"
        class="flex-1"
        @update:modelValue="(value: number) => (price = value)"
      >
        <NumberFieldContent>
          <NumberFieldDecrement />
          <NumberFieldInput />
          <NumberFieldIncrement />
        </NumberFieldContent>
      </NumberField>
      <CurrencySelectionCombobox ref="currencySelectorRef" />
    </div>
    <Button
      class="w-full mt-10 h-10"
      size="lg"
      variant="default"
      @click="createListing"
      >Create listing</Button
    >
  </div>
</template>

<style scoped></style>
