import WalletSelectionView from './views/WalletSelectionView.vue'

export default {
  path: '/wallet',
  name: 'wallet-selection',
  component: WalletSelectionView,
  meta: {
    title: 'Connect wallet',
    description: 'Select an account to connect to the application',
    closeable: true
  }
}