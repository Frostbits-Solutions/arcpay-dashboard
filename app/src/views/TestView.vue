<script setup lang="ts">
import { TransactionModal, TRANSACTION_TYPE, CONVENTION_TYPE } from '@/lib/web3'
import { onMounted, ref, watch } from 'vue'
import { CONTRACT_TYPE } from '@/lib/web3/transactions/constants'

const transactionType = ref(TRANSACTION_TYPE.buy)
const conventionType = ref(CONVENTION_TYPE.VoiArc72)
const contractType = ref(CONTRACT_TYPE.Sale)

const parameters = {
    [TRANSACTION_TYPE.buy]: {
        seller: '6J4RO7U2WYQWOGWXQOZUTBBA46W4QSFL5HTHJWC5BZR53RSYRAOPAY7KPM',
        appIndex: 42037609,
        nftAppID: 29105406,
        arc200AppID:40427782,
        price: 2,
        feesAddress: 'UVGMQYP246NIXHWFSLBNPFVXJ77HSXNLU3AFP3JQEUVJSTGZIMGJ3JFFZY',
        nftID: 602,
    },
    [TRANSACTION_TYPE.bid]: {
      seller: 'UVGMQYP246NIXHWFSLBNPFVXJ77HSXNLU3AFP3JQEUVJSTGZIMGJ3JFFZY',
      appIndex: 42034657,
      nftAppID: 29105406,
      minPrice: 1,
      feesAddress: 'UVGMQYP246NIXHWFSLBNPFVXJ77HSXNLU3AFP3JQEUVJSTGZIMGJ3JFFZY',
      nftID: 685,
    },
    [TRANSACTION_TYPE.cancel]: {
        seller: 'UVGMQYP246NIXHWFSLBNPFVXJ77HSXNLU3AFP3JQEUVJSTGZIMGJ3JFFZY',
        appIndex: 40427317,
        nftAppID: 29105406,
    },
    [TRANSACTION_TYPE.create]: {
        nftAppID: 29105406,
        nftID: 602,
        feesAddress:
            'UVGMQYP246NIXHWFSLBNPFVXJ77HSXNLU3AFP3JQEUVJSTGZIMGJ3JFFZY',
    },
    [TRANSACTION_TYPE.update]: {
        appIndex: 42037609,
        feesAddress:
            'UVGMQYP246NIXHWFSLBNPFVXJ77HSXNLU3AFP3JQEUVJSTGZIMGJ3JFFZY',
    },
}

watch(transactionType, () => {
  localStorage.setItem('arc-pay-test-transaction-type', (transactionType.value as number).toString())
})
watch(conventionType, () => {
  localStorage.setItem('arc-pay-test-convention-type', (conventionType.value as number).toString())
})
watch(contractType, () => {
  localStorage.setItem('arc-pay-test-contract-type', (contractType.value as number).toString())
})

function onMountedHook () {
  const tT = localStorage.getItem('arc-pay-test-transaction-type')
  if (tT !== null) {
    transactionType.value = parseInt(tT) as TRANSACTION_TYPE
  }
  const cT = localStorage.getItem('arc-pay-test-convention-type')
  if (cT !== null) {
    conventionType.value = parseInt(cT) as CONVENTION_TYPE
  }
  const ctT = localStorage.getItem('arc-pay-test-contract-type')
  if (ctT !== null) {
    contractType.value = parseInt(ctT) as CONTRACT_TYPE
  }
}
// @ts-ignore
onMounted(onMountedHook)
</script>

<template>
    <main class="flex items-center justify-center h-screen bg-gray-50 dark:bg-gray-900">
        <TransactionModal
            :transactionType="transactionType"
            :conventionType="conventionType"
            :contractType="contractType"
            :parameters="parameters[transactionType]"
        />

      <div class="test-parameters-containers">
        <p>Convention</p>
        <select v-model="conventionType">
          <option :value="CONVENTION_TYPE.VoiArc72">Voi -> Arc72</option>
          <option :value="CONVENTION_TYPE.VoiRwa">Voi -> RWA</option>
          <option :value="CONVENTION_TYPE.Arc200Arc72">Arc200 -> Arc72</option>
          <option :value="CONVENTION_TYPE.Arc200Rwa">Arc200 -> RWA</option>
        </select>

        <p>Contract</p>
        <select v-model="contractType">
          <option :value="CONTRACT_TYPE.Sale">Sale</option>
          <option :value="CONTRACT_TYPE.Dutch">Dutch</option>
          <option :value="CONTRACT_TYPE.Auction">Auction</option>
        </select>

        <p>Transaction:</p>
        <select v-model="transactionType">
          <option :value="TRANSACTION_TYPE.buy">buy</option>
          <option :value="TRANSACTION_TYPE.bid">bid</option>
          <option :value="TRANSACTION_TYPE.create">create</option>
          <option :value="TRANSACTION_TYPE.cancel">cancel</option>
          <option :value="TRANSACTION_TYPE.update">update</option>
        </select>
      </div>
    </main>
</template>

<style scoped>
main {
    text-align: center;
}

.test-parameters-containers {
  position: absolute;
  top: 50%;
  left: 0;
  transform: translateY(-50%);
  padding: 10px;
  background: white;
  border: 1px solid black;
}
</style>
