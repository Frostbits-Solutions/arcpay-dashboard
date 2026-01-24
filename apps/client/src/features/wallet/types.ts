import type { WalletAccount } from "@txnlab/use-wallet";

export type Callback = (account?: WalletAccount, error?: Error) => void;
