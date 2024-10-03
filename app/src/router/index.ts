import { createRouter, createWebHistory } from 'vue-router'
import AuthView from '@/views/AuthView.vue'
import { useSessionStore } from '@/stores/session'
import ListingsView from '@/views/ListingsView.vue'
import OrganizationSettingsView from '@/views/OrganizationSettingsView.vue'
import OrganizationSettingsGeneral from '@/components/organization/OrganizationSettingsGeneral.vue'
import OrganizationSettingsIntegrations from '@/components/organization/OrganizationSettingsIntegrations.vue'
import OrganizationSettingsUsers from '@/components/organization/OrganizationSettingsUsers.vue'
import OrganizationSettingsListings from '@/components/organization/OrganizationSettingsListings.vue'
import DashboardView from '@/views/DashboardView.vue'
import DirectLinkView from '@/views/DirectLinkView.vue'
import AuthenticatedView from '@/views/AuthenticatedView.vue'

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
