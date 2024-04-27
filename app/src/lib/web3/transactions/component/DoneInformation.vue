<template>
<div>
  done
  Tx id: {{information.txId}}<br>
  Confirmed round: {{information.confirmed-round}}<br>
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
