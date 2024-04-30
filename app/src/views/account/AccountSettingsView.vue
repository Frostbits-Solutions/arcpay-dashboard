<script setup lang="ts">
import { useAccountsStore } from '@/stores/accounts'
import AccountSettingsCard from '@/components/account/AccountSettingsCard.vue'
import { nextTick, onMounted, ref, watch } from 'vue'
import { getAccount, getAccountAddresses, getAccountApiKeys, getAccountUsers } from '@/lib/supabase/accounts'
import IconPlus from '@/components/icons/IconPlus.vue'
import ModalAccountAddUser from '@/components/account/ModalAccountAddUser.vue'
import { useModalsStore } from '@/stores/modals'
import IconTrash from '@/components/icons/IconTrash.vue'
import ModalAccountAddKey from '@/components/account/ModalAccountAddKey.vue'
import ClipboardInput from '@/components/common/InputClipboard.vue'
import IconLink from '@/components/icons/IconLink.vue'
import ModalAccountLinkAddress from '@/components/account/ModalAccountLinkAddress.vue'
import type { Database } from '@/lib/supabase/database.types'
import ModalSecondaryMarketFees from '@/components/account/ModalSecondaryMarketFees.vue'

interface AccountData {
  settings?: Database["public"]["Tables"]["accounts"]["Row"] | null
  users?: {
    role: Database["public"]["Tables"]["accounts_users_association"]["Row"]["role"],
    user_email: Database["public"]["Tables"]["accounts_users_association"]["Row"]["user_email"],
    created_at: Database["public"]["Tables"]["accounts_users_association"]["Row"]["created_at"],
  }[] | null
  keys?: Database["public"]["Tables"]["accounts_api_keys"]["Row"][] | null
  addresses?: Database["public"]["Tables"]["accounts_addresses"]["Row"][] | null
}

const accounts = useAccountsStore()
const modals = useModalsStore()
const data = ref<AccountData>({})

async function fetchAccountSettings() {
  if (typeof accounts.active?.id === 'number') {
    const { data: settings, error } = await getAccount(accounts.active?.id)
    if (!settings || error) {
      console.error(error)
    } else {
      data.value['settings'] = settings
    }
  }
}

async function fetchAccountUsers() {
  if (typeof accounts.active?.id === 'number') {
    const { data: users, error } = await getAccountUsers(accounts.active?.id)
    if (!users || error) {
      console.error(error)
    } else {
      data.value['users'] = users
    }
  }
}

async function fetchAccountKeys() {
  if (typeof accounts.active?.id === 'number') {
    const { data: keys, error } = await getAccountApiKeys(accounts.active?.id)
    if (!keys || error) {
      console.error(error)
    } else {
      data.value['keys'] = keys
    }
  }
}

async function fetchAccountAddresses() {
  if (typeof accounts.active?.id === 'number') {
    const { data: addresses, error } = await getAccountAddresses(accounts.active?.id)
    if (!addresses || error) {
      console.error(error)
    } else {
      data.value['addresses'] = addresses
    }
  }
}

watch(() => accounts.active,() => {
  data.value = {}
  fetchAccountSettings()
  fetchAccountUsers()
  fetchAccountKeys()
  fetchAccountAddresses()
})

onMounted(() => {
  nextTick(() => {
    fetchAccountSettings()
    fetchAccountUsers()
    fetchAccountKeys()
    fetchAccountAddresses()
  })
})
</script>

