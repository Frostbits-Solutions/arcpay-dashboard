<script lang="ts" setup>
import { ErrorMessage } from 'vee-validate'
import { toValue } from 'vue'
import { useFormField } from './useFormField'

const { name, formMessageId } = useFormField()
import { CircleX } from 'lucide-vue-next'
</script>

<template>
  <ErrorMessage :id="formMessageId" as="p" :name="toValue(name)" class="text-destructive text-[0.8rem] font-medium" v-slot="{ message }">
    <div class="flex items-center gap-0.5">
      <CircleX class="h-4 w-4" />
      {{ message }}
    </div>
  </ErrorMessage>
</template>
