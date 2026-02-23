import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/Login.vue')
  },
  {
    path: '/',
    redirect: '/login'
  },
  {
    path: '/student/award',
    name: 'StudentAward',
    component: () => import('../views/StudentAward.vue'),
    meta: { requiresAuth: true, roles: ['student', 'admin'] }
  },
  {
    path: '/student/record',
    name: 'ApplicationRecord',
    component: () => import('../views/ApplicationRecord.vue'),
    meta: { requiresAuth: true, roles: ['student', 'admin'] }
  },
  {
    path: '/student/application/detail/:id',
    name: 'ApplicationDetail',
    component: () => import('../views/ApplicationDetail.vue'),
    meta: { requiresAuth: true, roles: ['student', 'admin', 'mentor'] }
  },
  {
    path: '/admin/review',
    name: 'AdminReview',
    component: () => import('../views/AdminReview.vue'),
    meta: { requiresAuth: true, roles: ['admin', 'mentor'] }
  },
  {
    path: '/admin/statistics',
    name: 'AdminStatistics',
    component: () => import('../views/AdminStatistics.vue'),
    meta: { requiresAuth: true, roles: ['admin', 'mentor'] }
  },
  {
    path: '/admin/competition',
    name: 'CompetitionManage',
    component: () => import('../views/CompetitionManage.vue'),
    meta: { requiresAuth: true, roles: ['admin', 'mentor'] }
  },
  {
    path: '/admin/student',
    name: 'StudentManage',
    component: () => import('../views/Student.vue'),
    meta: { requiresAuth: true, roles: ['admin', 'mentor'] }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  // 从 localStorage 获取用户信息
  const userInfo = localStorage.getItem('saims_user')
  
  if (to.path === '/login') {
    next()
  } else {
    if (!userInfo) {
      next('/login')
    } else {
      next()
    }
  }
})

export default router
