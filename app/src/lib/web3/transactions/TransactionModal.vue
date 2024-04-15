<template>
<div class="transaction-modal" :key="reload">
  <choose-wallet
    v-if="web3Store.walletId === null"
    @wallet="setWalletId"/>
  <choose-account
    :accounts="web3Store.wallet.accounts"
    v-else-if="web3Store.account === null"
    @account="setAccount"/>
  <AlgoARC72Transactions
    v-else-if="conventionType === CONVENTION_TYPE.AlgoARC72"
    :account="web3Store.account"
    :transaction="transactionType"
  />
  <div>
    <button @click="resetWallet">Change Wallet</button>
    <button @click="resetAddress">Change Address</button>
  </div>
</div>
</template>

<script setup lang="ts">
import { useWeb3Store } from '@/stores/web3.js'
import ChooseWallet from '@/lib/web3/transactions/component/ChooseWallet.vue'
import type { PROVIDER_ID } from '@/lib/web3/constants'
import type { Account } from '@/lib/web3/types'
import ChooseAccount from '@/lib/web3/transactions/component/ChooseAccount.vue'
import Provider from '@/lib/web3'
import { TRANSACTION_TYPE, CONVENTION_TYPE } from '@/lib/web3/transactions/constants'
import AlgoARC72Transactions from '@/lib/web3/transactions/AlgoARC72/AlgoARC72Transactions.vue'
import { ref } from 'vue'

defineProps < {
  transactionType: TRANSACTION_TYPE,
  conventionType: CONVENTION_TYPE
  }> ()

const web3Store = useWeb3Store()
const possibleContracts = Object.keys(TRANSACTION_TYPE).filter(x => Number.isNaN(parseInt(x)))
let provider = null
const reload = ref(0)

async function setWalletId (_walletId: PROVIDER_ID) {
  provider = await Provider[_walletId].init()
  const wallet = await provider.connect(() => {})
  console.log('connection ok')
  if (wallet.accounts.length === 0) {
    throw { message: 'account does not have any address'}
  } else if (wallet.accounts.length === 1) {
    setAccount(wallet.accounts[0])
  }
  web3Store.wallet = wallet
  web3Store.provider = provider
  web3Store.walletId = _walletId

  console.log(await web3Store.provider.algodClient.status().do())
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

</script>

<style scoped>
.transaction-modal {
  display: flex;
  flex-direction: column;
  align-items: center;
}
</style>
