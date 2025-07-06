<script setup lang="ts">
import OrganizationSettingsListingsAddress from './OrganizationSettingsListingsAddress.vue'
import OrganizationSettingsListingsSecondary from './OrganizationSettingsListingsSecondary.vue'
</script>

<template>
  <div>
    <h2 class="text-2xl font-bold dark:text-white">Listings</h2>
    <div class="relative mt-6">
      <OrganizationSettingsListingsSecondary />
      <OrganizationSettingsListingsAddress />
    </div>
  </div>
</template>

<style scoped></style>
