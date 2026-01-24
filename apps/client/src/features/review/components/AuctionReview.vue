<script lang="ts" setup>
import CountUp from "vue-countup-v3";
import type { ListingParams } from "@/lib/app/reviewListing";
import {
  NumberField,
  NumberFieldContent,
  NumberFieldDecrement,
  NumberFieldIncrement,
  NumberFieldInput,
} from "@repo/ui/number-field";
import { computed, inject, onMounted, ref, watch } from "vue";
import ListingStatusChip from "@/components/ListingReview/ListingStatusChip.vue";
import { ArrowRight, LoaderCircle, Users, Crown } from "lucide-vue-next";
import type { Database } from "@/lib/supabase/database.types";
import { getTransactions } from "@/lib/supabase/transaction";
import type { SupabaseClient } from "@supabase/supabase-js";
import {
  formatAmountFromDecimals,
  formatPrice,
  getShortAddress,
} from "@/lib/utils";
import Jazzicon from "@/components/Jazzicon.vue";
import { ScrollArea } from "@repo/ui/scroll-area";
import AssetThumbnail from "@/components/ListingReview/AssetThumbnail.vue";

type Transaction = Database["public"]["Tables"]["transactions"]["Row"];

const client = inject<SupabaseClient>("supabase");
const props = defineProps<{
  listingParams: ListingParams;
  previewLink: string;
  presence: number;
  txs: Transaction[];
}>();
const emit = defineEmits<{ "action:buy": [price: number] }>();
const bid = ref<number>(props.listingParams.auction_start_price || 1);
const minbid = ref<number>(props.listingParams.auction_start_price || 1);
const transactions = ref<Transaction[]>([]);
const status = ref<typeof ListingStatusChip | undefined>();
const statusOverride = ref<string | undefined>();

const bids = computed(() => {
  return transactions.value
    .filter((tx) => tx.type === "bid")
    .sort((a, b) => (b.amount || 0) - (a.amount || 0));
});

const highestBid = computed(() => {
  return formatAmount(bids.value[0]?.amount) || 0;
});

function formatAmount(amount: number | null | undefined) {
  if (!amount) return 0;
  if (props.listingParams.currency_decimals === null) return amount;
  return parseFloat(
    formatAmountFromDecimals(
      amount,
      props.listingParams.currency_decimals,
    ).toFixed(2),
  );
}

watch(
  () => highestBid.value,
  (value) => {
    minbid.value = bid.value =
      value + (props.listingParams.auction_increment || 1);
  },
);

watch(
  () => props.txs,
  (value) => {
    transactions.value.splice(
      transactions.value.length - (value.length - 1),
      value.length,
      ...value,
    );
    value.map((tx) => {
      if (tx.type === "create") statusOverride.value = "active";
      if (tx.type === "close") statusOverride.value = "closed";
      if (tx.type === "cancel") statusOverride.value = "cancelled";
    });
  },
  { deep: true },
);

onMounted(async () => {
  if (client && props.listingParams.app_id) {
    const { data, error } = await getTransactions(
      client,
      props.listingParams.app_id,
    );
    if (data) {
      transactions.value = data;
      if (bids.value.length) {
        minbid.value = bid.value =
          highestBid.value + (props.listingParams.auction_increment || 1);
      }
    } else {
      console.error(error);
    }
  }
});
</script>

