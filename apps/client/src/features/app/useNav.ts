import { readonly, ref, type Ref } from "vue";
import { type RouteParamsRawGeneric } from "vue-router";
import router from "@/features/app/router";

type Args = Record<string, any>;
type Callback = () => void;

const _args = ref<Args>({});
let _callback: Callback = () => {};

export default function useNav<
  A extends Args,
  C extends Callback = () => void,
>() {
  async function push(
    name: string,
    args: A,
    callback?: C,
    params?: RouteParamsRawGeneric,
  ) {
    _args.value = args;
    _callback = callback || _callback;
    return router.push({ name, params });
  }

  return {
    push,
    args: readonly(_args),
    callback: _callback,
  };
}
