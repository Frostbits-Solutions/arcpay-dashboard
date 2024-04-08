import BaseClient from '../base';

import {
  base64ToBytes,
  bytesToBase64
} from '@agoralabs-sh/algorand-provider'
import type {
  AlgorandProvider,
  IBaseResult,
  IEnableResult,
  ISignTxnsResult,
} from '@agoralabs-sh/algorand-provider';

import _algosdk, {
  assignGroupID,
} from 'algosdk';
import type {
  Transaction
} from 'algosdk'

import type { Wallet, Account } from '@/lib/web3/types'
import {
  ICON,
  KIBISIS_NOT_INSTALLED,
  NO_ALGO_WALLET_INSTALLED, UNKNOWN_ERROR
} from '@/lib/web3/wallets/kibisis/constants'
import { PROVIDER_ID } from '@/lib/web3/constants'
import Algod from '@/lib/web3/algod'

class Kibisis extends BaseClient {
  genesisHash: string|undefined
  genesisId: string|undefined
  sessionId: string|undefined

  static async init () {
    const algoD = await Algod.init()
    return new Kibisis(algoD.algosdk, algoD.algodClient)
  }

  constructor(
    algosdk: typeof _algosdk,
    algodClient: _algosdk.Algodv2
    ) {
    super(algosdk, algodClient)
  }

  async connect(onDisconnect: () => void, arg?: any): Promise<Wallet> {
    //@ts-ignore
    if (!window.algorand) {
      throw {
        code: NO_ALGO_WALLET_INSTALLED,
        message: 'no algowallet installed as an extension of the browser'.toUpperCase()
      };
    }

    // @ts-ignore
    const wallets: string[] = (window.algorand as AlgorandProvider).getWallets();
    if (!wallets.includes('kibisis')){
      throw {
        code: KIBISIS_NOT_INSTALLED,
        message: 'kibisis not installed or detected'.toUpperCase()
      };
    }

    try {
      // @ts-ignore
      const result: IBaseResult & IEnableResult = await window.algorand.enable({
        id: 'kibisis',
      });

      console.log(result);
      this.genesisHash = result.genesisHash
      this.genesisId = result.genesisId
      this.sessionId = result.sessionId

      const accounts: Account[] = []
      for (const account of result.accounts)
        accounts.push({
          providerId: PROVIDER_ID.KIBISIS,
          address: account.address,
          name: account.name
        })

      return {
        id: PROVIDER_ID.KIBISIS,
        name: PROVIDER_ID.KIBISIS.toUpperCase(),
        icon: ICON,
        isWalletConnect: false,
        accounts: accounts
      }
    } catch (error) {
      console.log(error)
      throw new Error('Connection to Kibisis failed');
    }
  }

  async disconnect(): Promise<void> {
    return
  }

  async reconnect(onDisconnect: () => void): Promise<Wallet | null> {
    return this.connect(onDisconnect)
  }

  async signTransactions(transactions: Transaction[], isAtomicTransactions: Boolean) {
    try {
      if (isAtomicTransactions) {
        assignGroupID(transactions);
      }

      const txns = []
      for (const transaction of transactions){
        txns.push({
          txn: bytesToBase64(transaction.toByte())
          //signers: [], // an empty array instructs the wallet to skip signing this transaction
        })
      }

      // @ts-ignore
      let result: IBaseResult & ISignTxnsResult = await window.algorand.signTxns(txns);
      let signedTransactionBytes: Uint8Array[] = []
      for (let stxn of result.stxns) {
        if (typeof stxn === 'string'){
          signedTransactionBytes.push(base64ToBytes(stxn))
        }
      }

      console.log(result);
      /*
      {
        id: 'awesome-wallet',
        stxns: [
          'gqNzaWfEQ...',
        ],
      }
      */

      return signedTransactionBytes
    } catch (error) {
      console.error(error)
      throw {
        code: UNKNOWN_ERROR,
        message: error
      }
    }
  }
}

export default Kibisis

// class Kibisis implements Wallet {
//   async connect () {
//     // @ts-ignore
//     if (!window.algorand) {
//       throw new Error('no wallets are installed!');
//     }
//
//     // @ts-ignore
//     const wallets: string[] = (window.algorand as AlgorandProvider).getWallets();
//     if (!wallets.includes('kibisis')){
//       throw new Error('Kibisis is not installed');
//     }
//
//     try {
//       // @ts-ignore
//       const result: IBaseResult & IEnableResult = await window.algorand.enable({
//         id: 'kibisis',
//       });
//
//       console.log(result);
//       return result
//       /*
//       {
//         accounts: [
//           {
//             address: 'P3AIQVDJ2CTH54KSJE63YWB7IZGS4W4JGC53I6GK72BGZ5BXO2B2PS4M4U',
//             name: 'Wallet-1',
//           },
//           {
//             address: '6GT6EXFDAHZDZYUOPT725ZRWYBZDCEGYT7SYYXGJKRFUAG5B7JMI7DQRNQ',
//             name: 'Wallet-2',
//           },
//         ],
//         genesisHash: 'wGHE2Pwdvd7S12BL5FaOP20EGYesN73ktiC1qzkkit8=',
//         genesisId: 'mainnet-v1.0',
//         id: 'awesome-wallet',
//         sessionId: 'ab192498-0c63-4028-80fd-f148710611d8',
//       }
//       */
//     } catch (error) {
//       console.log(error)
//       throw new Error('Connection to Kibisis failed');
//     }
//   }
//
//   async sign(transactions: Transaction[], isAtomicTransactions: Boolean) {
//     try {
//       if (isAtomicTransactions) {
//         assignGroupID(transactions);
//       }
//
//       const txns = []
//       for (const transaction of transactions){
//         txns.push({
//           txn: bytesToBase64(transaction.toByte())
//           //signers: [], // an empty array instructs the wallet to skip signing this transaction
//         })
//       }
//
//       // @ts-ignore
//       let result: IBaseResult & ISignTxnsResult = await window.algorand.signTxns(txns);
//
//       console.log(result);
//
//       return result.stxns
//     } catch (error) {
//       // handle error
//     }
//   }
// }
//
// export default Kibisis
