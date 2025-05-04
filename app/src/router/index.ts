import { createRouter, createWebHistory } from 'vue-router'
import AuthView from '@/features/auth/views/AuthView.vue'
import { useSessionStore } from '@/features/auth/stores/session'
import ListingsView from '@/features/listings/views/ListingsView.vue'
import OrganizationSettingsView from '@/features/settings/views/OrganizationSettingsView.vue'
import OrganizationSettingsGeneral from '@/features/settings/components/OrganizationSettingsGeneral.vue'
import OrganizationSettingsIntegrations from '@/features/settings/components/OrganizationSettingsIntegrations.vue'
import OrganizationSettingsUsers from '@/features/settings/components/OrganizationSettingsUsers.vue'
import OrganizationSettingsListings from '@/features/settings/components/OrganizationSettingsListings.vue'
import DashboardView from '@/features/dashboard/views/DashboardView.vue'
import DirectLinkView from '@/features/directlink/views/DirectLinkView.vue'
import AuthenticatedView from '@/features/auth/views/AuthenticatedView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/auth',
      name: 'authentication',
      component: AuthView
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
          component: OrganizationSettingsView,
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
              path: 'integrations',
              name: 'organization-organization-integrations',
              component: OrganizationSettingsIntegrations,
            },
            {
              path: 'listings',
              name: 'organization-organization-listings',
              component: OrganizationSettingsListings,
            }
          ]
        }
      ]
    },
    {
      path: '/:chain/listing/:id',
      name: 'listing',
      component: DirectLinkView,
      props: true
    }
  ]
})

router.beforeEach((to, from) => {
  const session = useSessionStore()
  if (to.meta.requiresAuth && !session.user) {
    return { name: 'authentication' }
  }
})

export default router
