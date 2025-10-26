import { ref } from 'vue'
import type { Ref } from 'vue'
import { defineStore } from 'pinia'
import type { Session, User } from '@supabase/supabase-js'
import { supabase } from '@/lib/supabase/supabaseClient'


export const useSessionStore = defineStore('session', () => {
  const self: Ref<Session | null> = ref(null)
  const user: Ref<User | null> = ref(null)

  supabase.auth.onAuthStateChange((event, session) => {
    console.log("Auth state change", event, session)
    user.value = session?.user || null
    self.value = session || null
  })

  return { self, user }
})
