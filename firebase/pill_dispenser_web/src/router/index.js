import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import PatientView from '../views/PatientsView.vue'
import PageNotFound from '../views/PageNotFound.vue'
import AddPillSchedulePatient from '../views/AddPillSchedulePatient.vue'
import WeeklyReport from '../views/WeeklyReportView.vue'


const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView
    },
    {
      path: '/patients',
      name: 'patients',
      component: PatientView,
    },
    {
      path: '/patients/:patientEmail/addpillschedule',
      name: 'pillschedule',
      component: AddPillSchedulePatient,
    },
    {
      path: '/patients/:patientEmail/weeklyreport',
      name: 'patients',
      component: WeeklyReport,
    },
    {
      path:'/:pathMatch(.*)*',
      name: 'notfound',
      component: PageNotFound,
    }
  ]
})

export default router
