<script setup>
import { RouterLink } from 'vue-router';
import router from '../router';
import TextDetails from './TextDetailsField.vue';
import { functions } from '../FirebaseConfig';
import { httpsCallable } from '@firebase/functions';
import { state } from '../GlobalState';
</script>

<script>
export default {
    data() {
        return {
            showDetails: false,
        }
    },
    emits: ['update:dialogTitle', 'update:dialogText', 'update:dialogConfirmed', 'update:dialogVisible',],
    props: {
        'patientData': 'patientData',
        deletePatientCallback: {
            type: Function,
            required: true,
        },
        deletePillCallback: {
            type: Function,
            required: true,
        },
    },
    components: { RouterLink },
    methods: {
        getTiming(timing) {
            var time = new Date(timing);
            return time.getHours().toString().padStart(2, '0') + ':' + time.getMinutes().toString().padStart(2, '0');
        },
        goEditPill(pillName) {
            this.$router.push({
                name: 'editschedule', params: {
                    'patientEmail': this.patientData['email'],
                    'pill': pillName,
                }
            });
        },
        async fetchScheduleData() {
            this.showDialog('Updating details', 'Updating patient details...');
            const scheduleData = httpsCallable(functions, 'fetchPatientSchedule');
            await scheduleData({ 'patientUid': this.patientData['users_id'] })
                .then((result) => {
                    const data = result.data;
                    if (data['code'] == 200) {
                        state.patients[this.patientData['email']]['schedule'] = data['data'];
                    }
                });
        },
        removePatient() {
            this.deletePatientCallback(this.patientData['email'], this.patientData['users_id']);
        },
        onClickDelete(patientUID, patientEmail, pillName) {
            this.deletePillCallback(patientUID, patientEmail, pillName);
        },
    }
}
</script>
<style scoped>
.patient_section {
    display: flex;
    width: 100%;
}

.patient_details {
    width: 70%;
    padding-right: 20px;
}

a {
    color: #333;
    box-shadow: -3px 3px orange, -2px 2px orange, -1px 1px orange;
    border: 1px solid orange;
}

.option {
    margin: 20px 10px;
}

.options {
    padding-top: 20px;
    width: 30%;
}

a {
    background-color: #474EDD;
    background-image: -webkit-linear-gradient(283deg, rgba(255, 255, 255, 0.1) 50%, transparent 55%), -webkit-linear-gradient(top, rgba(255, 255, 255, 0.15), transparent);
    border-radius: 6px;
    box-shadow: 0 0 0 1px #163772 inset, 0 0 0 2px rgba(255, 255, 255, 0.15) inset, 0 4px 0 0 #333797, 0 4px 0 1px rgba(0, 0, 0, 0.4), 0 4px 4px 1px rgba(0, 0, 0, 0.5);
    color: white !important;
    display: block;
    font-family: "Lucida Grande", Arial, sans-serif;
    font-size: 15px;
    font-weight: bold;
    letter-spacing: -1px;
    line-height: 61px;
    text-align: center;
    text-shadow: 0 1px 1px rgba(0, 0, 0, 0.5);
    text-decoration: none !important;
    -webkit-transition: all .2s linear;
    transition: all .2s linear;
    width: 100%;
}

a:hover {
    background-color: #474EDD;
    top: 4px;
    box-shadow: 0 0 0 1px #163772 inset, 0 0 0 2px rgba(255, 255, 255, 0.15) inset, 0 0 0 0 #333797, 0 0 0 1px rgba(0, 0, 0, 0.4), 0 0px 8px 1px rgba(0, 0, 0, 0.5);
}

.schedule-details {
    margin-bottom: 20px;
}

.schedule {
    display: flex;
    flex-wrap: wrap;
    border: 1px solid black;
}

.scheduled-timings {
    display: flex;
    flex-wrap: wrap;
    flex-direction: column;
    align-items: flex-start;
    max-height: 100px;
}

.timing {
    margin: 0px 0px 0px 10px;
}

.details-btn {
    padding: 7px;
}

.details-btn:hover {
    background-color: rgba(100, 100, 100, 1);
    cursor: pointer;
}

.remove-patient-btn {
    text-align: center;
}

.remove-patient-btn:hover {
    background-color: rgba(100, 100, 100, 0.2);
    cursor: pointer;
}
</style>

<template>
    <section class="patient_section">
        <div class="patient_details">
            <h3 @click="removePatient" class="remove-patient-btn">Remove patient</h3>
            <div>
                <TextDetails class="details" label="Name" :modelValue="patientData['name']" />
                <TextDetails label="Email" :modelValue="patientData['email']" />
                <TextDetails label="Contact" :modelValue="patientData['contact_details']" />
            </div>
        </div>

        <div class="options">
            <div class="option">
                <RouterLink :to="{ name: 'pillschedule', params: { patientEmail: patientData['email'] } }">Add Patient's
                    Pill
                </RouterLink>
            </div>
            <div class="option">
                <RouterLink :to="{ name: 'weeklyreport', params: { patientEmail: patientData['email'] } }">View Weekly
                    Report</RouterLink>
            </div>
            <div class="option">
                <RouterLink :to="{ name: 'pillinformation', params: { patientEmail: patientData['email'] } }">Add Pill
                    Information</RouterLink>
            </div>
            <div class="option">
                <RouterLink :to="{ name: 'appointmentinfo', params: { patientEmail: patientData['email'] } }">Manage Patient Appointments</RouterLink>
            </div>
            <div class="option">
                <RouterLink :to="{ name: 'patientallergies', params: { patientEmail: patientData['email'] } }">Update Patient Allergies</RouterLink>
            </div>
            
        </div>
    </section>
    <div style="display: flex; margin-bottom: 10px;">
        <h3 v-if="!showDetails" @click="showDetails = !showDetails">Show Details</h3>
        <h3 v-if="showDetails" @click="showDetails = !showDetails">Hide Details</h3>
    </div>
    <section class="schedule-details" v-if="showDetails">
        <div>
            <h2>Allergies</h2>
            <div v-for="v, k in patientData['allergies']">
                <div v-if="v == 'true'">
                    <h2 style="padding: 0px 0px 0px 10px;  border: 1px solid black;">{{ k }}</h2>
                </div>
            </div>
        </div>
        <br />
        <h2>Pill Schedule</h2>
        <div style>
            <div class="schedule" v-for="e in patientData['schedule']">
                <div style="width: 30%; padding-left: 10px;">
                    <h3>Pill Name: {{ e['pill'] }}</h3>
                    <h3>Amount: {{ e['amount'] }}</h3>
                    <h3>Fequency: {{ e['frequency'] }}</h3>
                </div>
                <h3>Scheduled Timings:</h3>
                <div class="scheduled-timings">
                    <div v-for="t in e['scheduledTimes']">
                        <h3 class="timing">{{ getTiming(t) }}</h3>
                    </div>
                </div>
                <div style="margin-left: auto;" @click="goEditPill(e['pill'])">
                    <h3 class="details-btn">Edit</h3>
                </div>
                <div style="margin: 0px 10px;"
                    @click="onClickDelete(patientData['users_id'], patientData['email'], e['pill'])">
                    <h3 class="details-btn">Delete</h3>
                </div>
            </div>
        </div>
    </section>
</template>
