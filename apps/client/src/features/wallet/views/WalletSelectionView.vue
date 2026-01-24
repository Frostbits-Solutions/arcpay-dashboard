<script lang="ts" setup>
import { onMounted, ref } from "vue";
import { Button } from "@repo/ui/button";
import {
  ChevronDown,
  ChevronRight,
  CircleHelp,
  LoaderCircle,
  OctagonAlert,
} from "lucide-vue-next";
import { getShortAddress } from "@/lib/algod/utils.ts";
import { Jazzicon } from "@repo/ui/jazzicon";
import { type WalletAccount } from "@txnlab/use-wallet";
import { useWallet, type Wallet } from "@txnlab/use-wallet-vue";
import useNav from "@/features/app/useNav.ts";
import type { Callback } from "@/features/wallet/types.ts";

const { callback }: { callback: Callback } = useNav<{}, Callback>();
const { wallets, activeWallet } = useWallet();

const error = ref<string | undefined>();
const walletConnecting = ref<boolean>(false);

async function selectWallet(wallet: Wallet) {
  walletConnecting.value = true;
  try {
    await wallet.connect();
    if (activeWallet.value?.accounts.length === 0) {
      error.value =
        "Wallet does not have any accounts. Please select another wallet.";
    }
  } catch (e) {
    error.value = e.message || "Failed to connect to wallet.";
  } finally {
    walletConnecting.value = false;
  }
}

function disconnectWallet() {
  if (activeWallet.value) {
    activeWallet.value.disconnect();
  }
}

async function selectAccount(account: WalletAccount) {
  if (callback && account) {
    activeWallet.value?.setActiveAccount(account.address);
    callback(account);
  } else {
    throw { message: "Unexpected error: WalletSelectionCallback not provided" };
  }
}

onMounted(async () => {
  // if (callback && activeWalletManager.value?.activeAccount) callback(activeWalletManager.value?.activeAccount)
});
</script>

<template>
  <ul
    v-if="!activeWallet || walletConnecting"
    class="w-[350px] mx-auto mt-10 flex flex-col gap-3"
  >
    <li v-for="wallet in wallets" :key="wallet.id">
      <Button
        class="w-full h-14 justify-between bg-background hover:bg-background"
        variant="secondary"
        @click="selectWallet(wallet)"
      >
        <div class="flex items-center w-full">
          <img
            :alt="wallet.metadata.name"
            :src="wallet.metadata.icon"
            class="w-6 h-6 mr-2"
          />
          {{ wallet.metadata.name }}
        </div>
        <LoaderCircle
          v-if="activeWallet?.id === wallet.id"
          class="w-5 h-5 text-muted-foreground animate-spin"
        />
        <ChevronRight v-else class="w-5 h-5 text-muted-foreground" />
      </Button>
    </li>
    <li
      v-if="error"
      class="text-xs bg-destructive text-destructive-foreground py-2 px-3 rounded-md mt-2 flex items-center"
    >
      <OctagonAlert class="w-6 h-6 mr-2" />
      {{ error }}
    </li>
  </ul>
  <ul v-else class="w-[350px] mx-auto mt-6 flex flex-col gap-2">
    <li>
      <Button
        class="w-full h-12 justify-between bg-background hover:bg-background"
        variant="secondary"
        @click="disconnectWallet"
      >
        <div class="flex items-center w-full">
          <img
            :alt="activeWallet?.metadata.name"
            :src="activeWallet?.metadata.icon"
            class="w-6 h-6 mr-2"
          />
          {{ activeWallet?.metadata.name }}
        </div>
        <ChevronDown class="w-5 h-5 text-muted-foreground" />
      </Button>
    </li>
    <li
      v-for="(account, index) in activeWallet.accounts"
      :key="account.address"
      :style="`animation-delay: ${index * 50}ms; animation-fill-mode: both;`"
      class="animate-in slide-in-from-bottom fade-in"
    >
      <Button
        class="w-full h-12 justify-between hover:bg-background"
        variant="ghost"
        @click="selectAccount(account)"
      >
        <div class="flex items-center w-full text-xs font-semibold">
          <Jazzicon
            :address="`0x${account.address}`"
            :diameter="25"
            class="w-[25px] h-[25px] mr-2 shadow rounded-full"
          />
          <div class="truncate">
            {{ account.name
            }}<span class="text-muted-foreground ml-2 font-normal">{{
              getShortAddress(account.address)
            }}</span>
          </div>
        </div>
        <div
          class="w-4 h-4 border-2 border-muted-foreground/40 rounded flex-shrink-0"
        ></div>
      </Button>
    </li>
  </ul>
  <div
    class="text-muted-foreground flex items-center gap-1 text-xs underline justify-center mt-10"
  >
    <CircleHelp class="w-4 h-4" />
    Why do I need to connect with my wallet?
  </div>
</template>

<style scoped></style>