<template>
  <div class="w-full sm:w-[590px]">
    <h1 class="text-2xl text-foreground mr-1 truncate max-w-72 pl-2">
      {{ listingParams.name }}
    </h1>
    <div class="flex justify-between items-center">
      <div class="flex items-center gap-1 mt-1">
        <ListingStatusChip
          ref="status"
          :listing-params="listingParams"
          :override="statusOverride"
        />
        <div
          class="text-xs text-foreground bg-background/70 rounded-full px-2.5 py-1.5"
        >
          {{ listingParams.type }}
        </div>
        <div
          class="text-xs text-foreground bg-background/70 rounded-full px-2.5 py-1.5"
        >
          {{ listingParams.asset_type }}
        </div>
      </div>
      <div class="flex items-center text-muted-foreground text-sm mr-1">
        {{ presence }}
        <Users class="w-4 h-4 text-muted-foreground mx-1" />
      </div>
    </div>
  </div>
  <div
    class="mt-6 flex flex-col justify-between items-center sm:flex-row sm:items-stretch mb-10 gap-4"
  >
    <div class="flex items-center">
      <AssetThumbnail
        :listing-params="listingParams"
        :preview-link="previewLink"
      />
    </div>
    <div class="mt-2 w-72">
      <div class="flex items-baseline justify-between px-2">
        <span class="text-muted-foreground text-sm">History</span>
      </div>
      <ScrollArea class="h-[136px] px-2 py-1 mb-2">
        <ol v-if="bids.length" class="ml-4 border-l-2 border-border">
          <li
            v-for="(tx, index) in bids"
            :key="tx.id"
            class="py-2 flex items-center justify-between -ml-[11px] mr-0.5"
            v-motion-fade-visible-once
          >
            <div class="flex items-center w-full text-xs font-semibold gap-2">
              <Jazzicon
                :address="`0x${tx.from_address}`"
                :diameter="20"
                class="w-[20px] h-[20px] shadow rounded-full"
              />
              <div class="truncate text-muted-foreground">
                <div class="text-xs font-bold">
                  {{ getShortAddress(tx.from_address) }}
                </div>
              </div>
              <Crown v-if="!index" class="w-4 h-4 text-muted-foreground/50" />
            </div>
            <div class="shrink-0">
              <span class="font-bold mr-0.5">{{
                formatAmount(tx.amount)
              }}</span>
              <span class="uppercase text-muted-foreground text-xs">
                {{ listingParams.currency_ticker }}
              </span>
            </div>
          </li>
        </ol>
        <div
          v-else
          class="h-[120px] text-md text-muted-foreground/50 text-center flex items-center justify-center gap-1"
        >
          <LoaderCircle class="w-5 h-5 text-muted-foreground/50 animate-spin" />
          No bids yet
        </div>
      </ScrollArea>
      <div v-if="status?.status === 'active'">
        <span class="text-muted-foreground text-sm">Your bid</span>
        <NumberField
          id="bidMin"
          :format-options="{
            style: 'decimal',
            minimumFractionDigits: 2,
          }"
          :min="minbid"
          :model-value="bid"
          @update:modelValue="(value: number) => (bid = value)"
        >
          <NumberFieldContent>
            <NumberFieldDecrement />
            <NumberFieldInput class="text-lg font-bold h-10" />
            <NumberFieldIncrement />
          </NumberFieldContent>
        </NumberField>
      </div>
    </div>
  </div>
  <button
    v-if="status?.status === 'active'"
    class="animated-button hover:shadow-[#e99796] hover:shadow-2xl mx-auto"
    @click="
      emit(
        'action:buy',
        formatPrice(bid, listingParams.currency_decimals || undefined),
      )
    "
    v-motion-slide-bottom
  >
    <ArrowRight class="w-6 h-6 arr-2" />
    <span class="text flex items-center gap-1">
      Bid
      <div class="flex items-center">
        <span class="text-3xl font-extrabold tracking-tight">
          <count-up
            :decimalPlaces="2"
            :duration="1"
            :end-val="
              formatPrice(bid, listingParams.currency_decimals || undefined)
            "
          ></count-up>
        </span>
        <span class="ms-1 text-xl font-normal uppercase opacity-70">
          {{ listingParams.currency_ticker }}
        </span>
      </div>
    </span>
    <span class="circle"></span>
    <ArrowRight class="w-6 h-6 arr-1" />
  </button>
  <button
    v-if="status?.status === 'ended'"
    class="animated-button hover:shadow-[#e99796] hover:shadow-2xl mx-auto"
    @click="emit('action:buy', -1)"
    v-motion-slide-bottom
  >
    <ArrowRight class="w-6 h-6 arr-2" />
    <span class="text flex items-center gap-1">
      <span class="text-lg tracking-tight"> Close auction </span>
    </span>
    <span class="circle"></span>
    <ArrowRight class="w-6 h-6 arr-1" />
  </button>
</template>

<style scoped></style>
