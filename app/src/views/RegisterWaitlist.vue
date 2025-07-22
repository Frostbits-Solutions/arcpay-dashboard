<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '@/lib/supabase/supabaseClient'
import { useRouter } from 'vue-router'
import { Spinner } from '@/components/ui/spinner'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'

const router = useRouter()
const loading = ref(false)
const email = ref('')
const success = ref(false)
const errorMessage = ref('')

const handleWaitlistSignup = async () => {
    errorMessage.value = ''
    try {
        loading.value = true
        const { error } = await supabase
            .from('mailing_wait_list')
            .insert([{ email: email.value }])

        if (error) {
            const lowerMsg = error.message?.toLowerCase() || ''
            if (
                lowerMsg.includes('duplicate') ||
                lowerMsg.includes('already exists')
            ) {
                errorMessage.value = 'This email is already on the waitlist.'
                return
            }
            throw error
        }

        success.value = true
    } catch (error) {
        errorMessage.value =
            error instanceof Error
                ? error.message
                : 'An unexpected error occurred.'
    } finally {
        loading.value = false
    }
}

onMounted(() => {
    supabase.auth.getSession().then(({ data }) => {
        if (data.session) {
            loading.value = true
            setTimeout(() => {
                router.replace({ path: '/dashboard' })
            }, 1000)
        }
    })
})
</script>

<template>
    <div class="flex h-screen items-center justify-center bg-muted/30">
        <div
            class="w-full max-w-sm rounded-xl border border-border bg-popover p-4 shadow-xl sm:p-6 md:p-8"
        >
            <div class="mb-4 flex items-center justify-center">
                <img src="@/assets/logo.png" alt="Logo" class="mr-2 h-14" />
                <h1 class="text-5xl text-foreground">arcpay</h1>
            </div>

            <form
                v-if="!success"
                class="mt-8 border-t border-border pt-10"
                @submit.prevent="handleWaitlistSignup"
            >
                <div>
                    <label
                        for="email"
                        class="mb-2 block text-sm font-medium text-foreground"
                        >Your email</label
                    >
                    <Input
                        v-model="email"
                        type="email"
                        name="email"
                        id="email"
                        class="h-10"
                        placeholder="name@company.com"
                        required
                    />
                </div>

                <Button
                    variant="gradient"
                    type="submit"
                    size="lg"
                    class="mb-2 mt-12 w-full"
                >
                    <template v-if="!loading">Join the waitlist</template>
                    <Spinner v-else class="h-6 w-6 text-white" />
                </Button>

                <div
                    v-if="errorMessage"
                    class="mt-2 text-center text-xs text-red-600"
                >
                    {{ errorMessage }}
                </div>

                <div
                    class="mb-3 mt-6 text-center text-xs text-muted-foreground"
                >
                    Registration is temporarily closed. But you can join the
                    waitlist to be notified when it reopens.
                </div>
            </form>

            <div
                v-else
                class="space-y-6 border-t pt-8 text-center text-gray-700 dark:border-gray-700 dark:text-gray-200"
            >
                You're on the list! 🎉<br />We'll reach out as soon as
                registration reopens.
            </div>
        </div>
    </div>
</template>
