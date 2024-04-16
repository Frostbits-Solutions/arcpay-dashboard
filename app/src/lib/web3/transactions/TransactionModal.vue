<template>
<div class="transaction-modal" :key="reload">
  <choose-wallet
    v-if="web3Store.walletId === null"
    @wallet="setWalletId"/>

  <choose-account
    :accounts="web3Store.wallet.accounts"
    v-else-if="web3Store.account === null"
    @account="setAccount"/>

  <template v-else>
    <div class="flex-colum">
      <img :src="PROVIDER_ICONS[web3Store.account.providerId]">
      <div>{{getShortAddress(web3Store.account.address)}}</div>
    </div>
    <component
      :is="TRANSACTIONS_BUTTONS[conventionType][transactionType]"
      :account="web3Store.account"
      :parameters="parameters"
      @start="currentTransactionStep = 0"
      @next-step="currentTransactionStep++"
      @done="console.log"
      v-show="currentTransactionStep === null"
    />
    <TransactionStepsPreview
      :current-step="currentTransactionStep"
      :steps="TRANSACTIONS_STEPS[conventionType][transactionType]"
      v-if="currentTransactionStep !== null"
    />
  </template>

  <div class="change-parameters">
    <button @click="resetWallet">Change Wallet</button>
    <button @click="resetAddress">Change Address</button>
  </div>
</div>
</template>

<script setup lang="ts">
import type { PROVIDER_ID } from '@/lib/web3/constants'
import type { Account } from '@/lib/web3/types'
import type { TransactionParameters } from '@/lib/web3/types/transactions'
import type { Ref } from 'vue'

import ChooseWallet from '@/lib/web3/transactions/component/ChooseWallet.vue'
import ChooseAccount from '@/lib/web3/transactions/component/ChooseAccount.vue'
import {
  TRANSACTION_TYPE,
  CONVENTION_TYPE,
  TRANSACTIONS_BUTTONS,
  TRANSACTIONS_STEPS
} from '@/lib/web3/transactions/constants'
import { ref } from 'vue'
import { useWeb3Store } from '@/stores/web3.js'
import { PROVIDER, PROVIDER_ICONS } from '@/lib/web3/constants'
import TransactionStepsPreview from '@/lib/web3/transactions/component/TransactionStepsPreview.vue'

defineProps < {
  transactionType: TRANSACTION_TYPE,
  conventionType: CONVENTION_TYPE,
  parameters: TransactionParameters
  }> ()

const web3Store = useWeb3Store()
const reload = ref(0)
const currentTransactionStep: Ref<null | number> = ref(null)

async function setWalletId (_walletId: PROVIDER_ID) {
  const provider = await PROVIDER[_walletId].init()
  const wallet = await provider.connect(() => {})
  if (wallet.accounts.length === 0) {
    throw { message: 'account does not have any address'}
  } else if (wallet.accounts.length === 1) {
    setAccount(wallet.accounts[0])
  }
  web3Store.wallet = wallet
  web3Store.provider = provider
  web3Store.walletId = _walletId

  console.log(await provider.algodClient.status().do())
}

function setAccount (_account: Account) {
  web3Store.account = _account
}

function resetAddress () {
  localStorage.removeItem('gemsPayAccount')
  web3Store.account = null
  reload.value++
}

function resetWallet () {
  localStorage.removeItem('gemsPayWallet')
  web3Store.walletId = null
  resetAddress()
}

function getShortAddress (address: string): string {
  return `${address.slice(0,4)}...${address.slice(address.length - 5, address.length - 1)}`
}

</script>

<style scoped>
.transaction-modal {
  display: flex;
  flex-direction: column;
  align-items: center;
  border: 1px solid white;
  border-radius: 10px;
  padding: 10px;
  width: 100vw;
  height: 100vh;
  max-width: 400px;
  max-height: 600px;
  margin: auto;
  position: relative;
}

img {
  border-radius: 50%;
  width: 50px;
  height: 50px;
  grid-column: span 2;
  margin: auto;
}

.flex-colum {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.change-parameters {
  position: absolute;
  bottom: 0;
  padding: 5px;
}
</style>
