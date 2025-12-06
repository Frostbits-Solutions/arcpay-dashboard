<script lang="ts" setup>
import {
  NumberField,
  NumberFieldContent,
  NumberFieldDecrement,
  NumberFieldIncrement,
  NumberFieldInput,
} from "@repo/ui/number-field";
import { Label } from "@repo/ui/label";
import CurrencySelectionCombobox from "@/components/ListingCreation/CurrencySelectionCombobox.vue";
import { computed, ref } from "vue";

const currencySelectorRef = ref<typeof CurrencySelectionCombobox | null>(null);
const price = ref<number>(100);

const params = computed(() => {
  return {
    type: "sale",
    price: price.value,
    currency: currencySelectorRef.value?.selectedCurrency,
  };
});

defineExpose({
  params,
});
</script>

<template>
  <div class="mt-2">
    <Label class="mb-1 text-xs text-muted-foreground" for="price"
      >Asking price</Label
    >
    <div class="flex g1 items-center mt-2">
      <NumberField
        id="price"
        :format-options="{
          style: 'decimal',
          minimumFractionDigits: 2,
        }"
        :model-value="price"
        class="flex-1"
        @update:modelValue="(value: number) => (price = value)"
      >
        <NumberFieldContent>
          <NumberFieldDecrement />
          <NumberFieldInput />
          <NumberFieldIncrement />
        </NumberFieldContent>
      </NumberField>
      <CurrencySelectionCombobox ref="currencySelectorRef" />
    </div>
  </div>
</template>

<style scoped></style>
