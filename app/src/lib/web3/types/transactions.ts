import type { SuggestedParams } from 'algosdk'
import type { Expand, RenameProperties } from 'algosdk/src/types/utils'
import type { AppCreateTxn, MustHaveSuggestedParams } from 'algosdk/src/types/transactions'

export interface BuyTransactionParameters {
  seller: string,
  appIndex: number,
  nftAppID: number,
  nftID: number,
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
  feesAddress: string
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

export type PaymentObject = {
  from: string;
  note?: Uint8Array | undefined;
  suggestedParams: SuggestedParams;
  to: string;
  amount: number | bigint;
  closeRemainderTo?: string | undefined;
  rekeyTo?: string | undefined; }

export type TransfertObject = {
  from: string;
  note?: Uint8Array | undefined;
  suggestedParams: SuggestedParams;
  to: string;
  amount: number | bigint;
  closeRemainderTo?: string | undefined;
  rekeyTo?: string | undefined;
  assetIndex: number;
  revocationTarget?: string | undefined;
}

export type AppCallObject = Expand<
  Pick<
    RenameProperties<
      MustHaveSuggestedParams<AppCreateTxn>,
      {
        appOnComplete: 'onComplete';
        appAccounts: 'accounts';
        appForeignApps: 'foreignApps';
        appForeignAssets: 'foreignAssets';
        reKeyTo: 'rekeyTo';
      }
    >,
    | 'from'
    | 'suggestedParams'
    | 'appIndex'
    | 'onComplete'
    | 'appArgs'
    | 'accounts'
    | 'foreignApps'
    | 'foreignAssets'
    | 'boxes'
    | 'note'
    | 'lease'
    | 'rekeyTo'
    | 'extraPages'
  > &
  Partial<
    Pick<
      RenameProperties<
        MustHaveSuggestedParams<AppCreateTxn>,
        {
          appApprovalProgram: 'approvalProgram';
          appClearProgram: 'clearProgram';
          appLocalInts: 'numLocalInts';
          appLocalByteSlices: 'numLocalByteSlices';
          appGlobalInts: 'numGlobalInts';
          appGlobalByteSlices: 'numGlobalByteSlices';
        }
      >,
      | 'approvalProgram'
      | 'clearProgram'
      | 'numLocalInts'
      | 'numLocalByteSlices'
      | 'numGlobalInts'
      | 'numGlobalByteSlices'
    >
  >
>

export type AppCreateObject = Expand<
  Pick<
    RenameProperties<
      MustHaveSuggestedParams<AppCreateTxn>,
      {
        appOnComplete: 'onComplete';
        appApprovalProgram: 'approvalProgram';
        appClearProgram: 'clearProgram';
        appLocalInts: 'numLocalInts';
        appLocalByteSlices: 'numLocalByteSlices';
        appGlobalInts: 'numGlobalInts';
        appGlobalByteSlices: 'numGlobalByteSlices';
        appAccounts: 'accounts';
        appForeignApps: 'foreignApps';
        appForeignAssets: 'foreignAssets';
        reKeyTo: 'rekeyTo';
      }
    >,
    | 'from'
    | 'suggestedParams'
    | 'onComplete'
    | 'approvalProgram'
    | 'clearProgram'
    | 'numLocalInts'
    | 'numLocalByteSlices'
    | 'numGlobalInts'
    | 'numGlobalByteSlices'
    | 'appArgs'
    | 'accounts'
    | 'foreignApps'
    | 'foreignAssets'
    | 'boxes'
    | 'note'
    | 'lease'
    | 'rekeyTo'
    | 'extraPages'
  >
>


export interface TransactionObjects {
  appCalls?: AppCallObject[],
  appCreates?: AppCreateObject[]
  payments?: PaymentObject[],
  transfers?: TransfertObject[]
}
