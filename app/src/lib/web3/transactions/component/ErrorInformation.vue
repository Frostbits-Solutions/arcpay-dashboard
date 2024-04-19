<template>
  <div>
    <h2>Error</h2>
    {{information}}
  </div>
</template>

<script setup lang="ts">
const p = defineProps < {
  information: object
} > ()

console.error(p.information)
</script>

<style scoped>

</style>
