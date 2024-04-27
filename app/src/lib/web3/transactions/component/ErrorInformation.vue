<template>
  <div class="space-y-6 border-t pt-8 dark:border-gray-700 text-center text-gray-700 dark:text-gray-200">
    <h2 class="font-bold text-lg text-red-700">Error</h2>
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
