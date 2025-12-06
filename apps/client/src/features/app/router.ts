import { createMemoryHistory, createRouter } from "vue-router";
import ModalView from "./views/ModalView.vue";
import LoadingView from "./views/LoadingView.vue";
import ErrorView from "./views/ErrorView.vue";
import SuccessView from "./views/SuccessView.vue";

const router = createRouter({
  history: createMemoryHistory(),
  routes: [
    {
      path: "/",
      component: ModalView,
      children: [
        {
          path: "/loading",
          name: "loading",
          component: LoadingView,
          meta: {
            closeable: false,
          },
        },
        {
          path: "/success",
          name: "success",
          component: SuccessView,
          meta: {
            closeable: true,
          },
        },
        {
          path: "/error",
          name: "error",
          component: ErrorView,
          meta: {
            closeable: true,
          },
        },
        // createRoutes,
        // reviewRoutes,
        // walletRoutes,
      ],
    },
  ],
});
export default router;
