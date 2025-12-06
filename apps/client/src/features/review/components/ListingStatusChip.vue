<script lang="ts" setup>
import type { ListingParams } from "@/lib/app/reviewListing";
import { computed } from "vue";

const props = defineProps<{
  listingParams: ListingParams;
  override?: string;
}>();

const status = computed(() => {
  if (props.override) return props.override;
  if (
    props.listingParams.created_at &&
    props.listingParams.auction_duration &&
    props.listingParams.status &&
    props.listingParams.status !== "closed"
  ) {
    const now = Date.now();
    const endTime =
      new Date(props.listingParams.created_at).getTime() +
      new Date().getTimezoneOffset() * 60_000 +
      props.listingParams.auction_duration * 3_600_000;
    return now < endTime ? props.listingParams.status : "ended";
  }
  return props.listingParams.status || "pending";
});

defineExpose({
  status,
});
</script>

<template>
  <div>
    <span
      v-if="['pending'].includes(status)"
      class="inline-flex items-center bg-gray-100 text-gray-800 text-xs font-medium px-2.5 py-1.5 rounded-full dark:bg-gray-700 dark:text-gray-300"
    >
      <span class="w-2 h-2 me-1 bg-gray-500 rounded-full"></span>
      {{ status }}
    </span>
    <span
      v-if="['active'].includes(status)"
      class="inline-flex items-center bg-purple-100/60 text-purple-800 text-xs font-medium px-2.5 py-1.5 rounded-full dark:bg-purple-900 dark:text-purple-300 relative"
    >
      <span class="w-2 h-2 me-1 bg-purple-500 rounded-full animate-ping"></span>
      <span
        class="w-1.5 h-1.5 ml-[1px] bg-purple-500 rounded-full absolute"
      ></span>
      {{ status }}
    </span>
    <span
      v-if="['closed', 'ended'].includes(status)"
      class="inline-flex items-center bg-green-100 text-green-800 text-xs font-medium px-2.5 py-1.5 rounded-full dark:bg-green-900 dark:text-green-300"
    >
      <span class="w-2 h-2 me-1 bg-green-500 rounded-full"></span>
      {{ status }}
    </span>
    <span
      v-if="['cancelled'].includes(status)"
      class="inline-flex items-center bg-red-100 text-red-800 text-xs font-medium px-2.5 py-1.5 rounded-full dark:bg-red-900 dark:text-red-300"
    >
      <span class="w-2 h-2 me-1 bg-red-500 rounded-full"></span>
      {{ status }}
    </span>
  </div>
</template>

<style scoped></style>
