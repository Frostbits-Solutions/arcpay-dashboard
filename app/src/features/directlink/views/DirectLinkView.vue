<script lang="ts" setup>
import type { Chain } from '@/models'
import { onMounted } from 'vue'
import { createClient } from 'arcpay-sdk'
import { useDark } from '@vueuse/core'

const props = defineProps<{ id: string, chain: Chain }>()
const arcpay = createClient(props.chain, {
  apiKey: import.meta.env.VITE_ARCPAY_API_KEY
})

const isDark = useDark()

onMounted(() => {
  arcpay.toggleDarkMode(isDark.value)
  arcpay.buy(props.id)
})
</script>

<template>
  <div class="flex justify-center items-center h-screen">
    <div>
      <div class="m-auto w-fit flex items-center relative">
        <img class="w-8 h-8" src="/src/assets/logo.png" >
        <h1 class="ml-2 text-2xl text-foreground">Arcpay</h1>
        <span class="text-lg text-muted-foreground uppercase ml-1 mt-0.5"> | Direct link</span>
      </div>
      <div class="text-xs text-muted-foreground/50 text-center mt-4">
        ID: {{ id }}
      </div>
    </div>
  </div>
</template>

<style scoped>

</style>