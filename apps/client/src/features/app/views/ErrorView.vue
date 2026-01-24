<script lang="ts" setup>
import { computed, type Ref } from "vue";
import { Button } from "@repo/ui/button";
import useNav from "@/features/app/useNav.ts";
import type { Args, Callback } from "@/features/app/types.ts";

const { args, callback }: { args: Ref<Args>; callback: Callback } = useNav<
  Args,
  Callback
>();
const title = computed(() => args.value.title || "Success!");
const description = computed(() => args.value.description);
</script>

<template>
  <div class="flex flex-col w-[333px] h-[400px] mx-auto">
    <div class="flex-1 flex items-end justify-center pb-4">
      <div style="transform: translate(6px, -5px)">
        <svg
          class="checkmark"
          viewBox="0 0 52 52"
          xmlns="http://www.w3.org/2000/svg"
        >
          <defs>
            <linearGradient id="gradient">
              <stop offset="0%" stop-color="rgb(65, 88, 208)" />
              <stop offset="30%" stop-color="rgb(200, 80, 192)" />
              <stop offset="100%" stop-color="rgb(255, 204, 112)" />
            </linearGradient>
          </defs>
          <circle
            class="checkmark__circle"
            cx="26"
            cy="26"
            fill="none"
            r="25"
          />
          <path
            class="checkmark__check"
            d="M16 16 36 36 M36 16 16 36"
            fill="none"
          />
        </svg>
      </div>
    </div>
    <div
      class="w-full flex-1 pt-4 text-center flex flex-col items-center gap-2 justify-between"
    >
      <div
        class="animate-in slide-in-from-bottom-2 fade-in delay-75 fill-mode-both"
      >
        <div v-if="title" class="text-md font-semibold text-foreground">
          {{ title }}
        </div>
        <div v-if="description" class="text-xs text-muted-foreground break-all">
          {{ description }}
        </div>
      </div>
      <Button
        class="mb-8 grow-0 w-24"
        size="lg"
        variant="secondary"
        @click="callback"
        >Close
      </Button>
    </div>
  </div>
</template>

<style scoped>
.checkmark {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  display: block;
  stroke-width: 2;
  stroke: url(#gradient);
  stroke-miterlimit: 10;
  animation:
    fill 0.4s ease-in-out 0.4s forwards,
    scale 0.3s ease-in-out 0.9s both;
  position: relative;
  top: 5px;
  right: 5px;
  margin: 0 auto;
}

.checkmark__circle {
  stroke-dasharray: 166;
  stroke-dashoffset: 166;
  stroke-width: 2;
  stroke-miterlimit: 10;
  stroke: url(#gradient);
  animation: stroke 0.6s cubic-bezier(0.65, 0, 0.45, 1) forwards;
}

.checkmark__check {
  transform-origin: 50% 50%;
  stroke-dasharray: 48;
  stroke-dashoffset: 48;
  animation: stroke 0.3s cubic-bezier(0.65, 0, 0.45, 1) 0.8s forwards;
}

@keyframes stroke {
  100% {
    stroke-dashoffset: 0;
  }
}

@keyframes scale {
  0%,
  100% {
    transform: none;
  }

  50% {
    transform: scale3d(1.1, 1.1, 1);
  }
}
</style>
