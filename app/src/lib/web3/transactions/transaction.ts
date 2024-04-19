import type {
  TransactionObjects,
  PaymentObject,
  TransfertObject,
  AppCallObject,
  AppCreateObject
} from '@/lib/web3/types'
import type { BoxReference } from 'algosdk'
import _algosdk from 'algosdk'
import { SIMULATION_ERROR } from '@/lib/web3/transactions/constants'

export class Transaction {
  appCalls: AppCallObject[]
  appCreates: AppCreateObject[]
  payments: PaymentObject[]
  transfers: TransfertObject[]
  constructor (transactionsObj: TransactionObjects) {

    this.appCalls = transactionsObj.appCalls ?? []
    this.appCreates = transactionsObj.appCreates ?? []
    this.payments = transactionsObj.payments ?? []
    this.transfers = transactionsObj.transfers ?? []
  }

  async createTxns (algosdk: typeof _algosdk, algodClient: _algosdk.Algodv2) {
    //@ts-ignore
    const results = await this.simulateTxn(algosdk, algodClient)

    if (results?.txnGroups[0]?.failureMessage) {
      throw {
        code: SIMULATION_ERROR,
        message: results?.txnGroups[0]?.failureMessage
      }
    }
    console.log(results)

    if (results?.txnGroups[0]?.unnamedResourcesAccessed?.boxes) {
      for (const obj of this.appCalls) {
        const foreignApps: Array<number> = []
        obj.boxes = results
          .txnGroups[0]
          .unnamedResourcesAccessed
          .boxes
          .map((x) => {
            if (x.app !== 0 &&
                x.app !== obj.appIndex &&
                !foreignApps.includes(x.app as number)){
              foreignApps.push(x.app as number)
            }
            return {
              appIndex: x.app,
              name: x.name,
            } as BoxReference
          })
        if (obj.foreignApps) {
          obj.foreignApps = [...obj.foreignApps, ...foreignApps]
        } else {
          obj.foreignApps = foreignApps
        }
        console.log(obj.boxes, obj.foreignApps)
      }
    }

    const txns = []

    for (const obj of this.payments) {
      txns.push(algosdk.makePaymentTxnWithSuggestedParamsFromObject(obj))
    }

    for (const obj of this.transfers) {
      txns.push(algosdk.makeAssetTransferTxnWithSuggestedParamsFromObject(obj))
    }

    for (const obj of this.appCalls) {
      txns.push(algosdk.makeApplicationCallTxnFromObject(obj))
    }

    for (const obj of this.appCreates) {
      txns.push(algosdk.makeApplicationCreateTxnFromObject(obj))
    }

    return txns
  }


  async simulateTxn (algosdk: typeof _algosdk, algodClient: _algosdk.Algodv2) {

    const txns = []

    for (const obj of this.payments) {
      txns.push(algosdk.makePaymentTxnWithSuggestedParamsFromObject(obj))
    }

    for (const obj of this.transfers) {
      txns.push(algosdk.makeAssetTransferTxnWithSuggestedParamsFromObject(obj))
    }

    for (const obj of this.appCalls) {
      txns.push(algosdk.makeApplicationCallTxnFromObject(obj))
    }

    for (const obj of this.appCreates) {
      txns.push(algosdk.makeApplicationCreateTxnFromObject(obj))
    }

    const txngroup = algosdk.assignGroupID(txns);
    // Sign the transaction
    const stxns = txns.map(algosdk.encodeUnsignedSimulateTransaction)
    // Construct the simulation request
    const request = new algosdk.modelsv2.SimulateRequest({
      txnGroups: [
        new algosdk.modelsv2.SimulateRequestTransactionGroup({
          //@ts-ignore
          txns: stxns.map(algosdk.decodeObj),
        }),
      ],
      allowUnnamedResources: true,
      allowEmptySignatures: true,
    });

    // Simulate the transaction group
    const response = await algodClient
      .simulateTransactions(request)
      .do();

    return response
  }

}
