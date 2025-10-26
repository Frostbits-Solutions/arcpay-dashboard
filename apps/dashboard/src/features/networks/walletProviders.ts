import { type SupportedWallet, WalletId } from '@txnlab/use-wallet'

export const walletProviders: Record<string, SupportedWallet[]> = {
  'voi:testnet': [
    {
      id: WalletId.WALLETCONNECT,
      options: { projectId: import.meta.env.VITE_WC_PROJECT_ID },
    },
    WalletId.KIBISIS,
  ],
  'voi:mainnet': [
    {
      id: WalletId.WALLETCONNECT,
      options: { projectId: import.meta.env.VITE_WC_PROJECT_ID },
    },
    WalletId.KIBISIS,
  ],
  'algo:testnet': [
    WalletId.DEFLY,
    WalletId.PERA,
    WalletId.EXODUS,
    {
      id: WalletId.WALLETCONNECT,
      options: { projectId: import.meta.env.VITE_WC_PROJECT_ID },
    },
    {
      id: WalletId.LUTE,
      options: { siteName: 'Arcpay' },
    },
    WalletId.KIBISIS,
  ],
  'algo:mainnet': [
    WalletId.DEFLY,
    WalletId.PERA,
    WalletId.EXODUS,
    {
      id: WalletId.WALLETCONNECT,
      options: { projectId: import.meta.env.VITE_WC_PROJECT_ID },
    },
    {
      id: WalletId.LUTE,
      options: { siteName: 'Arcpay' },
    },
    WalletId.KIBISIS,
  ],
}
