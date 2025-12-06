<script lang="ts" setup>
import { computed, inject, onMounted, ref } from "vue";
import { CaretSortIcon, CheckIcon } from "@radix-icons/vue";
import defaultCurrencyIcon from "@/assets/currency.svg";

import { cn } from "@/lib/utils";
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
import { Skeleton } from "@repo/ui/skeleton";
import type { SupabaseClient } from "@supabase/supabase-js";
import { type Database } from "@/lib/supabase/database.types";
import { getCurrencies } from "@/lib/supabase/currencies";
import type { NetworksConfig } from "@/lib/algod/networks.config";

type Currency = Database["public"]["Tables"]["currencies"]["Row"];
const supabase = inject<SupabaseClient>("supabase");
const network = inject<NetworksConfig>("network");
const currencies = ref<Currency[]>([]);
const selectedCurrency = computed(() => {
  return currencies.value.find((currency) => currency.ticker === value.value);
});
const open = ref(false);
const value = ref<string | undefined>(network?.chain);
const loading = ref(true);
const debug = !!import.meta.env.VITE_DEBUG_API_KEY;

function fetchCurrencies() {
  if (!supabase) throw new Error("Unexpected error: supabase is undefined");
  if (!network) throw new Error("Unexpected error: supabase is undefined");
  loading.value = true;
  getCurrencies(supabase, network.key)
    .then(({ data, error }) => {
      if (data) {
        currencies.value = data;
      } else {
        console.error(
          `Unable to fetch currencies: ${error || "unexpected error"}`,
        );
      }
      loading.value = false;
    })
    .catch((error) => {
      console.error(
        `Unable to fetch currencies: ${error || "unexpected error"}`,
      );
    });
}

defineExpose({
  selectedCurrency,
});

onMounted(() => {
  fetchCurrencies();
});
</script>

<template>
  <Popover v-if="!loading" v-model:open="open">
    <PopoverTrigger as-child>
      <Button
        :aria-expanded="open"
        class="justify-between w-[120px] p-1"
        role="combobox"
        size="lg"
        variant="outline"
      >
        <template v-if="!value"> Select currency </template>
        <template v-else-if="selectedCurrency">
          <div class="flex items-center g1 min-w-0 px-1">
            <img
              :alt="`${selectedCurrency.ticker} icon`"
              :src="selectedCurrency?.icon || defaultCurrencyIcon"
              class="h-5 w-5 rounded-full bg-border"
            />
            <div class="text-xs text-muted-foreground min-w-0">
              <div class="font-semibold text-foreground truncate">
                {{ selectedCurrency.ticker.toUpperCase() }}
              </div>
            </div>
          </div>
        </template>
        <CaretSortIcon class="ml-2 h-4 w-4 shrink-0 opacity-50" />
      </Button>
    </PopoverTrigger>
    <PopoverContent align="end" class="p-0 w-[334px] h-[250px]" side="bottom">
      <Command>
        <CommandInput class="h-9" placeholder="Search by ticker" />
        <CommandEmpty>No currency found.</CommandEmpty>
        <CommandList>
          <CommandGroup class="w-[327px]">
            <CommandItem
              v-for="currency in currencies.filter(
                (c: Currency) => c.visible || debug,
              )"
              :key="currency.id"
              :value="currency.ticker"
              @select="
                (e: CustomEvent) => {
                  if (typeof e.detail.value === 'string') {
                    value = e.detail.value;
                  }
                  open = false;
                }
              "
            >
              <div class="flex items-center g1 min-w-0">
                <img
                  :alt="`${currency.ticker} icon`"
                  :src="currency?.icon || defaultCurrencyIcon"
                  class="h-5 w-5 rounded-full bg-border"
                />
                <div class="text-xs text-muted-foreground min-w-0">
                  <div class="font-semibold text-foreground truncate">
                    {{ currency.ticker.toUpperCase() }}
                  </div>
                  ID: {{ currency.id }}
                </div>
              </div>
              <CheckIcon
                :class="
                  cn(
                    'ml-auto h-4 w-4',
                    value === currency.ticker ? 'opacity-100' : 'opacity-0',
                  )
                "
              />
            </CommandItem>
          </CommandGroup>
        </CommandList>
      </Command>
    </PopoverContent>
  </Popover>
  <Skeleton v-else class="w-[120px] h-9 p-2" />
</template>
