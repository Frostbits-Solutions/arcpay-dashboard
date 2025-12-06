<script lang="ts" setup>
import { computed, inject, onMounted, ref } from "vue";
import { CheckIcon } from "@radix-icons/vue";
import { LoaderCircle } from "lucide-vue-next";
import { cn, formatAmountFromDecimals } from "@/lib/utils";
import { Button } from "@repo/ui/button";
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from "@repo/ui/command";
import { Popover, PopoverContent, PopoverTrigger } from "@repo/ui/popover";
import type { AssetMetadata } from "@/lib/types";
import { Skeleton } from "@repo/ui/skeleton";
import type { WalletAccount } from "@txnlab/use-wallet";
import { WalletManager } from "@txnlab/use-wallet";
import type { NetworksConfig } from "@/lib/algod/networks.config";
import InfiniteLoading from "v3-infinite-loading";

const props = defineProps<{
  account: WalletAccount | undefined;
  defaultValue: string | undefined;
}>();
const network = inject<NetworksConfig>("network");
const walletManager = inject<WalletManager>("walletManager");
const assets = ref<AssetMetadata[]>([]);
const open = ref(false);
const value = ref("");
const initialLoading = ref(true);
const selectedAsset = computed(() => {
  return assets.value.find((asset) => asset.id === value.value);
});

let page = 1;

async function getAssets(pageIndex: number) {
  if (network && walletManager && props.account?.address) {
    return network.services
      .getAddressAssets(
        walletManager.algodClient,
        props.account.address,
        pageIndex,
        25,
      )
      .then((data) => {
        assets.value.push(...data);
        if (
          assets.value.findIndex((asset) => asset.id === props.defaultValue) !==
          -1
        ) {
          value.value = props.defaultValue || "";
        }
        return data.length;
      });
  } else {
    throw new Error("Network or account not available");
  }
}

async function load(state: any) {
  try {
    const len = await getAssets(page);
    if (len < 25) state.complete();
    else {
      state.loaded();
      page++;
    }
  } catch (e) {
    console.error(e);
    state.error();
  }
}

defineExpose({
  selectedAsset,
});

onMounted(async () => {
  initialLoading.value = true;
  await getAssets(0);
  initialLoading.value = false;
});
</script>

<template>
  <Popover v-if="!initialLoading" v-model:open="open">
    <PopoverTrigger as-child>
      <Button
        :aria-expanded="open"
        :class="[
          'w-[333px] h-[333px] flex relative rounded-3xl p-0 overflow-hidden bg-background shadow-2xl border border-border transition hover:bg-background',
          !value ? 'items-center' : 'items-end',
        ]"
        role="combobox"
        variant="ghost"
      >
        <div v-if="!value" class="text-muted-foreground text-center">
          Click to select asset
        </div>
        <div
          v-else-if="selectedAsset"
          class="flex flex-1 min-w-0 relative z-10 p-4"
        >
          <div class="text-foreground min-w-0 text-left">
            <div
              class="text-sm inline-block max-w-full font-semibold truncate bg-background/50 backdrop-blur-lg px-1 py-0.5 rounded"
            >
              {{ selectedAsset.name }}
            </div>
            <div
              class="text-xs table bg-background/50 backdrop-blur-lg px-1 py-0.5 rounded"
            >
              {{ selectedAsset.id }}
            </div>
          </div>
        </div>
        <img
          v-if="selectedAsset"
          :alt="selectedAsset.id"
          :src="selectedAsset.thumbnail"
          class="w-[333px] h-[333px] object-cover absolute top-0 left-0 z-0"
        />
      </Button>
    </PopoverTrigger>
    <PopoverContent
      :side-offset="-333"
      class="p-0 w-[333px] h-[333px]"
      side="right"
    >
      <Command>
        <CommandInput class="h-9" placeholder="Search by asset id" />
        <CommandEmpty>
          <div class="text-muted-foreground mt-8">Wow, very empty.</div>
        </CommandEmpty>
        <CommandList>
          <CommandGroup class="w-[326px]">
            <CommandItem
              v-for="asset in assets"
              :key="asset.id"
              :value="asset.id"
              @select="
                (ev: CustomEvent) => {
                  if (typeof ev.detail.value === 'string') {
                    value = ev.detail.value;
                  }
                  open = false;
                }
              "
            >
              <div class="flex items-center g2 min-w-0">
                <img
                  :alt="asset.id"
                  :src="asset.thumbnail"
                  class="w-12 h-12 mr-2 rounded object-cover border border-border bg-muted"
                />
                <div class="text-xs text-muted-foreground min-w-0">
                  <div class="font-semibold text-foreground truncate">
                    {{ asset.name }}
                    <span
                      v-if="asset.subtype"
                      class="text-muted-foreground font-normal"
                      >({{ asset.subtype }})</span
                    >
                  </div>
                  ID: {{ asset.id }}<br />
                  <template v-if="asset.amount"
                    >Amount:
                    {{
                      formatAmountFromDecimals(asset.amount, asset.decimals)
                    }}</template
                  >
                </div>
              </div>
              <CheckIcon
                :class="
                  cn(
                    'ml-auto h-4 w-4',
                    value === asset.id ? 'opacity-100' : 'opacity-0',
                  )
                "
              />
            </CommandItem>
            <InfiniteLoading @infinite="load">
              <template #spinner>
                <div
                  class="flex justify-center items-center g2 p-2 text-xs text-muted-foreground"
                >
                  <LoaderCircle
                    class="size-4 text-primary animate-spin text-xs"
                  />
                  Loading assets...
                </div>
              </template>
              <template #complete>
                <span
                  class="flex justify-center items-center g2 p-2 text-xs text-muted-foreground"
                  >That's all for now!</span
                >
              </template>
              <template #error>
                <span
                  class="flex justify-center items-center g2 p-2 text-xs text-destructive"
                  >Unexpected error occurred while loading your assets</span
                >
              </template>
            </InfiniteLoading>
          </CommandGroup>
        </CommandList>
      </Command>
    </PopoverContent>
  </Popover>
  <Skeleton v-else class="w-[333px] h-[333px] p-2" />
</template>
