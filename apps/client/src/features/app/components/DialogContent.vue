<script lang="ts" setup>
import { computed, type HTMLAttributes } from "vue";
import {
  DialogClose,
  DialogContent,
  type DialogContentEmits,
  type DialogContentProps,
  DialogOverlay,
  DialogPortal,
  useForwardPropsEmits,
} from "radix-vue";
import { Cross2Icon } from "@radix-icons/vue";
import { cn } from "@repo/shared/utils";
import { useRoute } from "vue-router";
import { GlobeLock } from "lucide-vue-next";
import { ScrollArea } from "@repo/ui/scroll-area";
import logo from "@repo/ui/assets/logo.png";

const props = defineProps<
  DialogContentProps & { class?: HTMLAttributes["class"] }
>();
const emits = defineEmits<DialogContentEmits>();

const delegatedProps = computed(() => {
  const { class: _, ...delegated } = props;

  return delegated;
});
const route = useRoute();
const forwarded = useForwardPropsEmits(delegatedProps, emits);
</script>

<template>
  <DialogPortal disabled>
    <DialogOverlay
      class="fixed top-0 left-0 flex items-end sm:items-center justify-center h-dvh w-dvw z-50 bg-slate-100/55 dark:bg-slate-900/80 backdrop-blur-sm data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0"
    >
      <div
        class="absolute hidden sm:flex bottom-0 text-muted-foreground text-xs p-4 justify-start sm:justify-center items-center w-full"
      >
        Powered by<img
          alt="Arcpay logo"
          class="h-5 ml-1 mr-0.5"
          :src="logo"
        />arcpay
      </div>
      <DialogContent
        :class="
          cn(
            'w-dvw sm:w-auto border border-border bg-background/35 backdrop-blur-lg shadow-2xl z-50 flex max-h-[80dvh] items-stretch justify-stretch duration-200 data-[state=open]:animate-in data-[state=open]:slide-in-from-bottom data-[state=closed]:animate-out data-[state=closed]:slide-out-to-bottom data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:sm:zoom-out-95 data-[state=open]:sm:zoom-in-95 data-[state=open]:sm:slide-in-from-bottom-16 rounded-2xl transition-all',
            props.class,
          )
        "
        v-bind="forwarded"
      >
        <ScrollArea class="flex-1">
          <div class="py-6 px-4 sm:px-6">
            <slot />
          </div>
        </ScrollArea>
        <DialogClose
          v-if="route.meta.closeable"
          class="absolute right-4 top-4 rounded-sm opacity-70 ring-offset-background transition-opacity hover:opacity-100 focus:outline-none disabled:pointer-events-none data-[state=open]:bg-accent data-[state=open]:text-muted-foreground bg-background/20"
        >
          <Cross2Icon class="w-4 h-4" />
          <span class="sr-only">Close</span>
        </DialogClose>
      </DialogContent>
    </DialogOverlay>
  </DialogPortal>
</template>
