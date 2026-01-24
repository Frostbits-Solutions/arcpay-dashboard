import router from "@/features/app/router";
import useNav from "@/features/app/useNav";
import type { Args, Callback } from "@/features/app/types.ts";

const nav = useNav<Args, Callback>();

export async function closeDialog() {
  return router.push("/");
}

export async function load(title: string, description: string) {
  return nav.push("loading", { title, description });
}

export async function displayError(
  title: string,
  description: string,
  callback: () => void,
) {
  return nav.push("error", { title, description }, callback);
}

export async function success(
  title: string,
  description: string,
  callback: () => void,
) {
  return nav.push("success", { title, description }, callback);
}
