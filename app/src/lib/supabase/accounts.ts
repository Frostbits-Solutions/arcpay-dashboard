import { supabase } from '@/lib/supabase/supabaseClient'
import type { PostgrestError } from '@supabase/supabase-js'
type accountsMemberships = { id: number, name: string, role: 'admin'|'member'|'moderator'|'owner' }[]

export async function createAccount(name: string, owner_email: string) {
  const { data, error } = await supabase
    .from('accounts')
    .insert([{
      name,
      owner_email
    }])
  return { data, error }
}

export async function getAllAccounts(user_email: string): Promise<{ data: accountsMemberships | null, error: PostgrestError | null }> {
  const { data: ownershipData, error: ownershipError } = await supabase
    .from('accounts')
    .select('id, name')
    .eq('owner_email', `${user_email}`)
  if (ownershipError) return { data: null, error: ownershipError }

  const { data:membershipData, error:membershipError } = await supabase
    .from('accounts_users_association')
    .select('account_id, role, accounts(name)')
    .eq('user_email', user_email)
  if (membershipError) return { data: null, error: membershipError }

  const data:accountsMemberships = []
  ownershipData?.forEach((account) => {
    data.push({ ...account, role: 'owner' })
  })

  membershipData?.forEach((account) => {
    data.push({ id: account.account_id, name: account?.accounts?.name || 'account' , role: account.role })
  })

  return { data, error: null }
}

export async function getAccount(id: number) {
  const { data, error } = await supabase
    .from('accounts')
    .select('*')
    .eq('id', id)
    .single()
  return { data, error }
}

export async function updateAccount(id: number, name: string | undefined, enable_secondary_sales: boolean | undefined, secondary_sales_percentage_fee: number | undefined){
  const { data, error } = await supabase
    .from('accounts')
    .update({
      name: name,
      s_enable_secondary_sales: enable_secondary_sales,
      s_secondary_sales_percentage_fee: secondary_sales_percentage_fee
    })
    .eq('id', id)
    .select()
  return { data, error }
}

export async function deleteAccount(id: number) {
  const { data, error } = await supabase
    .from('accounts')
    .delete()
    .eq('id', id)
  return { data, error }
}

export async function addAccountUser(account_id: number, user_email: string, role: 'admin' | 'member') {
  const { data, error } = await supabase
    .from('accounts_users_association')
    .insert({
      account_id,
      user_email,
      role
    })
    .select()
  return { data, error }
}

export async function getAccountUsers(id: number) {
  const { data, error } = await supabase
    .from('accounts_users_association')
    .select('role, user_email')
    .eq('account_id', id)
  return { data, error }
}

export async function updateAccountUser(account_id: number, user_email: string, role: 'admin' | 'member') {
  const { data, error } = await supabase
    .from('accounts_users_association')
    .update({
      role
    })
    .eq('account_id', account_id)
    .eq('user_email', user_email)
    .select()
  return { data, error }
}

export async function removeAccountUser(id: string, email: string) {
  const { data, error } = await supabase
    .from('accounts_users_association')
    .delete()
    .eq('account_id', id)
    .eq('user_email', email)
  return { data, error }
}

export async function addAccountAddress(account_id: number, address: string, name: string, chain: 'voi:testnet'|'voi:mainnet') {
  const { data, error } = await supabase
    .from('accounts_addresses')
    .insert({
      account_id,
      address,
      name,
      chain
    })
    .select()
  return { data, error }
}

export async function getAccountAddresses(id: number) {
  const { data, error } = await supabase
    .from('accounts_addresses')
    .select('*')
    .eq('account_id', id)
  return { data, error }
}

export async function updateAccountAddress(id: number, address: string, name: string) {
  const { data, error } = await supabase
    .from('accounts_addresses')
    .update({
      name
    })
    .eq('id', id)
    .eq('address', address)
    .select()
  return { data, error }
}

export async function removeAccountAddress(id: number, address: string) {
  const { data, error } = await supabase
    .from('accounts_addresses')
    .delete()
    .eq('id', id)
    .eq('address', address)
  return { data, error }
}

export async function createAccountApiKey(account_id: number, domain: string, name: string) {
  const { data, error } = await supabase
    .from('accounts_api_keys')
    .insert({
      account_id,
      name,
      domain
    })
    .select()
  return { data, error }
}

export async function getAccountApiKeys(account_id: number) {
  const { data, error } = await supabase
    .from('accounts_api_keys')
    .select('*')
    .eq('account_id', account_id)
  return { data, error }
}

export async function updateAccountApiKey(account_id: number, key: number, domain: string, name: string) {
  const { data, error } = await supabase
    .from('accounts_api_keys')
    .update({
      domain,
      name
    })
    .eq('account_id', account_id)
    .eq('key', key)
    .select()
  return { data, error }
}

export async function deleteAccountApiKey(account_id: number, key: number) {
  const { data, error } = await supabase
    .from('accounts_api_keys')
    .delete()
    .eq('account_id', account_id)
    .eq('key', key)
  return { data, error }
}
