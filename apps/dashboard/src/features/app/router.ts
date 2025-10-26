import { createRouter, createWebHistory } from 'vue-router'
import AuthView from '@/features/auth/views/AuthView.vue'
import { useSessionStore } from '@/features/auth/stores/session'
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
          component: () => import('@/features/listings/views/ListingsView.vue'),
        },
        {
          path: '/organization/:name/settings',
          name: 'organization-organization',
          component: () => import('@/features/accounts/views/AccountSettingsView.vue'),
          children: [
            {
              path: '',
              name: 'organization-organization-general',
              component: () => import('@/features/accounts/components/OrganizationSettingsGeneral.vue'),
            },
            {
              path: 'users',
              name: 'organization-organization-users',
              component: () => import('@/features/accounts/components/OrganizationSettingsUsers.vue'),
            },
            {
              path: 'security',
              name: 'organization-organization-security',
              component: () => import('@/features/accounts/components/OrganizationSettingsSecurity.vue'),
            },
            {
              path: 'listings',
              name: 'organization-organization-listings',
              component: () => import('@/features/accounts/components/OrganizationSettingsListings.vue'),
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
