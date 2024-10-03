<script setup lang="ts">
import NavBar from '@/components/layout/NavBar.vue'
import SideBar from '@/components/layout/SideBar.vue'
import { onMounted } from 'vue'
import { useAccountsStore } from '@/stores/accounts'

onMounted (() => {
  const accounts = useAccountsStore()
  accounts.fetchAll()
})
</script>

<template>
  <NavBar/>
  <SideBar/>
  <router-view/>
</template>

<style scoped>

</style>