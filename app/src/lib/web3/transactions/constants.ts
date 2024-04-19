import { AlgoArc72BuyTransaction, AlgoArc72CancelTransaction, AlgoArc72CreateTransaction, AlgoArc72UpdateTransaction } from './TransactionButtons'

export enum TRANSACTION_TYPE {
  buy,
  create,
  cancel,
  update
}

export enum CONVENTION_TYPE {
  AlgoARC72
}

export const TRANSACTIONS_STEPS = {
    [CONVENTION_TYPE.AlgoARC72]: {
      [TRANSACTION_TYPE.buy]: [
        'Initiating purchase transaction, awaiting signature',
        'Processing purchase transaction',
        'Transaction complete, asset acquired'
      ],
      [TRANSACTION_TYPE.create]: [
        'Initiating listing creation, awaiting signature',
        'Transmitting listing data',
        'Allocating funds for listing, awaiting signature',
        'Processing listing funding',
        'Listing creation successful'
      ],
      [TRANSACTION_TYPE.cancel]: [
        'Initiating cancellation transaction, awaiting signature',
        'Processing cancellation request',
        'Cancellation complete, listing removed'
      ],
      [TRANSACTION_TYPE.update]: [
        'Enter new listing price', //This may be irrelevant because price is entered before clicking the button
        'Initiating price update, awaiting signature',
        'Processing price update transaction',
        'Price update successful, listing modified'
      ],
  }
}

export const TRANSACTIONS_BUTTONS = {

  [CONVENTION_TYPE.AlgoARC72]: {
    [TRANSACTION_TYPE.buy]: AlgoArc72BuyTransaction,
    [TRANSACTION_TYPE.cancel]: AlgoArc72CancelTransaction,
    [TRANSACTION_TYPE.create]: AlgoArc72CreateTransaction,
    [TRANSACTION_TYPE.update]: AlgoArc72UpdateTransaction,
  }
}

export const SIMULATION_ERROR = 4010
