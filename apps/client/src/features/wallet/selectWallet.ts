import type { WalletAccount } from "@txnlab/use-wallet";
import useNav from "@/features/app/useNav";
import type { Callback } from "@/features/wallet/types.ts";

const nav = useNav<{}, Callback>();

export async function selectWallet() {
  return new Promise<WalletAccount>((resolve, reject) => {
    nav.push(
      "wallet-selection",
      {},
      (account?: WalletAccount, error?: Error) => {
        if (error) reject(error);
        if (!account) {
          reject(new Error("No account selected"));
        } else {
          resolve(account);
        }
      },
    );
  });
}
