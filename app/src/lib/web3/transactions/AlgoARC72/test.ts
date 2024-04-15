import Algod from '@/lib/web3/algod'
import { base64ToArrayBuffer, fromHexString, longToByteArray, toHexString } from '@/lib/web3/transactions/utils'
import algosdk from 'algosdk'
import type { ConfirmedTxn, RawTxnResponse } from '@/lib/web3/types'
import { arc72Schema } from '@/lib/web3/transactions/AlgoARC72/abi'
//import CONTRACT from 'arccjs'


const algoD = await Algod.init()

const app_id_nft = 29105406
const nft_id = 582
const mnemonic_sender = "arrest pear require glad middle legend army stick bounce brush oyster police family version width endorse inquiry expand voice knee where foam search absent flush"

const private_key = algoD.algosdk.mnemonicToSecretKey(mnemonic_sender).sk

const sender_address = "UVGMQYP246NIXHWFSLBNPFVXJ77HSXNLU3AFP3JQEUVJSTGZIMGJ3JFFZY"
const receiver_address = "SUUDLSE47YXKM5FP3ATL4ZY7EAJICFJMFRZH2KJTQ6XZ46SWT22LRZI6QE"

async function waitForConfirmation(algodClient: algosdk.Algodv2, txId: string, timeout = 4) {
  const confirmation = (await algosdk.waitForConfirmation(
    algodClient,
    txId,
    timeout
  )) as ConfirmedTxn

  return { txId, ...confirmation }
}

async function sendRawTransactions(algodClient: algosdk.Algodv2, transactions: Uint8Array[], waitRoundsToConfirm?: number) {
  const sentTransaction = (await algodClient
    .sendRawTransaction(transactions)
    .do()) as RawTxnResponse

  if (!sentTransaction) {
    throw new Error('Transaction failed.')
  }

  const decodedTxn = algosdk.decodeSignedTransaction(transactions[0])
  const waitRounds = waitRoundsToConfirm || decodedTxn.txn.lastRound - decodedTxn.txn.firstRound

  const confirmedTransaction = await waitForConfirmation(algodClient, sentTransaction.txId, waitRounds)

  return {
    id: sentTransaction.txId,
    ...confirmedTransaction
  }
}

// @ts-ignore
function createAppCallTxnObject(abiMethod, args) {
  // @ts-ignore
  const appArgs = args.map((arg, index) => {
    return abiMethod.args[index].type.encode(arg);
  });
  return {
    from: sender_address,
    appIndex: app_id_nft,
    appArgs: [abiMethod.getSelector(), ...appArgs],
  };
}

export default async function test() {
  // new CONTRACT(
  //   contractId,
  //   algodClient,
  //   indexerClient,
  //   schema,
  //   opts.acc,
  //   opts.simulate,
  //   opts.waitForConfirmation
  // )


  const abi = new algosdk.ABIContract(arc72Schema)
  const abiMethod = abi.getMethodByName('arc72_transferFrom')
  const args = [sender_address, receiver_address, nft_id]
  const encodedArgs = args.map((arg, index) => {
    // @ts-ignore
    return abiMethod.args[index].type.encode(arg);
  });
  console.log(encodedArgs.map(x => btoa(toHexString(x))))
  // const obj = createAppCallTxnObject(abiMethod, args)
  // console.log(obj)

  const suggestedParams = await algoD.algodClient.getTransactionParams().do()
//  a54cc861fae79a8b9ec592c2d796b74ffe795daba6c057ed30252a994cd9430ca54cc861fae79a8b9ec592c2d796b74ffe795daba6c057ed30252a994cd9430c
//62a54cc861fae79a8b9ec592c2d796b74ffe795daba6c057ed30252a994cd9430c  4cc861fae79a8b9ec592c2d796b74ffe795daba6c057ed30252a994cd9430c
//a54cc861fae79a8b9ec592c2d796b74ffe795daba6c057ed30252a994cd9430c
  const nftIDBox = new Uint8Array(encodedArgs[2].length + 1)
  nftIDBox.set([110], 0)
  nftIDBox.set(encodedArgs[2], 1)
  const x = encodedArgs[0]
  const selectorBox = fromHexString('a54cc861fae79a8b9ec592c2d796b74ffe795daba6c057ed30252a994cd9430ca54cc861fae79a8b9ec592c2d796b74ffe795daba6c057ed30252a994cd9430c')
  console.log(encodedArgs[0])
  console.log(selectorBox)
  const addressBox = new Uint8Array(encodedArgs[0].length + 1)
  selectorBox.set([98], 0)
  selectorBox.set(encodedArgs[0], 1)

  let boxes;
  boxes = [abiMethod.getSelector(), ...encodedArgs].map(x=> {
    const nftIDBox = new Uint8Array(x.length + 1)
    nftIDBox.set([110], 0)
    nftIDBox.set(x, 1)
    return {
      appIndex: app_id_nft,
      name: nftIDBox
    }
  })
  // boxes[3].name = nftIDBox
  //   [
  //   {
  //     appIndex: 0,
  //     name: selectorBox
  //   },
  //   {
  //     appIndex: 0,
  //     name: selectorBox
  //   },
  //   {
  //     appIndex: 0,
  //     name: nftIDBox
  //   }
  // ]
  boxes.forEach(x => {
    console.log(toHexString(x.name))
  })

  console.log(toHexString(new Uint8Array([0, 110])))
  console.log(fromHexString("0x6e"))

  const b_name = [
    '6e0000000000000000000000000000000000000000000000000000000000000246', 'a54cc861fae79a8b9ec592c2d796b74ffe795daba6c057ed30252a994cd9430ca54cc861fae79a8b9ec592c2d796b74ffe795daba6c057ed30252a994cd9430c',
    '62a54cc861fae79a8b9ec592c2d796b74ffe795daba6c057ed30252a994cd9430c',
    '62952835c89cfe2ea674afd826be671f201281152c2c727d293387af9e7a569eb4'
    ]
  boxes = b_name.map(x => {
    return {
      appIndex: 0,
      name: fromHexString(x)
    }
  })
  console.log(boxes)
  const obj = {
    suggestedParams: suggestedParams,
    from: sender_address,
    appIndex: app_id_nft,
    appArgs: [abiMethod.getSelector(), ...encodedArgs],
    foreignApps: [app_id_nft],
    boxes: boxes,
  }

  const appArgs = [
    new TextEncoder().encode('update_price'),
    algoD.algosdk.decodeAddress(sender_address).publicKey,
    algoD.algosdk.decodeAddress(receiver_address).publicKey,
    longToByteArray(nft_id)]
  const accounts = [receiver_address, sender_address]

  const txn = algoD.algosdk.makeApplicationCallTxnFromObject({
    ...obj,
    // accounts: accounts,
    onComplete: algoD.algosdk.OnApplicationComplete.NoOpOC,
    suggestedParams
  })
  console.log(txn)

  const signedTx = txn.signTxn(private_key)
  return await sendRawTransactions(algoD.algodClient, [signedTx])
}
