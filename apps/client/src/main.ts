//ts-expect-error
window.global ||= window;
import "./assets/style.css";

import { createApp } from "vue";
import { createPinia } from "pinia";
import { MotionPlugin } from "@vueuse/motion";
import { WalletManagerPlugin, NetworkId } from "@txnlab/use-wallet-vue";

import App from "./App.vue";
import router from "./features/app/router";
import wallets from "./features/wallet/supportedWallets.config";

const app = createApp(App);

app.use(createPinia());
app.use(router);
app.use(MotionPlugin);
app.use(WalletManagerPlugin, {
  wallets: wallets,
  defaultNetwork: NetworkId.TESTNET,
});

app.mount("#app");
