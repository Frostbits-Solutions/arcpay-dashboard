import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import AuthView from '@/views/AuthView.vue'
import { useSessionStore } from '@/stores/session'
import AboutView from '@/views/AboutView.vue'
import TestView from '@/views/TestView.vue'
import DashboardView from '@/views/DashboardView.vue'
import AccountSettingsView from '@/views/Account/AccountSettingsView.vue'

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
      component: DashboardView,
      meta: { requiresAuth: true },
      children: [
        {
          path: '',
          name: 'dashboard',
          component: HomeView,
        },
        {
          path: 'account/settings',
          name: 'dashboard-account-settings',
          component: AccountSettingsView,
        }
      ]
    },
    {
      path: '/test',
      name: 'test',
      component: TestView
    },
    {
      path: '/about',
      name: 'about',
      component: AboutView,
      meta: { requiresAuth: true }
    },
  ]
})

router.beforeEach((to, from) => {
  const session = useSessionStore()
  if (to.meta.requiresAuth && !session.user) {
    return { name: 'authentication' }
  }
})

export default router
