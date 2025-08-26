import { supabase } from '@/lib/supabase/supabaseClient'
import type { PostgrestError } from '@supabase/supabase-js'
import type { AccountMembership, MembershipRole } from '@/models'

export async function createAccount(name: string) {
  const { data, error } = await supabase.rpc('create_account', { account_name: name })
  return { data, error }
}

export async function getAllAccounts(user_email: string): Promise<{ data: AccountMembership[] | null; error: PostgrestError | null }> {
  const { data, error } = await supabase.from('accounts_users_association').select('account_id, role, accounts(id, name)').eq('user_email', user_email).order('accounts(name)', { ascending: true })

  const accountsMemberships: AccountMembership[] | null =
    data?.map((item) => ({
      id: item.account_id,
      name: item.accounts?.name || 'Unknown Account',
      role: item.role,
    })) || null

  return { data: accountsMemberships, error }
}

export async function getAccount(id: string) {
  const { data, error } = await supabase.from('accounts').select('*').eq('id', id).single()
  return { data, error }
}

export async function updateAccount(id: string, values?: { name?: string; authorize_requests?: boolean }) {
  const { data, error } = await supabase
    .from('accounts')
    .update({
      name: values?.name,
      authorize_requests: values?.authorize_requests,
    })
    .eq('id', id)
    .select()
  return { data, error }
}

export async function deleteAccount(id: string) {
  const { data, error } = await supabase.from('accounts').delete().eq('id', id)
  return { data, error }
}

export async function addAccountUser(account_id: string, user_email: string, role: MembershipRole) {
  const { data, error } = await supabase
    .from('accounts_users_association')
    .insert({
      account_id,
      user_email,
      role,
    })
    .select()
  return { data, error }
}

export async function getAccountUsers(id: string) {
  const { data, error } = await supabase.from('accounts_users_association').select('role, user_email, created_at').eq('account_id', id)
  return { data, error }
}

export async function updateAccountUser(account_id: string, user_email: string, role: MembershipRole) {
  const { data, error } = await supabase
    .from('accounts_users_association')
    .update({
      role,
    })
    .eq('account_id', account_id)
    .eq('user_email', user_email)
    .select()
  return { data, error }
}

export async function removeAccountUser(id: string, email: string) {
  const { data, error } = await supabase.from('accounts_users_association').delete().eq('account_id', id).eq('user_email', email)
  return { data, error }
}

export async function addAccountAddress(account_id: string, address: string, name: string) {
  const { data, error } = await supabase
    .from('accounts_addresses')
    .insert({
      account_id,
      address,
      name,
    })
    .select()
  return { data, error }
}

export async function getAccountAddresses(id: string) {
  const { data, error } = await supabase.from('accounts_addresses').select('*').eq('account_id', id)
  return { data, error }
}

export async function updateAccountAddress(id: string, address: string, name: string) {
  const { data, error } = await supabase
    .from('accounts_addresses')
    .update({
      name,
    })
    .eq('id', id)
    .eq('address', address)
    .select()
  return { data, error }
}

export async function removeAccountAddress(id: string, address: string) {
  const { data, error } = await supabase.from('accounts_addresses').delete().eq('account_id', id).eq('address', address)
  return { data, error }
}

export async function createAccountSecret(account_id: string, name: string) {
  const { data, error } = await supabase
    .from('accounts_secrets')
    .insert({
      account_id,
      name,
    })
    .select()
  return { data, error }
}

export async function getAccountSecrets(account_id: string) {
  const { data, error } = await supabase.from('accounts_secrets').select('*').eq('account_id', account_id)
  return { data, error }
}

export async function deleteAccountSecret(account_id: string, secret: string) {
  const { data, error } = await supabase.from('accounts_secrets').delete().eq('account_id', account_id).eq('secret', secret)
  return { data, error }
}

export async function getAccountSubscription(account_id: string) {
  const { data, error } = await supabase
    .from('accounts')
    .select(
      `
      subscription_id,
      subscription_expiration_date,
      subscription_tiers (
        id,
        name,
        duration,
        allow_secondary_listings,
        allow_custom_currencies
      )
    `
    )
    .eq('id', account_id)
    .single()
  return { data, error }
}

export async function getAccountActiveListingsAppids(account_id: string, network: string) {
  const { data, error } = await supabase.from('listings').select('app_id').eq('account_id', account_id).in('status', ['pending', 'active']).eq('network', network)
  return { data, error }
}

export async function getAccountNetworksParameters(account_id: string) {
  const { data, error } = await supabase.from('accounts_networks_parameters').select('*').eq('account_id', account_id)
  return { data, error }
}

export async function createAccountNetworksParameters(account_id: string, network_id: string, enable_secondary: boolean, secondary_fee_address: string, secondary_percentage_fee: number) {
  const { data, error } = await supabase
    .from('accounts_networks_parameters')
    .insert({
      account_id,
      network_id,
      enable_secondary,
      secondary_fee_address,
      secondary_percentage_fee,
    })
    .select()
  return { data, error }
}

export async function updateAccountNetworksParameters(account_id: string, network_id: string, enable_secondary: boolean, secondary_fee_address: string, secondary_percentage_fee: number) {
  const { data, error } = await supabase
    .from('accounts_networks_parameters')
    .update({
      enable_secondary,
      secondary_fee_address,
      secondary_percentage_fee,
    })
    .eq('account_id', account_id)
    .eq('network_id', network_id)
    .select()
  return { data, error }
}

export async function getAccountCurrencies(account_id: string) {
  const { data, error } = await supabase.from('accounts_currencies').select('*').eq('account_id', account_id)
  return { data, error }
}

export async function addAccountCurrency(account_id: string, currency: number, network_id: string) {
  const { data, error } = await supabase
    .from('accounts_currencies')
    .insert({
      account_id,
      currency,
      network_id,
    })
    .select()
  return { data, error }
}

export async function removeAccountCurrency(account_id: string, currencyId: number, network_id: string) {
  const { data, error } = await supabase.from('accounts_currencies').delete().eq('account_id', account_id).eq('currency', currencyId).eq('network_id', network_id)
  return { data, error }
}

export async function createAccountJwtSecret(account_id: string, name: string) {
  const { data, error } = await supabase
    .from('accounts_secrets')
    .insert({
      account_id,
      name,
    })
    .select()
  return { data, error }
}

export async function getAccountJwtSecrets(account_id: string) {
  const { data, error } = await supabase.from('accounts_secrets').select('*').eq('account_id', account_id)
  return { data, error }
}

/**
 * Delete a JWT secret for an account.
 * @param account_id - The ID of the account.
 * @param secret_id - The secret to delete.
 */
export async function deleteAccountJwtSecret(account_id: string, secret: string) {
  const { data, error } = await supabase.from('accounts_secrets').delete().eq('account_id', account_id).eq('secret', secret)
  return { data, error }
}
