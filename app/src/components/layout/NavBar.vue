<script setup lang="ts">
import OrganizationSelectionPopover from '@/components/organization/OrganizationSelectionPopover.vue'
import NetworkPopover from '@/components/layout/NetworkPopover.vue'
</script>

<template>
  <nav class="bg-background flex flex-wrap items-center justify-between fixed w-full z-20 top-0 left-O pl-20 py-4 pr-4 border-b border-border box-border">
    <OrganizationSelectionPopover/>
    <NetworkPopover/>
  </nav>
</template>

<style scoped>

</style>