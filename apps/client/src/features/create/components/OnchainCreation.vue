<script lang="ts" setup>
import { Gavel, HandCoins, Receipt } from "lucide-vue-next";
import AssetSelectionCombobox from "@/components/ListingCreation/AssetSelectionCombobox.vue";
import type { CreateListingOptions, ListingCreationParams } from "@/lib/app";
import { computed, ref, type VNodeRef } from "vue";
import { Button } from "@repo/ui/button";
import { Label } from "@repo/ui/label";
import type { AssetMetadata } from "@/lib/types";
import type { WalletAccount } from "@txnlab/use-wallet";

const emit = defineEmits<{
  (e: "action:create-listing", params: ListingCreationParams): void;
}>();
const props = defineProps<{
  args: {
    account: WalletAccount;
    options: CreateListingOptions;
  };
}>();
const assetSelectionComboboxRef = ref<VNodeRef | null>(null);
const ListingCreationComponentRef = ref<VNodeRef | null>(null);

const selectedAsset = computed<AssetMetadata>(() => {
  return assetSelectionComboboxRef.value?.selectedAsset;
});

const listingParams = computed(() => {
  return ListingCreationComponentRef.value?.params;
});

function createListing() {
  if (listingParams.value && selectedAsset.value) {
    emit("action:create-listing", {
      ...listingParams.value,
      asset: selectedAsset.value,
    } as ListingCreationParams);
  }
}
</script>

<template>
  <div class="flex flex-col g2 mt-4 md:flex-row md:g8">
    <div class="flex flex-col justify-center mx-auto">
      <AssetSelectionCombobox
        ref="assetSelectionComboboxRef"
        :account="args?.account"
        :default-value="args?.options?.assetId"
      />
    </div>
    <div class="flex flex-col justify-between w-[333px] mx-auto">
      <div>
        <div v-if="!args?.options?.listingType">
          <Label class="text-xs text-muted-foreground">Listing type</Label>
          <div class="grid g[17px] grid-cols-4 mt-2">
            <RouterLink
              :to="{ name: 'sale-creation' }"
              class="h-[74px] text-xs cursor-pointer flex flex-col items-center justify-center g1 rounded-md border-2 border-muted bg-background text-muted-foreground hover:text-foreground"
            >
              <Receipt class="h-5 w-5" />
              Sale
            </RouterLink>
            <RouterLink
              :to="{ name: 'auction-creation' }"
              class="h-[74px] text-xs cursor-pointer flex flex-col items-center justify-center g1 rounded-md border-2 border-muted bg-background text-muted-foreground hover:text-foreground"
            >
              <Gavel class="h-5 w-5" />
              Auction
            </RouterLink>
            <RouterLink
              :to="{ name: 'dutch-creation' }"
              class="text-center h-[74px] text-xs cursor-pointer flex flex-col items-center justify-center g1 rounded-md border-2 border-muted bg-background text-muted-foreground hover:text-foreground"
            >
              <HandCoins class="h-5 w-5" />
              Reverse
            </RouterLink>
          </div>
        </div>
        <div>
          <router-view v-slot="{ Component }">
            <component :is="Component" ref="ListingCreationComponentRef" />
          </router-view>
        </div>
      </div>
      <Button
        class="w-full mt-10 h-10"
        size="lg"
        variant="default"
        @click="createListing"
        >Create listing</Button
      >
    </div>
  </div>
</template>

<style scoped>
.router-link-exact-active {
  border-color: transparent;
  background-image:
    linear-gradient(hsl(var(--background)), hsl(var(--background))),
    var(--gradient);
  background-origin: border-box;
  background-clip: content-box, border-box;
  color: hsl(var(--foreground));
}
</style>
