<script setup lang="ts">
import { useRoute } from 'vue-router'
import { onMounted } from 'vue'
import { useNetworksStore } from '@/features/networks/stores/networks'

const route = useRoute()
const networks = useNetworksStore()

onMounted(() => {
  const network = route.query.network as string
  const darkMode = route.query.dark === 'true'

  if (network) {
    networks.setActive(network, false)
  }
})
</script>

<template></template>

<style scoped></style>
