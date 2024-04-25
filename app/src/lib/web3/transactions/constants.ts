import {
  Arc200Arc72SaleBuyTransaction,
  Arc200Arc72SaleCancelTransaction,
  Arc200Arc72SaleCreateTransaction,
  Arc200Arc72SaleUpdateTransaction,
  VoiArc72DutchBuyTransaction,
  VoiArc72DutchCancelTransaction, VoiArc72DutchCreateTransaction, VoiArc72DutchUpdateTransaction,
  VoiArc72SaleBuyTransaction,
  VoiArc72SaleCancelTransaction,
  VoiArc72SaleCreateTransaction,
  VoiArc72SaleUpdateTransaction
} from './TransactionButtons'

export enum TRANSACTION_TYPE {
  buy,
  create,
  cancel,
  update,
  bid
}

export enum CONVENTION_TYPE {
  VoiARC72,
  Arc200Arc72
}

export enum CONTRACT_TYPE {
  Auction,
  Sale,
  Dutch
}

export const TRANSACTIONS_STEPS = {
  [CONVENTION_TYPE.VoiARC72]: {
    [CONTRACT_TYPE.Sale]: {
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
    },
    [CONTRACT_TYPE.Dutch]: {
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
  },
  [CONVENTION_TYPE.Arc200Arc72]: {
    [CONTRACT_TYPE.Sale]: {
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
}

export const TRANSACTIONS_BUTTONS = {
  [CONVENTION_TYPE.VoiARC72]: {
    [CONTRACT_TYPE.Sale]: {
      [TRANSACTION_TYPE.buy]: VoiArc72SaleBuyTransaction,
      [TRANSACTION_TYPE.cancel]: VoiArc72SaleCancelTransaction,
      [TRANSACTION_TYPE.create]: VoiArc72SaleCreateTransaction,
      [TRANSACTION_TYPE.update]: VoiArc72SaleUpdateTransaction,
    },
    [CONTRACT_TYPE.Dutch]: {
      [TRANSACTION_TYPE.buy]: VoiArc72DutchBuyTransaction,
      [TRANSACTION_TYPE.cancel]: VoiArc72DutchCancelTransaction,
      [TRANSACTION_TYPE.create]: VoiArc72DutchCreateTransaction,
      [TRANSACTION_TYPE.update]: VoiArc72DutchUpdateTransaction,
    }
  },
  [CONVENTION_TYPE.Arc200Arc72]: {
    [CONTRACT_TYPE.Sale]: {
      [TRANSACTION_TYPE.buy]: Arc200Arc72SaleBuyTransaction,
      [TRANSACTION_TYPE.cancel]:Arc200Arc72SaleCancelTransaction,
      [TRANSACTION_TYPE.create]: Arc200Arc72SaleCreateTransaction,
      [TRANSACTION_TYPE.update]: Arc200Arc72SaleUpdateTransaction,
    }
  }
}

export const SIMULATION_ERROR = 4010
