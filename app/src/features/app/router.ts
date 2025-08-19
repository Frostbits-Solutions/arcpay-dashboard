import { createRouter, createWebHistory } from 'vue-router'
import AuthView from '@/features/auth/views/AuthView.vue'
import { useSessionStore } from '@/features/auth/stores/session'
import ListingsView from '@/features/listings/views/ListingsView.vue'
import AccountSettingsView from '@/features/accounts/views/AccountSettingsView.vue'
import OrganizationSettingsGeneral from '@/features/accounts/components/OrganizationSettingsGeneral.vue'
import OrganizationSettingsSecurity from '@/features/accounts/components/OrganizationSettingsSecurity.vue'
import OrganizationSettingsUsers from '@/features/accounts/components/OrganizationSettingsUsers.vue'
import OrganizationSettingsListings from '@/features/accounts/components/OrganizationSettingsListings.vue'
import DashboardView from '@/features/dashboard/views/DashboardView.vue'
import AuthenticatedView from '@/features/auth/views/AuthenticatedView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/auth',
      name: 'authentication',
      component: AuthView,
    },
    {
      path: '/',
      name: 'authenticated-view',
      component: AuthenticatedView,
      meta: { requiresAuth: true },
      redirect: { name: 'dashboard' },
      children: [
        {
          path: '/dashboard',
          name: 'dashboard',
          component: DashboardView,
        },
        {
          path: '/listings',
          name: 'listings',
          component: ListingsView,
        },
        {
          path: '/organization/:name/settings',
          name: 'organization-organization',
          component: AccountSettingsView,
          children: [
            {
              path: '',
              name: 'organization-organization-general',
              component: OrganizationSettingsGeneral,
            },
            {
              path: 'users',
              name: 'organization-organization-users',
              component: OrganizationSettingsUsers,
            },
            {
              path: 'security',
              name: 'organization-organization-security',
              component: OrganizationSettingsSecurity,
            },
            {
              path: 'listings',
              name: 'organization-organization-listings',
              component: OrganizationSettingsListings,
            },
          ],
        },
      ],
    },
  ],
})

router.beforeEach((to, from) => {
  const session = useSessionStore()
  if (to.meta.requiresAuth && !session.user) {
    return { name: 'authentication' }
  }
})

export default router
