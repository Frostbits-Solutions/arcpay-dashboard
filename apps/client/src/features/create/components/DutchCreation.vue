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
const priceMin = ref<number>(1);
const priceMax = ref<number>(100);
const duration = ref<number>(7);

const params = computed(() => {
  return {
    type: "dutch",
    priceMin: priceMin.value,
    priceMax: priceMax.value,
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
    <Label class="text-xs text-muted-foreground" for="priceMin"
      >Price range</Label
    >
    <div class="flex gap-1 items-top mt-2 w-[333px]">
      <div>
        <div class="flex items-center gap-2">
          <span class="text-xs text-muted-foreground/50">Min</span>
          <NumberField
            id="priceMin"
            :format-options="{
              style: 'decimal',
              minimumFractionDigits: 2,
            }"
            :min="1"
            :model-value="priceMin"
            class="flex-1"
            @update:modelValue="
              (value: number) => {
                priceMin = value;
                if (priceMax <= priceMin) {
                  priceMax = priceMin + 1;
                }
              }
            "
          >
            <NumberFieldContent>
              <NumberFieldDecrement />
              <NumberFieldInput />
              <NumberFieldIncrement />
            </NumberFieldContent>
          </NumberField>
        </div>
        <div class="flex items-center gap-1 mt-1">
          <span class="text-xs text-muted-foreground/50">Max</span>
          <NumberField
            id="priceMax"
            :format-options="{
              style: 'decimal',
              minimumFractionDigits: 2,
            }"
            :min="priceMin + 1"
            :model-value="priceMax"
            class="flex-1"
            @update:modelValue="(value: number) => (priceMax = value)"
          >
            <NumberFieldContent>
              <NumberFieldDecrement />
              <NumberFieldInput />
              <NumberFieldIncrement />
            </NumberFieldContent>
          </NumberField>
        </div>
      </div>
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
