<script lang="ts" setup>
import useNav from "@/features/app/useNav";
import { computed, type Ref } from "vue";

interface Args {
  title?: string;
  description?: string;
}

const args: Ref<Args> = useNav<Args, any>().args;
const title = computed(() => args.value.title || "Loading...");
const description = computed(() => args.value.description);
</script>

<template>
  <div class="flex flex-col w-[333px] h-[400px] mx-auto">
    <div class="flex-1 flex items-end justify-center pb-4">
      <div style="transform: translate(6px, -5px)">
        <svg
          class="spinner"
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
          <circle class="spinner__circle" cx="26" cy="26" fill="none" r="25" />
        </svg>
      </div>
    </div>
    <div
      class="w-full flex-1 pt-4 text-center flex flex-col items-center g2 justify-between animate-in slide-in-from-bottom-2 fade-in delay-75 fill-mode-both animate-out slide-out-to-top-2"
    >
      <div>
        <div
          v-motion-slide-bottom
          class="text-md font-semibold text-foreground"
          :key="title"
        >
          {{ title }}
        </div>
        <div
          v-if="description"
          class="text-xs text-muted-foreground whitespace-pre-line"
        >
          {{ description }}
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.spinner {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  display: block;
  position: relative;
  top: 5px;
  right: 5px;
  margin: 0 auto;
}

.spinner__circle {
  stroke-dasharray: 166;
  stroke-dashoffset: 166;
  stroke-width: 2;
  stroke-miterlimit: 10;
  stroke: url(#gradient);
  animation:
    stroke 0.6s linear forwards,
    rotate 0.9s linear 0.6s infinite;
  transform-origin: 50% 50%;
}

@keyframes stroke {
  100% {
    stroke-dashoffset: 25;
  }
}

@keyframes rotate {
  100% {
    transform: rotate(360deg);
  }
}
</style>
