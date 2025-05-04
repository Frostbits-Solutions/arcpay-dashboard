<script setup lang="ts">
import NavBar from '@/features/shared/components/NavBar.vue'
import SideBar from '@/features/shared/components/SideBar.vue'
import { onMounted } from 'vue'
import { useAccountsStore } from '@/features/shared/stores/accounts'

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