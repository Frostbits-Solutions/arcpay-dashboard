import type { SupabaseClient } from '@supabase/supabase-js'
import type { SaleCreationParams } from '@/lib/contracts/types'
import type { WalletAccount } from '@txnlab/use-wallet'
import { Transaction } from '@/lib/algod/Transaction'
import { useNetworksStore } from '@/features/networks/stores/networks'
import getContract from '@/services/contracts'
async function create(client: SupabaseClient, account: WalletAccount, params: SaleCreationParams): Promise<number> {
  const networks = useNetworksStore()
  const algod = networks.activeNetwork?.walletProvider.algodClient
  const signer = networks.activeNetwork?.walletProvider.transactionSigner
  const approvalProgram = await getContract(client, networks.activeNetwork.id, 'algo_asa_sale_approval', '0.0.1')

  if (!algod) throw new Error('Error during WalletManager initialization: algodClient is undefined')
  if (!signer) throw new Error('Error during WalletManager initialization: transactionSigner is undefined')

  const transactionConfirmation = await new Transaction(algod, { fromAddress })
    .createApp([longToByteArray(nftID, 8), longToByteArray(price, 8), algosdk.decodeAddress(accountFeesAddress).publicKey], approvalProgram, clearProgram)
    .send(signer)
}
