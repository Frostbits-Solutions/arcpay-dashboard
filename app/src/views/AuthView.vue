<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '@/lib/supabase/supabaseClient'
import { useRouter } from 'vue-router'
import ButtonSpinner from '@/components/common/ButtonSpinner.vue'

const router = useRouter()
const loading = ref(false)
const email = ref('')
const register = ref(false)
const success = ref(false)

const handleLogin = async () => {
    try {
        loading.value = true
        const { error } = await supabase.auth.signInWithOtp({
            email: email.value,
            options: {
                emailRedirectTo: `${window.location.origin}/auth`
            }
        })
        if (error) throw error
        success.value = true
    } catch (error) {
        if (error instanceof Error) {
            alert(error.message)
        }
    } finally {
        loading.value = false
    }
}

onMounted(() => {
    supabase.auth.getSession().then((session) => {
        if (session) {
            router.replace({ path: '/dashboard' })
        }
    })
})
</script>

<template>
    <div class="flex items-center justify-center h-screen bg-gray-50 dark:bg-gray-900">
        <div class="w-full max-w-sm rounded-xl border border-gray-200 bg-white p-4 shadow-xl sm:p-6 md:p-8 dark:border-gray-700 dark:bg-gray-800 animate-modal">
          <div class="mb-8 flex items-center justify-center">
            <img src="@/assets/logo.png" alt="Logo" class="w-12 h-12" />
            <h1 class="text-4xl ml-2 dark:text-white">arcpay</h1>
          </div>
          <form v-if="!success" class="space-y-6 border-t pt-8 dark:border-gray-700" @submit.prevent="handleLogin">
            <div>
              <label for="email" class="mb-2 block text-sm font-medium text-gray-900 dark:text-white">Your email</label>
              <input v-model="email" type="email" name="email" id="email" class="block w-full rounded-lg border border-gray-300 bg-gray-50 p-2.5 text-sm text-gray-900 focus:border-blue-500 focus:ring-blue-500 dark:border-gray-500 dark:bg-gray-600 dark:text-white dark:placeholder-gray-400" placeholder="name@company.com" required />
            </div>
            <button type="submit" class="w-full rounded-lg bg-blue-700 px-5 py-2.5 text-center text-sm font-medium text-white hover:bg-blue-800 focus:outline-none focus:ring-4 focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800">
              <template v-if="!loading">
                <template v-if="register">Register with magic link</template>
                <template v-else>Login with magic link</template>
              </template>
              <ButtonSpinner v-else class="w-6 h-6 fill-white dark:fill-gray-300"/>
            </button>
            <div v-if="register" class="text-sm font-medium text-gray-500 dark:text-gray-300">
              Already registered?
              <a @click.prevent="register = false" href="#" class="text-blue-700 hover:underline dark:text-blue-500">Sign-in</a>
            </div>
            <div v-else class="text-sm font-medium text-gray-500 dark:text-gray-300">
              Not registered?
              <a @click.prevent="register = true" href="#" class="text-blue-700 hover:underline dark:text-blue-500">Create account</a>
            </div>
          </form>
          <div v-else class="space-y-6 border-t pt-8 dark:border-gray-700 text-center text-gray-700 dark:text-gray-200">
            Check your email for the login link!
          </div>
        </div>
    </div>
</template>
