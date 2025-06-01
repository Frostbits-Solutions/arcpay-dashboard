<script setup lang="ts">
import { ref } from 'vue'
import { supabase } from '@/lib/supabase/supabaseClient' // adjust import if needed

const accountId = ref('')
const jwt = ref('')
const result = ref<string | null>(null)
const error = ref<string | null>(null)

async function testJwt() {
  result.value = null
  error.value = null
  try {
    // Call a protected endpoint with custom headers
    const { error: rpcError, data } = await supabase.rpc('verify_arcpay_jwt_request', {}, {
      headers: {
        'x-arcpay-account-id': accountId.value,
        'x-arcpay-jwt': jwt.value,
      },
    })
    if (rpcError) {
      error.value = rpcError.message
    } else {
      result.value = 'JWT is valid!'
    }
  } catch (e: any) {
    error.value = e.message || String(e)
  }
}
</script>

<template>
  <div class="border p-4 rounded-lg bg-muted/50 max-w-xl mx-auto mt-10">
    <h2 class="text-lg font-bold mb-4">Test Arcpay JWT Function</h2>
    <div class="mb-2">
      <label class="block mb-1 font-medium">Account ID</label>
      <input v-model="accountId" class="input w-full" placeholder="Enter account id" />
    </div>
    <div class="mb-2">
      <label class="block mb-1 font-medium">JWT</label>
      <textarea v-model="jwt" class="input w-full" rows="3" placeholder="Paste JWT here"></textarea>
    </div>
    <button class="btn btn-primary mt-2" @click="testJwt">Test JWT</button>
    <div v-if="result" class="mt-4 text-green-600 font-semibold">{{ result }}</div>
    <div v-if="error" class="mt-4 text-red-600 font-semibold">{{ error }}</div>
  </div>
</template>

<style scoped>
.input {
  @apply border rounded px-2 py-1 bg-white text-black;
}
.btn {
  @apply px-4 py-2 rounded bg-primary text-white font-bold;
}
</style>
