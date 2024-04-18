import algosdk, { ABIMethod, Transaction } from 'algosdk'

export function longToByteArray (long: number): Uint8Array
export function longToByteArray (long: number, n = 32) {
  const byteArray = []
  for (let i = 0; i < n; i++) {
    byteArray.push(0)
  }


  for (let index = byteArray.length - 1; index >= 0; index--) {
    const byte = long & 0xff
    byteArray[index] = byte
    long = (long - byte) / 256
  }

  return new Uint8Array(byteArray)
}

export function base64ToArrayBuffer (base64: string) {
  const binaryString = window.atob(base64)
  const len = binaryString.length
  const bytes = new Uint8Array(len)
  for (let i = 0; i < len; i++) {
    bytes[i] = binaryString.charCodeAt(i)
  }
  return bytes
}


export function fromHexString (hexString:string): Uint8Array
export function fromHexString (hexString: string, radix = 16): Uint8Array {
  // @ts-ignore
  return Uint8Array.from(hexString.match(/.{1,2}/g).map((byte) => parseInt(byte, radix)))
}

export function toHexString (bytes: Uint8Array): string
export function toHexString (bytes: Uint8Array, n = 16): string {
  // @ts-ignore
  return bytes.reduce((str, byte) => str + byte.toString(n).padStart(2, '0'), '');
}

export function encodeAppArgs (abiMethod: ABIMethod,  args: any[]) {
  const appArgs = args.map((arg, index) => {
    // @ts-ignore
    return abiMethod.args[index].type.encode(arg);
  });
  return [abiMethod.getSelector(), ...appArgs]
}

export function concatUint8Array (a: Uint8Array, b: Uint8Array): Uint8Array {
  const t = new Uint8Array(a.length + b.length)
  t.set(a, 0)
  t.set(b, a.length)
  return t
}

export async function simulateTxn (
  transactions: {
    appCallObjs: object[],
    paymentObjs: object[]
  },
  algodClient: algosdk.Algodv2) {
  const txns = []
  for (const obj of transactions.appCallObjs) {
    //@ts-ignore
    txns.push(algosdk.makeApplicationCallTxnFromObject(obj))
  }
  for (const obj of transactions.paymentObjs) {
    //@ts-ignore
    txns.push(algosdk.makePaymentTxnWithSuggestedParamsFromObject(obj))
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
