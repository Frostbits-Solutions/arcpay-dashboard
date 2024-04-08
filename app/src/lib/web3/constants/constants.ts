import type { Network } from '../types/node'
import { ICON as iconKibisis } from '../wallets/kibisis/constants'
import { ICON as iconWalletconnect } from '../wallets/walletConnect/constants'
import kibisis from '@/lib/web3/wallets/kibisis'

export enum PROVIDER_ID {
  KIBISIS = 'kibisis',
  WALLETCONNECT = 'walletconnect',
}

export const PROVIDER_ICONS: {[key: string]: string} = {
  kibisis: iconKibisis,
  walletconnect: iconWalletconnect,
}

export const GEMS_PAY_METADA = {
  name: 'Gems pay',
  description: 'Example Dapp',
  url: '#',
  icons: ['https://walletconnect.com/walletconnect-logo.png']
}

export const DEFAULT_NETWORK: Network = 'testnet'

export const DEFAULT_NODE_BASEURL = 'https://testnet-api.voi.nodly.io/'

export const DEFAULT_NODE_TOKEN = ''

export const DEFAULT_NODE_PORT = '443'
