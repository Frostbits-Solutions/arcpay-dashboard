<script lang="ts" setup>
import { computed, inject, onMounted, ref } from "vue";
import { Button } from "@repo/ui/button";
import {
  ChevronDown,
  ChevronRight,
  CircleHelp,
  LoaderCircle,
  OctagonAlert,
} from "lucide-vue-next";
import { getShortAddress } from "@/lib/utils";
import Jazzicon from "@/components/Jazzicon.vue";
import {
  type WalletAccount,
  WalletId,
  type WalletManager,
  type WalletMetadata,
} from "@txnlab/use-wallet";

interface WalletSelectionProvider {
  callback: (account: WalletAccount) => void;
}

interface Wallet {
  id: string;
  metadata: WalletMetadata;
  accounts: WalletAccount[];
  activeAccount: WalletAccount | null;
  isConnected: boolean;
  isActive: boolean;
  connect: (args?: Record<string, any>) => Promise<WalletAccount[]>;
  disconnect: () => Promise<void>;
  setActive: () => void;
  resumeSession: () => Promise<void>;
  setActiveAccount: (address: string) => void;
}

const manager = inject<WalletManager>("walletManager");
const { callback } =
  inject<{ WalletSelection: WalletSelectionProvider }>("appProvider")?.[
    "WalletSelection"
  ] || {};

const error = ref<string | undefined>();
const activeWallet = ref<Wallet | undefined>();
const accountLoading = ref<boolean>(false);
const wallets = computed(() => {
  if (!manager) return [];
  return [...manager.wallets.values()].map((wallet): Wallet => {
    return {
      id: wallet.id,
      metadata: wallet.metadata,
      accounts: [],
      activeAccount: null,
      isConnected: wallet.isConnected,
      isActive: wallet.isActive,
      connect: (args) => wallet.connect(args),
      disconnect: () => wallet.disconnect(),
      setActive: () => wallet.setActive(),
      setActiveAccount: (addr) => wallet.setActiveAccount(addr),
      resumeSession: () => wallet.resumeSession(),
    };
  });
});

// All of this will be needed when we allow magic wallet
const magicEmail = ref("");
const isMagicLink = (wallet: Wallet) => wallet.id === WalletId.MAGIC;
const isEmailValid = () => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(magicEmail.value);
const isConnectDisabled = (wallet: Wallet) =>
  wallet.isConnected || (isMagicLink(wallet) && !isEmailValid());

const getConnectArgs = (wallet: Wallet) => {
  if (isMagicLink(wallet)) {
    return { email: magicEmail.value };
  }
  return undefined;
};

async function selectWallet(wallet: Wallet) {
  wallet.setActive();
  activeWallet.value = wallet;
  accountLoading.value = true;
  if (wallet.isConnected && manager?.activeWallet !== undefined) {
    activeWallet.value.accounts = manager?.activeWallet?.accounts || [];
  } else {
    activeWallet.value.accounts = await wallet.connect(getConnectArgs(wallet));
  }
  accountLoading.value = false;
  if (activeWallet.value?.accounts.length === 0) {
    error.value =
      "Wallet does not have any accounts. Please select another wallet.";
  }
}

function disconnectWallet() {
  if (activeWallet.value) {
    activeWallet.value.disconnect();
    activeWallet.value = undefined;
  }
}

async function selectAccount(account: WalletAccount) {
  if (callback && account) {
    manager?.activeWallet?.setActiveAccount(account.address);
    callback(account);
  } else {
    throw { message: "Unexpected error: WalletSelectionCallback not provided" };
  }
}

onMounted(async () => {
  // if (callback && manager?.activeWallet?.activeAccount) callback(manager?.activeWallet?.activeAccount)
});
</script>

<template>
  <ul
    v-if="!activeWallet || accountLoading"
    class="w-[350px] mx-auto mt-6 flex flex-col g2"
  >
    <li v-for="wallet in wallets" :key="wallet.id">
      <Button
        :disabled="isConnectDisabled(wallet)"
        class="w-full h-12 justify-between bg-background hover:bg-background"
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
  <ul v-else class="w-[350px] mx-auto mt-6 flex flex-col g2">
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
    class="text-muted-foreground flex items-center g1 text-xs underline justify-center mt-6"
  >
    <CircleHelp class="w-4 h-4" />
    Why do I need to connect with my wallet?
  </div>
</template>

<style scoped></style>
