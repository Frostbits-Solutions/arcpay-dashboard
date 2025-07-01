<script setup lang="ts">
import NavBar from '@/features/app/components/NavBar.vue'
import SideBar from '@/features/app/components/SideBar.vue'
import { onMounted } from 'vue'
import { useAccountsStore } from '@/features/app/stores/accounts'

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