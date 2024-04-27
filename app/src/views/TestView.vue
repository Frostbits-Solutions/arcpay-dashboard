<script setup lang="ts">
import { TransactionModal, TRANSACTION_TYPE, CONVENTION_TYPE } from '@/lib/web3'
import { ref } from 'vue'
import { CONTRACT_TYPE } from '@/lib/web3/transactions/constants'

const transactionType = ref(TRANSACTION_TYPE.buy)

const parameters = {
    [TRANSACTION_TYPE.buy]: {
        seller: '6J4RO7U2WYQWOGWXQOZUTBBA46W4QSFL5HTHJWC5BZR53RSYRAOPAY7KPM',
        appIndex: 42037589,
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
        appIndex: 40427317,
        feesAddress:
            'UVGMQYP246NIXHWFSLBNPFVXJ77HSXNLU3AFP3JQEUVJSTGZIMGJ3JFFZY',
    },
}
</script>

<template>
    <main class="flex items-center justify-center h-screen bg-gray-50 dark:bg-gray-900">
        <TransactionModal
            :transactionType="transactionType"
            :conventionType="CONVENTION_TYPE.Arc200Rwa"
            :contractType="CONTRACT_TYPE.Sale"
            :parameters="parameters[transactionType]"
        />

      <div class="test-parameters-containers">
        <p>Test contract:</p>
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
