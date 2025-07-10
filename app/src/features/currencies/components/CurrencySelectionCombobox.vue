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
  excludeCurrencyIds: {
    type: Array as () => number[],
    default: () => [],
  },
})

const emit = defineEmits<{
  (e: 'select', currency: Currency): void
}>()

const currencyStore = useCurrenciesStore()
const currencies = computed(() => currencyStore.list.filter((c) => !props.excludeCurrencyIds.includes(c.id)))
const selectedCurrency = computed(() => {
  return currencies.value.find((currency) => currency.ticker === value.value)
})
const open = ref(false)
const value = ref<string | undefined>(undefined)
const loading = ref(true)

watch(
  () => props,
  () => {
    loading.value = true
    currencyStore.fetchCurrencies(props.activeChain)
    loading.value = false
  },
  { immediate: true, deep: true }
)
</script>

<template>
  <Popover v-if="!loading" v-model:open="open">
    <PopoverTrigger as-child>
      <Button :aria-expanded="open" class="w-[160px] justify-between p-3" role="combobox" size="lg" variant="outline">
        <template v-if="!selectedCurrency"> Select currency </template>
        <template v-else-if="selectedCurrency">
          <div class="flex min-w-0 items-center gap-1 px-1">
            <img :alt="`${selectedCurrency.ticker} icon`" :src="selectedCurrency?.icon || defaultCurrencyIcon" class="h-5 w-5 rounded-full bg-border" />
            <div class="min-w-0 text-xs text-muted-foreground">
              <div class="truncate font-semibold text-foreground">
                {{ selectedCurrency.ticker.toUpperCase() }}
              </div>
            </div>
          </div>
        </template>
        <CaretSortIcon class="ml-2 h-4 w-4 shrink-0 opacity-50" />
      </Button>
    </PopoverTrigger>

    <PopoverContent align="end" class="h-[250px] w-[334px] p-0" side="bottom">
      <Command>
        <CommandInput placeholder="Search by ticker" />
        <CommandEmpty>No currency found.</CommandEmpty>
        <CommandList>
          <CommandGroup class="w-[327px]">
            <CommandItem
              v-for="currency in currencies.filter((c: Currency) => !c.is_public)"
              :key="currency.id"
              :value="currency.ticker"
              @select="
                (e: CustomEvent) => {
                  if (typeof e.detail.value === 'string') {
                    value = e.detail.value
                    const selected = currencies.find((c) => c.ticker === value)
                    if (selected) {
                      emit('select', selected)
                    }
                  }
                  open = false
                }
              "
            >
              <div class="flex min-w-0 items-center gap-1">
                <img :alt="`${currency.ticker} icon`" :src="currency?.icon || defaultCurrencyIcon" class="h-5 w-5 rounded-full bg-border" />
                <div class="min-w-0 text-xs text-muted-foreground">
                  <div class="truncate font-semibold text-foreground">
                    {{ currency.ticker.toUpperCase() }}
                  </div>
                  ID: {{ currency.id }}
                </div>
              </div>
              <CheckIcon :class="cn('ml-auto h-4 w-4', value === currency.ticker ? 'opacity-100' : 'opacity-0')" />
            </CommandItem>
          </CommandGroup>
        </CommandList>
      </Command>
    </PopoverContent>
  </Popover>

  <Skeleton v-else class="h-9 w-[120px] p-2" />
</template>
