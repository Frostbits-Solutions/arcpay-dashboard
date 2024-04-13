<template>
<div>
  <choose-wallet
    v-if="web3Store.walletId === null"
    @wallet="setWalletId"/>
  <choose-account
    :accounts="web3Store.wallet.accounts"
    v-else-if="web3Store.account === null"
    @account="setAccount"/>
  <AlgoARC72Transactions
    v-else-if="conventionType === CONVENTION_TYPE.AlgoARC72"
    :wallet="web3Store.wallet"
    :transaction="transactionType"
  />
  {{possibleContracts}}
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

defineProps < {
  transactionType: TRANSACTION_TYPE,
  conventionType: CONVENTION_TYPE
  }> ()

const web3Store = useWeb3Store()
const possibleContracts = Object.keys(TRANSACTION_TYPE).filter(x => Number.isNaN(parseInt(x)))
let provider = null

async function setWalletId (_walletId: PROVIDER_ID) {
  provider = await Provider[_walletId].init()
  const wallet = await provider.connect(() => {})
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
  console.log(_account)
  web3Store.account = _account
}

</script>

<style scoped>

</style>
