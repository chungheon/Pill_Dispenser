import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import PatientView from '../views/PatientsView.vue'
import PageNotFound from '../views/PageNotFound.vue'
import AddPillSchedulePatient from '../views/AddPillSchedulePatient.vue'
import WeeklyReport from '../views/WeeklyReportView.vue'
import AddPillInformation from '../views/AddPillInformationView.vue'
import EditPillSchedulePatient from '../views/EditPillSchedulePatient.vue'
import PatientApptView from'../views/PatientApptView.vue'
import PatientAllergyView from '../views/PatientAllergyView.vue'


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
      path: '/patients/:patientEmail/:pill',
      name: 'editschedule',
      component: EditPillSchedulePatient,
    },
    {
      path: '/patients/:patientEmail/weeklyreport',
      name: 'weeklyreport',
      component: WeeklyReport,
    },
    {
      path: '/patients/:patientEmail/patientapptinfo',
      name: 'appointmentinfo',
      component: PatientApptView,
    },
    {
      path: '/patients/:patientEmail/patientallergies',
      name: 'patientallergies',
      component: PatientAllergyView,
    },
    {
      path: '/patients/:patientEmail/addpillinformation',
      name: 'pillinformation',
      component: AddPillInformation,
    },
    {
      path: '/:pathMatch(.*)*',
      name: 'notfound',
      component: PageNotFound,
    }
  ]
})

export default router
