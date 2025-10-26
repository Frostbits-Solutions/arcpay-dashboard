<script setup lang="ts">
import { useDark } from '@vueuse/core'
import { Toaster } from '@repo/ui/toast'

useDark({
  selector: 'body',
  valueDark: 'dark',
})
</script>

<template>
  <RouterView />
  <Toaster />
</template>

<style scoped></style>
