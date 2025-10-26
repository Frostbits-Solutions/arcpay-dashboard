<script lang="ts" setup>
import { computed, ref, watch } from 'vue'
import { CaretSortIcon, CheckIcon } from '@radix-icons/vue'
import defaultCurrencyIcon from '@repo/ui/assets/currency.svg'

import { cn } from '@repo/shared/utils'
import { Button } from '@repo/ui/button'
import { Command, CommandEmpty, CommandGroup, CommandInput, CommandItem, CommandList } from '@repo/ui/command'
import { Popover, PopoverContent, PopoverTrigger } from '@repo/ui/popover'
import { Skeleton } from '@repo/ui/skeleton'
import { type Database } from '@/lib/supabase/database.types'
import { getCurrencies } from '@/services/currencies'
import { errorHandler } from '@/lib/errorHandler'
import { supabase } from '@/lib/supabase/supabaseClient'

type Currency = Database['public']['Tables']['currencies']['Row']

const props = defineProps({
  network: {
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

const selectedCurrency = computed(() => {
  return currencies.value?.find((currency) => currency.ticker === value.value)
})
const open = ref(false)
const value = ref<string | undefined>(undefined)
const loading = ref(true)
const currencies = ref<Currency[]>([])

watch(
  () => [props.network, props.excludeCurrencyIds],
  async () => {
    loading.value = true
    value.value = undefined
    const { data, error } = await getCurrencies(supabase, props.network)
    if (!data || error) {
      errorHandler(error, `Unable to fetch currencies for ${props.network}.`)
    } else {
      currencies.value = data.filter((c) => !props.excludeCurrencyIds.includes(c.id))
    }
    loading.value = false
  },
  { immediate: true }
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
              v-for="currency in currencies?.filter((c: Currency) => !c.is_public)"
              :key="currency.id"
              :value="currency.ticker"
              @select="
                (e: CustomEvent) => {
                  if (typeof e.detail.value === 'string') {
                    value = e.detail.value
                    const selected = currencies?.find((c) => c.ticker === value)
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
