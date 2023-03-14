<script setup>
import { reactive, watch } from 'vue';
import PatientDetails from '../components/PatientDetails.vue';
import { state } from '../GlobalState';
import { httpsCallable } from '@firebase/functions';
import { functions } from '../FirebaseConfig';
import { update } from '@firebase/database';
</script>

<script>
export default {
  data() {
    watch(state, (newVal, oldVal) => {
      this.fetchAllPatientsData();
    });
    return {
      isLoading: false,
    }
  },
  beforeMount() {
    this.fetchAllPatientsData();
  },
  methods: {
    async fetchAllPatientsData() {
      if (Object.keys(state.patients).length > 0 && !this.isLoading) {
        this.isLoading = true;
        const reportPromise = this.fetchReport();
        const schedulePromise = this.fetchScheduleData();
        const pillPromise = this.fetchPillInfo();
        await Promise.all([reportPromise, schedulePromise, pillPromise]);
        this.isLoading = false;
      }
    },
    async fetchReport() {
      const reportData = httpsCallable(functions, 'fetchReportData');
      for (var patient of Object.keys(state.patients)) {
        if (state.patients[patient]['report'] == null) {
          reportData({ 'patientUid': state.patients[patient]['users_id'] })
            .then((result) => {
              const data = result.data;
              state.patients[patient]['report'] = data['data'];
            });
        }
      }


    },
    async fetchScheduleData() {
      const scheduleData = httpsCallable(functions, 'fetchPatientSchedule');
      for (var patient of Object.keys(state.patients)) {
        if (state.patients[patient]['schedule'] == null) {
          scheduleData({ 'patientUid': state.patients[patient]['users_id'] })
            .then((result) => {
              const data = result.data;
              state.patients[patient]['schedule'] = data['data'];
            });
        }
      }
    },
    async fetchPillInfo() {
      const pillInfo = httpsCallable(functions, 'fetchPatientPillInformation');
      for (var patient of Object.keys(state.patients)) {
        if (state.patients[patient]['pill_info'] == null) {
          pillInfo({ 'patientUid': state.patients[patient]['users_id'] })
            .then((result) => {
              const data = result.data;
              state.patients[patient]['pill_info'] = data['data'];
            });
        }
      }
    },
  }
}
</script>

<style scoped>
main {
  min-height: 95vh;
  width: 100%;
}

.patient_details {
  padding-left: 20px;
  padding-right: 20px;
}
</style>


<template>
  <main>
    <section v-if="!isLoading">
      <section class="patient_details" v-if="Object.keys(state.patients).length > 0">
        <div v-for="email in Object.keys(state.patients)">
          <PatientDetails :patientData="state.patients[email]" />
          <hr class="solid">
        </div>
      </section>
      <section v-else>
        <h1>You have no patients</h1>
      </section>
    </section>
    <section v-else>
      <p>Fetching Patient's Information</p>
    </section>
  </main>
</template>
