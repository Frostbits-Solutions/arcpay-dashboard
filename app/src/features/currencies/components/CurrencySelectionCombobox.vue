<script lang="ts" setup>
import { computed, onMounted, ref, watch } from 'vue'
import { CaretSortIcon, CheckIcon } from '@radix-icons/vue'
import defaultCurrencyIcon from '@/assets/currency.svg'

import { cn } from '@/lib/utils'
import { Button } from '@/lib/ui/button'
import { Command, CommandEmpty, CommandGroup, CommandInput, CommandItem, CommandList } from '@/lib/ui/command'
import { Popover, PopoverContent, PopoverTrigger } from '@/lib/ui/popover'
import { Skeleton } from '@/lib/ui/skeleton'
import { type Database } from '@/lib/supabase/database.types'
import { useCurrenciesStore } from '@/features/currencies/stores/currencies'

type Currency = Database['public']['Tables']['currencies']['Row']

const props = defineProps({
  activeChain: {
    type: String,
    required: true,
  },
})

const currencyStore = useCurrenciesStore()
const currencies = computed(() => currencyStore.list)
const selectedCurrency = computed(() => {
  return currencies.value.find((currency) => currency.ticker === value.value)
})
const open = ref(false)
const value = ref<string | undefined>(props.activeChain || undefined)
const loading = ref(true)

defineExpose({
  selectedCurrency,
})

watch(
  () => props,
  () => {
    loading.value = true
    currencyStore.fetchCurrencies(props.activeChain)
    console.log('Listed currencies:', currencyStore.list)
    loading.value = false
  },
  { immediate: true, deep: true }
)
</script>

<template>
  <Popover v-if="!loading" v-model:open="open">
    <PopoverTrigger as-child>
      <Button :aria-expanded="open" class="ap-justify-between ap-w-[120px] ap-p-1" role="combobox" size="lg" variant="outline">
        <template v-if="!value"> Select currency </template>
        <template v-else-if="selectedCurrency">
          <div class="ap-flex ap-items-center ap-gap-1 ap-min-w-0 ap-px-1">
            <img :alt="`${selectedCurrency.ticker} icon`" :src="selectedCurrency?.icon || defaultCurrencyIcon" class="ap-h-5 ap-w-5 ap-rounded-full ap-bg-border" />
            <div class="ap-text-xs ap-text-muted-foreground ap-min-w-0">
              <div class="ap-font-semibold ap-text-foreground ap-truncate">
                {{ selectedCurrency.ticker.toUpperCase() }}
              </div>
            </div>
          </div>
        </template>
        <CaretSortIcon class="ap-ml-2 ap-h-4 ap-w-4 ap-shrink-0 ap-opacity-50" />
      </Button>
    </PopoverTrigger>
    <PopoverContent align="end" class="ap-p-0 ap-w-[334px] ap-h-[250px]" side="bottom">
      <Command>
        <CommandInput class="ap-h-9" placeholder="Search by ticker" />
        <CommandEmpty>No currency found.</CommandEmpty>
        <CommandList>
          <CommandGroup class="ap-w-[327px]">
            <CommandItem
              v-for="currency in currencies.filter((c: Currency) => !c.is_public)"
              :key="currency.id"
              :value="currency.ticker"
              @select="
                (e: CustomEvent) => {
                  if (typeof e.detail.value === 'string') {
                    value = e.detail.value
                  }
                  open = false
                }
              "
            >
              <div class="ap-flex ap-items-center ap-gap-1 ap-min-w-0">
                <img :alt="`${currency.ticker} icon`" :src="currency?.icon || defaultCurrencyIcon" class="ap-h-5 ap-w-5 ap-rounded-full ap-bg-border" />
                <div class="ap-text-xs ap-text-muted-foreground ap-min-w-0">
                  <div class="ap-font-semibold ap-text-foreground ap-truncate">
                    {{ currency.ticker.toUpperCase() }}
                  </div>
                  ID: {{ currency.id }}
                </div>
              </div>
              <CheckIcon :class="cn('ap-ml-auto ap-h-4 ap-w-4', value === currency.ticker ? 'ap-opacity-100' : 'ap-opacity-0')" />
            </CommandItem>
          </CommandGroup>
        </CommandList>
      </Command>
    </PopoverContent>
  </Popover>
  <Skeleton v-else class="ap-w-[120px] ap-h-9 ap-p-2" />
</template>
