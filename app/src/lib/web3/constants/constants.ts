import type { Network } from '../types'
import { ICON as iconKibisis } from '../wallets/kibisis/constants'
import { ICON as iconWalletconnect } from '../wallets/walletConnect/constants'
import Kibisis from '@/lib/web3/wallets/kibisis'
import WalletConnect from '@/lib/web3/wallets/walletConnect'

export const PROVIDER = {
  'kibisis': Kibisis,
  'walletconnect': WalletConnect
}

export enum PROVIDER_ID {
  KIBISIS = 'kibisis',
  WALLETCONNECT = 'walletconnect',
}

export const PROVIDER_ICONS: {[key: string]: string} = {
  kibisis: iconKibisis,
  walletconnect: iconWalletconnect,
}

export const ARC_PAY_METADA = {
  name: 'ARC pay',
  description: 'Example Dapp',
  url: '#1',
  icons: ['https://walletconnect.com/walletconnect-logo.png']
}

export const DEFAULT_NETWORK: Network = 'testnet'

export const DEFAULT_NODE_BASEURL = 'https://testnet-api.voi.nodly.io/'

export const DEFAULT_NODE_TOKEN = ''

export const DEFAULT_NODE_PORT = '443'
