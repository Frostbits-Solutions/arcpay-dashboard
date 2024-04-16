export interface BuyTransactionParameters {
  seller: string,
  appIndex: number,
  nftAppID: number,
  price: number,
  feesAddress: string,
}

export interface CancelTransactionParameters {
  seller: string,
  appIndex: number,
  nftAppID: number,
}

export interface CreateTransactionParameters {
  nftAppID: number,
  nftID: number,
  feesAddress: string,
  receiverAddress: string
}

export interface UpdateTransactionParameters {
  appIndex: number,
  feesAddress: string,
}

export type TransactionParameters =
  BuyTransactionParameters |
  CancelTransactionParameters |
  CreateTransactionParameters |
  UpdateTransactionParameters
