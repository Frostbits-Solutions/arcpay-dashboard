import { ref } from 'vue'
import type { Ref } from 'vue'
import { defineStore } from 'pinia'
import { PROVIDER_ID } from '@/lib/web3/constants'
import type { Account, Wallet } from '@/lib/web3/types'
import Kibisis from '@/lib/web3/wallets/kibisis'
import WalletConnect from '@/lib/web3/wallets/walletConnect'


export const useWeb3Store = defineStore('web3Store', () => {
  const walletId: Ref<PROVIDER_ID | null> = ref(null)
  const wallet: Ref<Wallet| null> = ref(null)
  const provider: Ref<Kibisis | WalletConnect | null> = ref(null)
  const account: Ref<Account| null> = ref(null)
  return { walletId, wallet, account, provider }
})
