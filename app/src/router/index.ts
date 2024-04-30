import { createRouter, createWebHistory } from 'vue-router'
import AuthView from '@/views/AuthView.vue'
import { useSessionStore } from '@/stores/session'
import TestView from '@/views/TestView.vue'
import DashboardLayout from '@/views/dashboard/DashboardLayout.vue'
import AccountSettingsView from '@/views/account/AccountSettingsView.vue'
import DashboardHomeView from '@/views/dashboard/DashboardHomeView.vue'
import DashboardListingsView from '@/views/dashboard/DashboardListingsView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/auth',
      name: 'authentication',
      component: AuthView
    },
    {
      path: '/dashboard',
      alias: '/',
      component: DashboardLayout,
      meta: { requiresAuth: true },
      children: [
        {
          path: '',
          name: 'dashboard',
          component: DashboardHomeView,
        },
        {
          path: 'account/settings',
          name: 'dashboard-account-settings',
          component: AccountSettingsView,
        },
        {
          path: 'listings',
          name: 'dashboard-listings',
          component: DashboardListingsView,
        }
      ]
    },
    {
      path: '/test',
      name: 'test',
      component: TestView
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
