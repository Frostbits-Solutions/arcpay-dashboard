<script setup lang="ts">
import { useAccountsStore } from '@/stores/accounts'
import { Button } from '@/components/ui/button'
import { Trash2, Package } from 'lucide-vue-next'
import {
    deleteAccountJwtSecret,
} from '@/lib/supabase/accounts'
import { h } from 'vue'
import ToastError from '@/components/ui/toast/ToastError.vue'
import ToastCheck from '@/components/ui/toast/ToastCheck.vue'
import { useToast } from '@/components/ui/toast'
import { Skeleton } from '@/components/ui/skeleton'
import { Clipboard } from '@/components/ui/clipboard'
import OrganizationGenerateSecretDialog from '@/components/organization/OrganizationGenerateSecretDialog.vue'
import JWTValidityTestingComponent from '@/components/organization/JWTValidityTestingComponent.vue'

const accounts = useAccountsStore()
const { toast } = useToast()

async function onDeleteJwtSecret(secret: string) {
    if (accounts.active?.id) {
        const { data, error } = await deleteAccountJwtSecret(
            accounts.active.id,
            secret
        )
        if (error) {
            toast({
                title: `Error deleting API key`,
                description: error.message,
                variant: 'destructive',
                action: h(ToastError),
            })
        } else {
            await accounts.fetchAccountSecrets(accounts.active.id)
            toast({
                title: `API key deleted`,
                action: h(ToastCheck),
            })
        }
    }
}
</script>

<template>
    <h2 class="text-2xl font-bold dark:text-white">Security</h2>
    <div class="relative mt-6">
        <div class="mb-8">
            <h4 class="text-md font-normal mb-1">Authentication</h4>
            <p class="text-sm text-muted-foreground mb-2">
                Your Account ID is required for all Arcpay API and SDK calls.<br>
                Send it as a header named <strong>x-arcpay-account-id</strong> in every request.<br>
                This header is used to authenticate your organization.
            </p>
            <div class="flex items-center gap-2">
                <span class="text-base font-semibold text-muted-foreground">Account ID :</span>
                <Clipboard
                    :source="accounts.active?.id.toString() || ''"
                    class="font-mono bg-muted px-3 py-1 rounded text-sm text-primary"
                />
            </div>
        </div>
    </div>
    <div class="relative mt-6">
        <div class="flex items-end justify-between gap-10 pb-4">
            <div>
                <h4 class="text-md mb-1 font-normal">JWT Secrets</h4>
                <p class="mb-2 text-sm text-muted-foreground">
                    Used to securely authenticate your users with Arcpay. <br />
                    Always generate and sign JWTs on your backend server.
                </p>
                <ul
                    class="mb-2 list-inside list-disc text-sm text-muted-foreground"
                >
                    <li>
                        Generate a signed JWT on your backend using the secret
                        and your desired payload.
                    </li>
                    <li>
                        Send the signed JWT to your frontend and use it when
                        initializing the Arcpay client.
                    </li>
                    <li>
                        All SDK/API requests will be authenticated using this
                        JWT.
                    </li>
                </ul>
                <p class="text-sm text-muted-foreground">
                    For more details, see the
                    <a
                        href="https://jwt.io/"
                        target="_blank"
                        class="text-primary underline transition-colors hover:text-primary/80"
                    >
                        JWT authentication documentation </a
                    >.
                </p>
                <br />
                <span
                    class="inline-flex items-center gap-2 rounded bg-yellow-100 px-2 py-1 text-xs font-medium text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200"
                >
                    <svg
                        class="h-4 w-4 text-yellow-500"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="2"
                        viewBox="0 0 24 24"
                    >
                        <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            d="M12 9v2m0 4h.01M21 12A9 9 0 1 1 3 12a9 9 0 0 1 18 0z"
                        />
                    </svg>
                    Never expose your JWT secret in your frontend code.
                </span>
            </div>
            <!-- Use JWT_SECRET constant -->
            <OrganizationGenerateSecretDialog >
                <Button variant="outline">Generate new secret</Button>
            </OrganizationGenerateSecretDialog>
        </div>
        <div class="overflow-hidden rounded-lg border border-border">
            <table
                class="w-full text-left text-sm text-muted-foreground rtl:text-right"
            >
                <thead
                    class="bg-muted/50 text-xs uppercase text-muted-foreground/50"
                >
                    <tr>
                        <th scope="col" class="px-6 py-3">Secret</th>
                        <th scope="col" class="px-6 py-3">Name</th>
                        <th scope="col" class="w-16"></th>
                    </tr>
                </thead>
                <tbody>
                    <template v-if="!accounts.loading">
                        <tr
                            v-for="secret in accounts.activeSettings.secrets"
                            :key="secret.secret"
                            class="border-b border-border last:border-b-0"
                        >
                            <td class="truncate px-6 py-4">
                                <Clipboard
                                    :source="secret.secret"
                                    class="min-w-64"
                                />
                            </td>
                            <td class="truncate px-6 py-4">
                                {{ secret.name }}
                            </td>

                            <td class="px-6 py-4">
                                <Button
                                    variant="ghost"
                                    size="icon"
                                    class="size-7 rounded-sm"
                                    @click="onDeleteJwtSecret(secret.secret)"
                                >
                                    <Trash2 class="size-4 text-destructive" />
                                </Button>
                            </td>
                        </tr>
                        <tr v-if="!accounts.activeSettings.secrets?.length">
                            <td
                                colspan="4"
                                class="px-6 py-4 text-center text-sm text-muted-foreground"
                            >
                                No secret
                            </td>
                        </tr>
                    </template>
                    <tr v-else>
                        <td class="px-6 py-4">
                            <Skeleton class="h-4 w-48" />
                        </td>
                        <td class="px-6 py-4">
                            <Skeleton class="h-4 w-48" />
                        </td>
                        <td class="px-6 py-4">
                            <Skeleton class="h-4 w-28" />
                        </td>
                        <td class="px-6 py-4">
                            <Skeleton class="h-5 w-8" />
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
    <a
            href="https://www.npmjs.com/package/arcpay-sdk"
            target="_blank"
            class="relative mt-6 flex h-16 items-center justify-start rounded-lg border border-border bg-muted/50 p-4 text-sm"
        >
            <Package class="mr-4 h-6 w-6" />
            Arcpay SDK npm package
            <ArrowUpRight
                class="absolute right-2 top-2 h-4 w-4 rotate-90 text-border"
            />
        </a>
    <JWTValidityTestingComponent />
</template>

<style scoped></style>
