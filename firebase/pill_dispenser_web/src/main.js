import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

import './assets/main.css';

import VueApexCharts from 'vue3-apexcharts';


/* import the fontawesome core */
import { library } from '@fortawesome/fontawesome-svg-core'

/* import font awesome icon component */
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'

/* import specific icons */
import { faPlus, faMinus } from '@fortawesome/free-solid-svg-icons'

/* add icons to the library */
library.add(faPlus, faMinus);

createApp(App)
.use(router)
.use(VueApexCharts)
.component('font-awesome-icon', FontAwesomeIcon)
.mount('#app')
