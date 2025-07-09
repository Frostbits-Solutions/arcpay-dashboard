<script setup lang="ts">
import { useAccountsStore } from '@/features/accounts/stores/accounts'
import { Button } from '@/lib/ui/button'
import { Trash2, Package } from 'lucide-vue-next'
import { deleteAccountJwtSecret, updateAccount } from '@/features/accounts/services/accounts'
import { h } from 'vue'
import ToastError from '@/lib/ui/toast/ToastError.vue'
import ToastCheck from '@/lib/ui/toast/ToastCheck.vue'
import { useToast } from '@/lib/ui/toast'
import { Skeleton } from '@/lib/ui/skeleton'
import { ArrowUpRight } from 'lucide-vue-next'
import { Clipboard } from '@/lib/ui/clipboard'
import OrganizationGenerateSecretDialog from '@/features/accounts/components/OrganizationGenerateSecretDialog.vue'
import { Switch } from '@/lib/ui/switch'

const accounts = useAccountsStore()
const { toast } = useToast()

async function toggleAuthorization(value: boolean) {
  if (accounts.active?.id) {
    const { data, error } = await updateAccount(accounts.active.id, { authorize_requests: value })
    if (error) {
      toast({
        title: `Error updating authorization`,
        description: error.message,
        variant: 'destructive',
        action: h(ToastError),
      })
    } else {
      if (accounts.activeSettings?.settings) accounts.activeSettings.settings.authorize_requests = value
    }
  }
}

async function onDeleteJwtSecret(secret: string) {
  if (accounts.active?.id) {
    const { data, error } = await deleteAccountJwtSecret(accounts.active.id, secret)
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
  <p class="text-sm text-muted-foreground">Access control. Manage who can access your listings.</p>
  <div class="mt-10 flex items-center justify-between rounded-lg border border-border bg-muted/50 p-4">
    <div>
      <h4 class="text-md font-normal">Authorize requests</h4>
      <p class="text-sm text-muted-foreground">
        When activated, only requests with a valid JWT token will be permitted.<br />This allows to control who can interact with your listings and enables you to add extra layers of access control.
      </p>
    </div>
    <Switch @update:checked="toggleAuthorization" :checked="accounts.activeSettings.settings?.authorize_requests" />
  </div>
  <div v-if="accounts.activeSettings.settings?.authorize_requests" class="relative mt-2 rounded-lg border border-border p-4" v-motion-fade>
    <div class="flex items-center justify-between gap-10 pb-4">
      <div>
        <h4 class="text-md mb-1 font-normal">JWT Secrets</h4>
        <p class="text-sm text-muted-foreground">
          JWT Secrets are used to sign and verify JSON Web Tokens (JWTs). Signed JWTs are used to authenticate requests to your listings and to ensure that only authorized users can access them. JWTs
          must be generated and signed by your backend. Secrets should <span class="font-bold">NEVER</span> be exposed in your front-end code.<br />
        </p>
        <span class="mt-2 inline-flex items-center gap-2 rounded-sm bg-yellow-100 px-2 py-1 text-sm font-medium text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200">
          <svg class="size-5 text-yellow-500" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01M21 12A9 9 0 1 1 3 12a9 9 0 0 1 18 0z" />
          </svg>
          Never expose JWT secrets in your front-end code.
        </span>
      </div>
      <OrganizationGenerateSecretDialog>
        <Button variant="outline">Generate new secret</Button>
      </OrganizationGenerateSecretDialog>
    </div>
    <div class="overflow-hidden rounded-lg border border-border">
      <table class="w-full text-left text-sm text-muted-foreground rtl:text-right">
        <thead class="bg-muted/50 text-xs uppercase text-muted-foreground/50">
          <tr>
            <th scope="col" class="px-6 py-3">Secret</th>
            <th scope="col" class="px-6 py-3">Name</th>
            <th scope="col" class="w-16"></th>
          </tr>
        </thead>
        <tbody>
          <template v-if="!accounts.loading">
            <tr v-for="secret in accounts.activeSettings.secrets" :key="secret.secret" class="border-b border-border last:border-b-0">
              <td class="truncate px-6 py-4">
                <Clipboard :secret="true" :source="secret.secret" class="text-xs" />
              </td>
              <td class="truncate px-6 py-4">
                {{ secret.name }}
              </td>

              <td class="px-6 py-4">
                <Button variant="ghost" size="icon" class="size-7 rounded-sm" @click="onDeleteJwtSecret(secret.secret)">
                  <Trash2 class="size-4 text-destructive" />
                </Button>
              </td>
            </tr>
            <tr v-if="!accounts.activeSettings.secrets?.length">
              <td colspan="4" class="px-6 py-4 text-center text-sm text-muted-foreground">No secret</td>
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
</template>

<style scoped></style>
