<script lang="ts" setup>
import CountUp from "vue-countup-v3";
import type { ListingParams } from "@/lib/app/reviewListing";
import { onMounted, ref, watch } from "vue";
import { ArrowRight, Users } from "lucide-vue-next";
import ListingStatusChip from "@/components/ListingReview/ListingStatusChip.vue";
import type { Database } from "@/lib/supabase/database.types";
import AssetThumbnail from "@/components/ListingReview/AssetThumbnail.vue";
import { formatPrice } from "@/lib/utils";

type Transaction = Database["public"]["Tables"]["transactions"]["Row"];

const props = defineProps<{
  listingParams: ListingParams;
  previewLink: string;
  presence: number;
  txs: Transaction[];
}>();
const emit = defineEmits<{
  "action:buy": [price: number];
}>();
const price = ref<number>(0);
const previousPrice = ref<number>(0);
const status = ref<typeof ListingStatusChip | undefined>();
const statusOverride = ref<string | undefined>();

function getLatestPrice() {
  if (
    props.listingParams &&
    props.listingParams.created_at &&
    props.listingParams.dutch_duration &&
    props.listingParams.dutch_max_price &&
    props.listingParams.dutch_min_price !== null
  ) {
    const startTime = new Date(props.listingParams.created_at).getTime();
    const endTime = startTime + props.listingParams.dutch_duration * 3_600_000;
    const max = props.listingParams.dutch_max_price;
    const min = props.listingParams.dutch_min_price;
    const ratio = parseFloat(((max - min) / (endTime - startTime)).toFixed(10));
    const now = Date.now() + new Date().getTimezoneOffset() * 60_000;
    const price = max - (now - startTime) * ratio;
    return price > min ? price : min;
  }
  return 0;
}

watch(
  () => props.txs,
  (value) => {
    value.map((tx) => {
      if (tx.type === "create") statusOverride.value = "active";
      if (tx.type === "buy") statusOverride.value = "closed";
      if (tx.type === "close") statusOverride.value = "closed";
      if (tx.type === "cancel") statusOverride.value = "cancelled";
    });
  },
  { deep: true },
);

onMounted(() => {
  price.value = getLatestPrice();
  setInterval(() => {
    previousPrice.value = price.value;
    price.value = getLatestPrice();
  }, 500);
});
</script>

<template>
  <div class="w-full sm:w-96">
    <h1 class="text-2xl text-foreground mr-1 truncate max-w-72 pl-2">
      {{ listingParams.name }}
    </h1>
    <div class="flex justify-between items-center">
      <div class="flex items-center g1 mt-1">
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
      <div class="flex items-center text-muted-foreground text-sm">
        {{ presence }}
        <Users class="w-4 h-4 text-muted-foreground mx-1" />
      </div>
    </div>
    <div class="flex justify-center mt-10 mb-16">
      <AssetThumbnail
        :listing-params="listingParams"
        :preview-link="previewLink"
      />
    </div>
    <button
      v-if="status?.status === 'active'"
      class="animated-button hover:shadow-[#e99796] hover:shadow-2xl mx-auto"
      @click="
        emit(
          'action:buy',
          formatPrice(price, listingParams.currency_decimals || undefined),
        )
      "
      v-motion-slide-bottom
    >
      <ArrowRight class="w-6 h-6 arr-2" />
      <span class="text flex items-center g1">
        Pay
        <div class="flex items-center">
          <span class="text-3xl font-extrabold tracking-tight">
            <count-up
              :decimalPlaces="2"
              :duration="1"
              :end-val="
                formatPrice(price, listingParams.currency_decimals || undefined)
              "
              :start-val="
                formatPrice(
                  previousPrice,
                  listingParams.currency_decimals || undefined,
                )
              "
            ></count-up>
          </span>
          <span class="ms-1 text-xl font-normal uppercase opacity-70">{{
            listingParams.currency_ticker
          }}</span>
        </div>
      </span>
      <span class="circle"></span>
      <ArrowRight class="w-6 h-6 arr-1" />
    </button>
  </div>
</template>

<style scoped></style>
