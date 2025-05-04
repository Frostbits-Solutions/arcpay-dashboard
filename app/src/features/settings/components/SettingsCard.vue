<script setup lang="ts">
import { useSlots } from 'vue'

const slots = useSlots()
</script>

<template>
    <div class="my-4 w-full rounded-lg border border-border bg-background p-5">
        <h2 v-if="slots.title" class="mb-2 text-lg font-semibold text-foreground">
            <slot name="title"></slot>
        </h2>
        <p v-if="slots.description" class="mb-6 text-muted-foreground">
            <slot name="description"></slot>
        </p>
        <slot></slot>
    </div>
</template>