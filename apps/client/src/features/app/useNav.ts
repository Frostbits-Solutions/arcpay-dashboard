import { readonly, ref, type Ref } from "vue";
import { type RouteParamsRawGeneric } from "vue-router";
import router from "@/features/app/router";

type Args<T> = Record<string, T>;
type Callback<U> = () => U;

const _args: Args<any> = ref({});
let _callback: Callback<any> = () => {};

export default function useNav<T, U>() {
  async function push(
    name: string,
    args: Args<T>,
    callback?: Callback<U>,
    params?: RouteParamsRawGeneric,
  ) {
    _args.value = args;
    _callback = callback || (() => {});
    return router.push({ name, params });
  }

  return {
    push,
    args: readonly(_args as Ref<Args<T>>),
    callback: _callback as Callback<U>,
  };
}
