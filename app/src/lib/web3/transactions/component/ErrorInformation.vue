<template>
  <div>
    <h2>Error</h2>
    <div v-if="information.message">
      {{information.message}}
      <p v-id="information.code">
        Error Code: {{information.code}}
      </p>
    </div>
    <div v-else>
      {{information}}
    </div>
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