<template>
  <main class="min-h-dvh pl-16 pt-16">
    <div class="max-w-screen-xl mx-auto p-10">
      <h4 class="text-2xl font-bold dark:text-white">Organization settings</h4>

      <!-- account details -->
      <AccountSettingsCard>
        <template #title>Organization name</template>
        <template #body>
          <div class="relative my-4">
            <input id="account-name" type="text" class="col-span-6 bg-gray-50 border border-gray-300 text-gray-500 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-800 dark:border-gray-600 dark:placeholder-gray-400 dark:text-gray-400 dark:focus:ring-blue-500 dark:focus:border-blue-500" :value="accounts?.active?.name" disabled readonly>
          </div>
        </template>
      </AccountSettingsCard>

      <!-- account members -->
      <AccountSettingsCard>
        <template #title>Users</template>
        <template #description>Users can login to the organization's account to create and manage listings. Only owner and admins can change the organization settings.</template>
        <template #body>
          <div class="relative">
            <div class="flex items-center justify-between pb-4">
              <div class="flex items-center justify-between flex-column flex-wrap md:flex-row space-y-4 md:space-y-0">
                <label for="table-search" class="sr-only">Search</label>
                <div class="relative">
                  <div class="absolute inset-y-0 rtl:inset-r-0 start-0 flex items-center ps-3 pointer-events-none">
                    <svg class="w-4 h-4 text-gray-500 dark:text-gray-400" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 20 20">
                      <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m19 19-4-4m0-7A7 7 0 1 1 1 8a7 7 0 0 1 14 0Z"/>
                    </svg>
                  </div>
                  <input type="text" id="table-search-users" class="block p-2 ps-10 text-sm text-gray-900 border border-gray-300 rounded-lg w-80 bg-gray-50 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-800 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" placeholder="Search for users">
                </div>
              </div>
              <button @click="modals.showModal('ModalAccountAddUser')" type="button" class="flex items-center text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-xs px-3 py-2.5 me-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800"><IconPlus class="mr-2 w-4 h-4"/> Add User</button>
            </div>
            <div class="shadow-sm rounded-lg border border-gray-200 dark:border-gray-700 overflow-hidden">
              <table class="w-full text-sm text-left rtl:text-right text-gray-700 dark:text-gray-400">
                <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-800 dark:text-gray-400">
                <tr>
                  <th scope="col" class="px-6 py-3">
                    Email
                  </th>
                  <th scope="col" class="px-6 py-3">
                    Role
                  </th>
                </tr>
                </thead>
                <tbody>
                <tr v-if="data.settings" class="border-b last:border-b-0 dark:border-gray-700">
                  <td class="px-6 py-4">
                    {{ data.settings.owner_email }}
                  </td>
                  <td class="px-6 py-4">
                    <span class="bg-red-100 text-red-800 text-xs font-medium me-2 px-2.5 py-0.5 rounded-full dark:bg-red-900 dark:text-red-300">Owner</span>
                  </td>
                </tr>
                <tr v-for="user in data.users" :key="user.user_email" class="border-b last:border-b-0 dark:border-gray-700">
                  <td class="px-6 py-4">
                    {{ user.user_email }}
                  </td>
                  <td class="px-6 py-4">
                    <span v-if="user.role === 'admin'" class="bg-yellow-100 text-yellow-800 text-xs font-medium me-2 px-2.5 py-0.5 rounded-full dark:bg-yellow-900 dark:text-yellow-300">Admin</span>
                    <span v-if="user.role === 'member'" class="bg-green-100 text-green-800 text-xs font-medium me-2 px-2.5 py-0.5 rounded-full dark:bg-green-900 dark:text-green-300">Member</span>
                  </td>
                </tr>
                <tr v-if="!data.users">
                  <td class="px-6 py-4">
                    <div class="h-4 bg-gray-200 rounded-full dark:bg-gray-700 w-48 animate-pulse"></div>
                  </td>
                  <td class="px-6 py-4">
                    <div class="h-5 bg-gray-200 rounded-full dark:bg-gray-700 w-16 animate-pulse"></div>
                  </td>
                </tr>
                </tbody>
              </table>
            </div>
          </div>
        </template>
      </AccountSettingsCard>

      <!-- account API keys -->
      <AccountSettingsCard>
        <template #title>API Keys</template>
        <template #description>API keys can be used for advanced integration to interact with our API.<br> To help prevent malicious use of your keys, you are strongly encouraged to only allow specific origins. HTTP requests that don't have a matching Origin header will be blocked.</template>
        <template #body>
          <div class="relative">
            <div class="flex items-center justify-between pb-4">
              <div></div>
              <button @click="modals.showModal('ModalAccountAddKey')" type="button" class="flex items-center text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-xs px-3 py-2.5 me-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800"><IconPlus class="mr-2 w-4 h-4"/> Create new key</button>
            </div>
            <div class="shadow-sm rounded-lg border border-gray-200 dark:border-gray-700 overflow-hidden">
              <table class="w-full text-sm text-left rtl:text-right text-gray-700 dark:text-gray-400">
                <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-800 dark:text-gray-400">
                <tr>
                  <th scope="col" class="px-6 py-3">
                    Key
                  </th>
                  <th scope="col" class="px-6 py-3">
                    Allowed Origin
                  </th>
                  <th scope="col" class="px-6 py-3">
                    Name
                  </th>
                  <th scope="col" class="px-6 py-3 w-16">
                    Delete
                  </th>
                </tr>
                </thead>
                <tbody>
                <tr v-for="key in data.keys" :key="key.key" class="border-b last:border-b-0 dark:border-gray-700">
                  <td class="px-6 py-4">
                    <ClipboardInput :id="key.key" :value="key.key" class="min-w-64"/>
                  </td>
                  <td class="px-6 py-4 truncate">
                    {{ key.origin }}
                  </td>
                  <td class="px-6 py-4 truncate">
                    {{ key.name }}
                  </td>
                  <td class="px-6 py-4 w-16">
                    <button type="button" class="bg-red-100 text-red-700 focus:ring-4 focus:outline-none focus:ring-red-300 font-medium rounded-lg text-sm p-2 text-center inline-flex items-center me-2 dark:bg-red-900/50 dark:text-red-400 dark:focus:ring-red-800">
                      <IconTrash class="w-4 h-4 "/>
                      <span class="sr-only">Delete</span>
                    </button>
                  </td>
                </tr>
                <tr v-if="!data.keys?.length">
                  <td colspan="4" class="px-6 py-4 text-center text-sm text-gray-500">
                    No API key found
                  </td>
                </tr>
                <tr v-if="!data.keys">
                  <td class="px-6 py-4">
                    <div class="h-4 bg-gray-200 rounded-full dark:bg-gray-700 w-48 animate-pulse"></div>
                  </td>
                  <td class="px-6 py-4">
                    <div class="h-4 bg-gray-200 rounded-full dark:bg-gray-700 w-48 animate-pulse"></div>
                  </td>
                  <td class="px-6 py-4">
                    <div class="h-4 bg-gray-200 rounded-full dark:bg-gray-700 w-28 animate-pulse"></div>
                  </td>
                  <td class="px-6 py-4">
                    <div class="h-5 bg-gray-200 rounded-full dark:bg-gray-700 w-8 animate-pulse"></div>
                  </td>
                </tr>
                </tbody>
              </table>
            </div>
          </div>
        </template>
      </AccountSettingsCard>

      <!-- account addresses -->
      <AccountSettingsCard>
        <template #title>Primary Addresses</template>
        <template #description>Link primary accounts to your organization to create listings. Listings made from non linked accounts will be considered secondary listings.</template>
        <template #body>
          <div class="relative">
            <div class="flex items-center justify-between pb-4">
              <div></div>
              <div class="flex gap-0.5">
                <button @click="modals.showModal('ModalSecondaryMarketFees')" type="button" class="flex items-center text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-xs px-3 py-2.5 me-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800"><IconPlus class="mr-2 w-4 h-4"/> Add fees</button>
                <button @click="modals.showModal('ModalAccountLinkAddress')" type="button" class="flex items-center text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-xs px-3 py-2.5 me-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800"><IconLink class="mr-2 w-4 h-4"/> Link address</button>
              </div>
               </div>
            <div class="shadow-sm rounded-lg border border-gray-200 dark:border-gray-700 overflow-hidden">
              <table class="w-full text-sm text-left rtl:text-right text-gray-700 dark:text-gray-400">
                <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-800 dark:text-gray-400">
                <tr>
                  <th scope="col" class="px-6 py-3 max-w-32">
                    Address
                  </th>
                  <th scope="col" class="px-6 py-3">
                    Name
                  </th>
                  <th scope="col" class="px-6 py-3 w-16">
                    Unlink
                  </th>
                </tr>
                </thead>
                <tbody>
                <tr v-for="address in data.addresses" :key="address.address" class="border-b last:border-b-0 dark:border-gray-700">
                  <td class="px-6 py-4 max-w-32">
                    <ClipboardInput :id="address.address" :value="address.address" class="min-w-64"/>
                  </td>
                  <td class="px-6 py-4 truncate">
                    {{ address.name }}
                  </td>
                  <td class="px-6 py-4 w-16">
                    <button type="button" class="bg-red-100 text-red-700 focus:ring-4 focus:outline-none focus:ring-red-300 font-medium rounded-lg text-sm p-2 text-center inline-flex items-center me-2 dark:bg-red-900/50 dark:text-red-400 dark:focus:ring-red-800">
                      <IconTrash class="w-4 h-4"/>
                      <span class="sr-only">Unlink</span>
                    </button>
                  </td>
                </tr>
                <tr v-if="!data.addresses?.length">
                  <td colspan="4" class="px-6 py-4 text-center text-sm text-gray-500">
                    No addresses linked
                  </td>
                </tr>
                <tr v-if="!data.addresses">
                  <td class="px-6 py-4">
                    <div class="h-4 bg-gray-200 rounded-full dark:bg-gray-700 w-48 animate-pulse"></div>
                  </td>
                  <td class="px-6 py-4">
                    <div class="h-4 bg-gray-200 rounded-full dark:bg-gray-700 w-48 animate-pulse"></div>
                  </td>
                  <td class="px-6 py-4">
                    <div class="h-4 bg-gray-200 rounded-full dark:bg-gray-700 w-28 animate-pulse"></div>
                  </td>
                  <td class="px-6 py-4">
                    <div class="h-5 bg-gray-200 rounded-full dark:bg-gray-700 w-8 animate-pulse"></div>
                  </td>
                </tr>
                </tbody>
              </table>
            </div>
          </div>
        </template>
      </AccountSettingsCard>
    </div>
    <ModalAccountAddUser @success="fetchAccountUsers"/>
    <ModalAccountAddKey @success="fetchAccountKeys"/>
    <ModalAccountLinkAddress @success="fetchAccountAddresses"/>
    <ModalSecondaryMarketFees/>
  </main>
</template>

<style scoped>

</style>