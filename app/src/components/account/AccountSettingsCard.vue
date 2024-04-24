<template>
    <div
        class="my-5 w-full rounded-lg border border-gray-200 bg-white p-5 dark:border-gray-700 dark:bg-gray-900"
    >
        <h2 class="mb-2 text-lg font-semibold text-gray-900 dark:text-white">
            <slot name="title"></slot>
        </h2>
        <p class="mb-6 text-gray-500 dark:text-gray-400">
            <slot name="description"></slot>
        </p>
        <slot name="body"></slot>
    </div>
</template>

<script setup lang="ts"></script>
