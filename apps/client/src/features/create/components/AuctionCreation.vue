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
const duration = ref<number>(7);

const params = computed(() => {
  return {
    type: "auction",
    price: price.value,
    duration: duration.value * 24,
    currency: currencySelectorRef.value?.selectedCurrency,
  };
});

defineExpose({
  params,
});
</script>

<template>
  <div class="mt-2">
    <Label class="text-xs text-muted-foreground" for="price">Start price</Label>
    <div class="flex gap-1 items-center mt-2">
      <NumberField
        id="price"
        :format-options="{
          style: 'decimal',
          minimumFractionDigits: 2,
        }"
        :min="1"
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
  <div class="mt-2">
    <Label class="text-xs text-muted-foreground" for="duration">Duration</Label>
    <NumberField
      id="duration"
      :format-options="{
        style: 'unit',
        unit: 'day',
      }"
      :min="1"
      :model-value="duration"
      class="flex-1 mt-2"
      @update:modelValue="(value: number) => (duration = value)"
    >
      <NumberFieldContent>
        <NumberFieldDecrement />
        <NumberFieldInput />
        <NumberFieldIncrement />
      </NumberFieldContent>
    </NumberField>
  </div>
</template>

<style scoped></style>
