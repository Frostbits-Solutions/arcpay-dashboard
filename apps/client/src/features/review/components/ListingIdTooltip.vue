<script setup lang="ts">
import { useClipboard } from "@vueuse/core";
import { ref } from "vue";
import type { ListingParams } from "@/lib/app/reviewListing";
import { Button } from "@repo/ui/button";
import { Link2, Check } from "lucide-vue-next";

const props = defineProps<{ listingParams: ListingParams }>();

const source = ref<string>(props.listingParams?.id || "");
const { copy, copied, isSupported } = useClipboard({ source });
</script>

<template>
  <div
    v-if="isSupported"
    @click="copy(source)"
    class="w-full text-center absolute -bottom-12 left-0"
  >
    <Button variant="ghost" class="px-1 rounded h-6 text-muted-foreground/30">
      <Check v-if="copied" class="w-4 h-4 text-green-500 mr-1" />
      <Link2 v-else class="w-4 h-4 mr-1" />
      {{ source }}
    </Button>
  </div>
</template>
