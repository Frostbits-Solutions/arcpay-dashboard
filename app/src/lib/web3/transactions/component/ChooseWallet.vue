<template>
<div>
<button v-for="provider of providers" @click="() => chooseWallet(provider.providerId)">
  <img :src="provider.icon">
  <p>{{provider.name}}</p>
</button>
</div>
</template>

<script setup lang="ts">
import { PROVIDER_ID, PROVIDER_ICONS } from '@/lib/web3/constants'

const emit = defineEmits(['wallet'])

const providers =
  Object.values(PROVIDER_ID)
    .map((id) => {
      return {
        providerId: id,
        name: id,
        icon: PROVIDER_ICONS[id]
      }
    }) ;

function chooseWallet (wallet: string) {
  emit('wallet', wallet)
}
</script>

<style scoped>
img {
  border-radius: 50%;
  width: 50px;
  height: 50px;
  object-fit: cover;
}

button {
  border: none;
  background: transparent;
}
</style>
