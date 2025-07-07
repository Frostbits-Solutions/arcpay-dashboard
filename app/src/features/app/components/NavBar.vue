<script setup lang="ts">
import OrganizationSelectionPopover from '@/features/accounts/components/OrganizationSelectionPopover.vue'
import NetworkPopover from '@/features/networks/components/NetworkPopover.vue'
</script>

<template>
  <nav class="left-O fixed top-0 z-20 box-border flex w-full flex-wrap items-center justify-between border-b border-border bg-background py-4 pl-20 pr-4">
    <OrganizationSelectionPopover />
    <NetworkPopover />
  </nav>
</template>

<style scoped></style>
