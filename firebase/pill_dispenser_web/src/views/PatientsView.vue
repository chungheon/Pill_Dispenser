<script setup>
import { reactive, watch } from 'vue';
import PatientDetails from '../components/PatientDetails.vue';
import { state, fetchingState } from '../GlobalState';
import { httpsCallable } from '@firebase/functions';
import { functions } from '../FirebaseConfig';
import { update } from '@firebase/database';
import CustomDialog from '../components/DialogForm.vue';
import TextFormField from '../components/TextFormField.vue';
</script>

<script>
export default {
  data() {
    watch(state, (newVal, oldVal) => {
      this.fetchAllPatientsData();
    });
    return {
      isLoading: false,
      patientEmail: "",
      customDialogText: "",
      customDialogVisible: false,
      customDialogConfirmed: null,
      customDialogTitle: "",
      customDialogAllowCancel: false,
    };
  },
  mounted() {
    this.fetchAllPatientsData();
  },
  methods: {
    async fetchAllPatientsData() {
      if (Object.keys(state.patients).length > 0 && !this.isLoading && !fetchingState.fetchingPatientDetails) {
        fetchingState.fetchingPatientDetails = true;
        this.isLoading = true;
        const reportPromise = this.fetchReport();
        const schedulePromise = this.fetchScheduleData();
        const pillPromise = this.fetchPillInfo();
        const apptPromise = this.fetchApptInfo();
        await Promise.all([reportPromise, schedulePromise, pillPromise, apptPromise]);
        this.isLoading = false;
        fetchingState.fetchingPatientDetails = false;
      }
    },
    async fetchReport() {
      const reportData = httpsCallable(functions, "fetchReportData");
      for (var patient of Object.keys(state.patients)) {
        if (state.patients[patient] != 'pending' && state.patients[patient]["report"] == null) {
          await reportData({ "patientUid": state.patients[patient]["users_id"] })
            .then((result) => {
              const data = result.data;
              state.patients[patient]["report"] = data["data"];
            });
        }
      }
    },
    async fetchPatientSchedule(patientUID, patientEmail) {
      const scheduleData = httpsCallable(functions, "fetchPatientSchedule");
      await scheduleData({ "patientUid": patientUID })
        .then((result) => {
          const data = result.data;
          state.patients[patientEmail]["schedule"] = data["data"];
        });
    },
    async fetchScheduleData() {
      const scheduleData = httpsCallable(functions, "fetchPatientSchedule");
      for (var patient of Object.keys(state.patients)) {
        if (state.patients[patient] != 'pending' && state.patients[patient]["schedule"] == null) {
          await scheduleData({ "patientUid": state.patients[patient]["users_id"] })
            .then((result) => {
              const data = result.data;
              state.patients[patient]["schedule"] = data["data"];
            });
        }
      }
    },
    async fetchPillInfo() {
      const pillInfo = httpsCallable(functions, "fetchPatientPillInformation");
      for (var patient of Object.keys(state.patients)) {
        if (state.patients[patient] != 'pending' && state.patients[patient]["pill_info"] == null) {
          await pillInfo({ "patientUid": state.patients[patient]["users_id"] })
            .then((result) => {
              const data = result.data;
              state.patients[patient]["pill_info"] = data["data"];
            });
        }
      }
    },
    async fetchApptInfo() {
      const apptInfo = httpsCallable(functions, 'fetchAppointmentsData');
      for (var patient of Object.keys(state.patients)) {
        if (state.patients[patient] != 'pending' && state.patients[patient]["appt"] == null) {
          await apptInfo({ 'patientUid': state.patients[patient]['users_id'] })
            .then((result) => {
              const data = result.data;
              state.patients[patient]['appt'] = data['data'];
            });
        }
      }
    },
    onClickDeletePatient(patientEmail, patientUID) {
      this.showCustomDialog("Are you sure?", "Are you sure you wish to delete patient " + patientEmail + "?");
      this.customDialogAllowCancel = true;
      this.customDialogConfirmed = () => {
        this.showCustomDialog("Deleting Patient", "Patient is being removed from list.");
        this.customDialogConfirmed = () => { };
        this.customDialogAllowCancel = false;
        this.deletePatient(patientEmail, patientUID);
      };
    },
    async deletePill(patientUID, patientEmail, pillName) {
      const removePill = httpsCallable(functions, "removePillSchedule");
      removePill({ "patientUid": patientUID, "pillNames": [pillName] })
        .then(async (result) => {
          const data = result.data;
          if (data["code"] == 200) {
            await this.fetchPatientSchedule(patientUID, patientEmail);
            this.showCustomDialog("Pill Deleted", "Pill has been deleted");
            this.customDialogConfirmed = () => this.resetCustomDialog();
          }
          else {
            this.showCustomDialog("Unable to delete", "Pill is unable to be deleted! Try again later.");
            this.customDialogConfirmed = () => this.resetCustomDialog();
          }
        });
    },
    onClickDeletePill(patientUID, patientEmail, pillName) {
      this.showCustomDialog("Are you sure?", "Are you sure you wish to delete " + pillName + "?");
      this.customDialogAllowCancel = true;
      this.customDialogConfirmed = () => {
        this.showCustomDialog("Deleting Pill", "Deleting pill from database.");
        this.customDialogConfirmed = () => { };
        this.customDialogAllowCancel = false;
        this.deletePill(patientUID, patientEmail, pillName);
      };
    },
    onClickRequest() {
      var patientEmail = this.patientEmail.toString().toLowerCase();
      if (this.validateEmail(patientEmail)) {
        this.customDialogTitle = "Request as guardian?";
        this.customDialogText = "Request to be guardian for " + patientEmail + "?";
        this.showCustomDialog("Request as guardian", "Request to be guardian for " + patientEmail + "?");
        this.customDialogAllowCancel = true;
        this.customDialogConfirmed = () => {
          this.customDialogAllowCancel = false;
          this.requestGuardian(patientEmail);
          this.customDialogConfirmed = () => { };
        };
      }
    },
    validateEmail(patientEmail) {
      var error = "Unable to request because:";
      if (patientEmail.trim().length <= 0) {
        this.showCustomDialog("Unable to request", "No email has been entered.");
        return false;
      }
      if (state.patients[patientEmail] != null) {
        this.showCustomDialog("Unable to request", "Email is already registered as a patient.");
        return false;
      }
      return true;
    },
    async requestGuardian(patientEmail) {
      this.showCustomDialog("Sending request", "Sending request to be guardian...");
      const requestGuardian = httpsCallable(functions, "reqGuardian");
      requestGuardian({ "patientEmail": patientEmail }).then((result) => {
        var data = result.data;
        if (data["code"] == 200) {
          this.showCustomDialog("Request Sent!", "Request to be guardina has been sent!");
          this.patientEmail = '';
          this.fetchRelationships();
          this.customDialogConfirmed = () => this.resetCustomDialog();
        }
        else {
          this.showCustomDialog("Request Failed!", data["message"]);
          this.customDialogConfirmed = () => this.resetCustomDialog();
        }
      });
    },
    async deletePatient(patientEmail, patientUID) {
      // var grdEmail = data.grdEmail.toLowerCase();
      // var grdUID = data.grdUID;
      // var patientEmail = data.patientEmail.toLowerCase();
      // var patientUID = data.patientUID;
      const deletePatient = httpsCallable(functions, "removeGuardianPatient");
      deletePatient({
        grdEmail: state.user.email,
        grdUID: state.user.uid,
        patientEmail: patientEmail,
        patientUID: patientUID,
      }).then((result) => {
        var data = result.data;
        if (data["code"] == 200) {
          this.showCustomDialog("Patient deleted", "Patient has been removed from list.");
          this.fetchPatient();
        }
        else {
          this.showCustomDialog("Unable to delete", "Unable to delete patient. Please try again later.");
          ƒ;
        }
      });
    },
    fetchRelationships() {
      fetchingState.fetchingRelationships = true;
      const relationships = httpsCallable(functions, 'fetchRelationships');
      relationships()
        .then((result) => {
          const data = result.data;
          console.log(data);
          state.patients = data['patients'] ?? {};
          state.guardians = data['guardians'] ?? {};
          fetchingState.fetchingRelationships = false;
        });

    },
    async fetchPatient() {
      this.showCustomDialog("Fetching patients list", "Fetching updated patients list...");
      fetchingState.fetchingRelationships = true;
      const relationships = httpsCallable(functions, "fetchRelationships");
      relationships()
        .then((result) => {
          const data = result.data;
          console.log(data);
          this.showCustomDialog("Updated patients list", "Patients list has been updated.");
          this.customDialogConfirmed = this.resetCustomDialog();
          state.patients = data["patients"] ?? {};
          state.guardians = data["guardians"] ?? {};
          fetchingState.fetchingRelationships = false;
        });
    },
    showCustomDialog(title, message) {
      this.customDialogTitle = title;
      this.customDialogText = message;
      this.customDialogVisible = true;
    },
    resetCustomDialog() {
      this.customDialogVisible = false;
      this.customDialogText = "";
      this.customDialogConfirmed = null;
      this.customDialogTitle = "";
    }
  },
  components: { TextFormField }
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

.request-section {
  margin: 0px 20px 20px 20px;
}

.request-btn {
  width: 100%;
  padding: 5px;
}
</style>


<template>
  <main>
    <section class="request-section">
      <TextFormField label='Patient Email' v-model="patientEmail" hint="Enter Patient's Email" width="100%" />
      <button class="request-btn" @click="onClickRequest">Send Request</button>
    </section>
    <section v-if="fetchingState.fetchingRelationships">
      <section style="display: flex;">
        <h2 style="margin: auto; padding: 20px">Fetching Patient Records</h2>
      </section>
    </section>
    <section v-else>
      <section v-if="!fetchingState.fetchingPatientDetails">
        <section class="patient_details" v-if="Object.keys(state.patients).length > 0">
          <div v-for="email in Object.keys(state.patients)">
            <div v-if="state.patients[email] == 'pending'">
              <h2>{{ email }} is pending</h2>
              <hr class="solid">
            </div>
          </div>
          <div v-for="email in Object.keys(state.patients)">
            <div v-if="state.patients[email] != 'pending'">
              <PatientDetails :deletePatientCallback="onClickDeletePatient" :deletePillCallback="onClickDeletePill"
                :patientData="state.patients[email]" v-on:update:dialogTitle="customDialogTitle = $event"
                v-on:update:dialogText="customDialogText = $event"
                v-on:update:dialogVisible="customDialogVisible = $event"
                v-on:update:dialogConfirmed="customDialogConfirmed = $event" />
              <hr class="solid">
            </div>
          </div>

        </section>
        <section style="display: flex;" v-else>
          <h2 style="margin: auto; padding: 20px">You have no patients</h2>
        </section>
      </section>
      <section v-else>
        <section style="display: flex;">
          <h2 style="margin: auto; padding: 20px">Fetching Patient's Information</h2>
        </section>
      </section>
    </section>
    <CustomDialog :title="customDialogTitle" :message="customDialogText" :visible="customDialogVisible"
      @confirmed="customDialogConfirmed" @cancelled="resetCustomDialog" :allowCancel="customDialogAllowCancel" />
  </main>
</template>
