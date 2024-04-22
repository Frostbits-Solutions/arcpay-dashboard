import type { BoxReference } from 'algosdk'
import _algosdk from 'algosdk'
import { SIMULATION_ERROR } from '@/lib/web3/transactions/constants'
import { TransactionType } from 'algosdk/src/types/transactions'
import type {
  AppCallObject,
  AppCreateObject,
  PaymentObject,
  TransactionObject,
  TransfertObject,
  AppObject
} from '@/lib/web3/types'

export class Transaction {

  objs: TransactionObject[]
  constructor (transactionsObjs: TransactionObject[]) {
    this.objs = transactionsObjs
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
      for (const obj of this.objs) {
        if (obj.type !== TransactionType.appl) {
          continue
        }
        const appObj = obj as AppObject
        const foreignApps: Array<number> = []

        appObj.boxes = results
          .txnGroups[0]
          .unnamedResourcesAccessed
          .boxes
          .map((x) => {
            if (x.app !== 0 &&
                //@ts-ignore
                x.app !== appObj?.appIndex &&
                !foreignApps.includes(x.app as number)){
              foreignApps.push(x.app as number)
            }
            return {
              appIndex: x.app,
              name: x.name,
            } as BoxReference
          })
        if (appObj.foreignApps) {
          appObj.foreignApps = [...appObj.foreignApps, ...foreignApps]
        } else {
          appObj.foreignApps = foreignApps
        }
        console.log(appObj.boxes, appObj.foreignApps)
      }
    }

    const txns = this.objs.map(this._getTxn)

    return txns
  }


  async simulateTxn (algosdk: typeof _algosdk, algodClient: _algosdk.Algodv2) {

    const txns = this.objs.map(this._getTxn)
    console.log(txns)
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

    console.log(txns, stxns, response)
    return response
  }

  _getTxn (obj: TransactionObject) {
    switch (obj.type) {
      case TransactionType.appl:
        //@ts-ignore
        if (obj?.appIndex) {
          return _algosdk.makeApplicationCallTxnFromObject(obj as AppCallObject)
        } else {
          return _algosdk.makeApplicationCreateTxnFromObject(obj as AppCreateObject)
        }
      case TransactionType.pay:
        return _algosdk.makePaymentTxnWithSuggestedParamsFromObject(obj as PaymentObject)
      case TransactionType.axfer:
        return _algosdk.makeAssetTransferTxnWithSuggestedParamsFromObject(obj as TransfertObject)
      default:
        throw {
          message: `transaction type ${obj.type} not implemented`
        }
    }
  }
}
