<template>
<div class="space-y-6 border-t pt-8 dark:border-gray-700 text-center text-gray-700 dark:text-gray-200">
  <button v-for="account of accounts" @click="() => chooseAccount(account)">
    {{getShortAddress(account.address)}}
  </button>
</div>
</template>

<script setup lang="ts">
import type { Account } from '@/lib/web3/types'
import { onMounted } from 'vue'

defineProps<{ accounts: Account[]}>()
const emits = defineEmits(['account'])

function getShortAddress (address: string) {
  return `${address.slice(0,10)}...${address.slice(address.length-3)}`
}

function chooseAccount (account: Account) {
  localStorage.setItem('gemsPayAccount', JSON.stringify(account))
  emits('account', account)
}

function onMountedHook () {
  const acc = localStorage.getItem('gemsPayAccount')
  if (acc) {
    const t = JSON.parse(acc)
    emits('account', t)
  }
}

// @ts-ignore
onMounted(onMountedHook)
</script>

<style scoped>
.flex-column {
  display: flex;
  flex-direction: column;
}
</style>
