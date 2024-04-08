<template>
<div class="flex-column">
  <button v-for="account of accounts" @click="() => emits('account', account)">
    {{getShortAddress(account.address)}}
  </button>
</div>
</template>

<script setup lang="ts">
import type { Account } from '@/lib/web3/types'

defineProps<{ accounts: Account[]}>()
const emits = defineEmits(['account'])

function getShortAddress (address: string) {
  return `${address.slice(0,10)}...${address.slice(address.length-3)}`
}
</script>

<style scoped>
.flex-column {
  display: flex;
  flex-direction: column;
}
</style>
