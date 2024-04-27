<template>
<div class="space-y-6 border-t pt-8 dark:border-gray-700 text-center text-gray-700 dark:text-gray-200">
  <h2 class="font-bold text-lg">Done</h2>
  Tx id: {{information.txId}}<br>
  Confirmed round: {{information['confirmed-round']}}<br>
  <a :href="`https://voi.observer/explorer/transaction/${information.txId}`">See it on VOI explorer</a>
</div>
</template>

<script setup lang="ts">

defineProps < {
  information: object
 } > ()

</script>

<style scoped>

</style>
