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
        'Signing transaction',
        'Sending the transaction',
        'Done'
      ],
      [TRANSACTION_TYPE.create]: [
        'Creation of the application',
        'Sending the transaction',
        'Funding the application',
        'Sending the funds',
        'Done'
      ],
      [TRANSACTION_TYPE.cancel]: [
        'Signing transaction',
        'Sending the transaction',
        'Done'
      ],
      [TRANSACTION_TYPE.update]: [
        'Input price',
        'Signing update',
        'Sending the transaction',
        'Done'
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
