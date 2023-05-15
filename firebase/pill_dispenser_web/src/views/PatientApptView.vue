<script setup>
import { functions } from '../FirebaseConfig';
import { httpsCallable } from '@firebase/functions';
import TextDetails from '../components/TextDetailsField.vue';
import TextFormField from '../components/TextFormField.vue';
import CustomDialog from '../components/DialogForm.vue';
import { state } from '../GlobalState';
</script>

<style scoped>
.edit-details {
    padding: 0px 20px
}

.instruction-details {
    padding: 0px 20px
}

.display-details {
    padding: 0px 20px;
}

.patient_details {
    padding: 0px 20px;
    display: flex;
}

.details {
    width: 50%;
    padding: 10px 0px 10px 10px;
}


h2 {
    font-weight: 500;
}

h3 {
    font-weight: 500;
    padding: 10px 0px 0px 0px;
}

p {
    padding: 0px 20px 10px 20px;
}

#update-appt-btn {
    width: 100%;
    margin: 10px 0px;
    font-size: 1.2em;
}

.details-btn {
    padding: 7px;
    display: inline-flex;
}

.details-btn:hover {
    background-color: rgba(100, 100, 100, 1);
    cursor: pointer;
}
</style>

<template>
    <main>
        <section class="patient_details">
            <TextDetails class="details" label="Patient's Name" :modelValue="patientData['name']" />
            <TextDetails class="details" label="Contact" :modelValue="patientData['contact_details']" />
        </section>
        <section class="edit-details">
            <TextFormField label="Appointment Name" v-model="apptName" width="100%" />
            <TextFormField label="Message(Optional)" hintText="Message" v-model="apptMsg" width="100%" />
            <div style="display: flex;">
                <p style="font-size: 1.2rem;">Select a Date: </p>
                <input type="datetime-local" id="datetime-selector" :min=minDate style="font-size: 1.5rem;" v-model="apptDateTime"/>
            </div>
        </section>
        <section class="instruction-details">

            <button id="update-appt-btn" @click="clickUpdateAppt">Update Patient Appointment</button>
        </section>
        <section class="display-details">
            <div>
                <h2>Appoinments</h2>
            </div>
            <div v-for="apptId in Object.keys(patientData['appt'] ?? {})">
                <h3>Appointment Name: {{ patientData['appt'][apptId]['name'] }}</h3>
                <h3>Message: {{ patientData['appt'][apptId]['message'] }}</h3>
                <h3>Date: {{ new Date(patientData['appt'][apptId]['apptDateTime']).toLocaleString('en-US', {
                    weekday: 'long',
                    year: 'numeric', month: 'numeric', day: 'numeric', hour: 'numeric', minute: 'numeric'
                }) }}</h3>
                <div style="margin: 0px 10px;" @click="onClickDelete(apptId)">
                    <h3 class="details-btn">Delete</h3>
                </div>
                <hr class="solid">
            </div>

        </section>
        <CustomDialog :title="customDialogTitle" :message="customDialogText" :visible="customDialogVisible"
            @confirmed="customDialogConfirmed" :allowCancel="customDialogAllowCancel" @cancelled="resetCustomDialog" />
    </main>
</template>

<script>
export default {
    data() {
        return {
            patientEmail: null,
            patientData: null,
            apptName: '',
            apptMsg: '',
            apptDateTime: null,
            customDialogTitle: '',
            customDialogVisible: false,
            customDialogText: '',
            customDialogConfirmed: null,
            customDialogAllowCancel: false,
            minDate: null,
        }
    },
    beforeMount() {
        this.patientEmail = this.$route.params['patientEmail'];
        if (this.patientEmail == null) {
            this.$router.push({ name: 'notfound' });
        }
        this.patientData = state.patients[this.patientEmail];
        if (this.patientData == null) {
            this.$router.push({ name: 'notfound' });
        }
        var now = new Date()
        this.minDate = new Date();
        this.minDate.setDate(now.getDate() + 1);
        this.apptDateTime = new Date(this.minDate);
        this.minDate = this.minDate.toISOString().slice(0,new Date().toISOString().lastIndexOf(":"));
    },
    methods: {
        async fetchApptInfo() {
            const apptInfo = httpsCallable(functions, 'fetchAppointmentsData');
            var patientEmail = this.$route?.params['patientEmail'];
            await apptInfo({ 'patientUid': state.patients[patientEmail]['users_id'] })
                .then((result) => {
                    const data = result.data;
                    state.patients[patientEmail]['appt'] = data['data'];
                });
        },
        async updatePatientAppt() {
            /*
                var apptDateTime = data.apptDateTime;
                var apptName = data.apptName;
                var apptMsg = data.apptMsg;
                var patientUID = data.patientUid;
            */
            const updatePatientAppt = httpsCallable(functions, 'updatePatientAppt');
            console.log(state.patients[this.patientEmail]['users_id']);
            return await updatePatientAppt({
                'apptDateTime': this.apptDateTime.valueOf(),
                'apptName': this.apptName,
                'apptMsg': this.apptMsg,
                'patientUid': state.patients[this.patientEmail]['users_id'],
            });
        },
        async removeAppt(apptId) {
            const removePatientAppt = httpsCallable(functions, 'removePatientAppt');
            return await removePatientAppt({
                'patientUid': state.patients[this.patientEmail]['users_id'],
                'apptId': apptId,
            }).then(async (result) => {
                var data = result.data;
                if (data['code'] == 200) {
                    await this.fetchApptInfo();
                    this.customDialogTitle = 'Appointment removed';
                    this.customDialogText = 'Appointment has been removed';
                    this.customDialogConfirmed = () => {
                        this.resetCustomDialog();
                        this.customDialogConfirmed = null;
                    };
                }
            });
        },
        onClickDelete(apptId) {
            this.customDialogTitle = 'Are you sure?';
            this.customDialogText = 'Are you sure you want to delete?';
            this.customDialogAllowCancel = true;
            this.customDialogConfirmed = () => {
                this.customDialogTitle = 'Removing Appointment';
                this.customDialogText = 'Removing appointment from patient...';
                this.customDialogAllowCancel = false;
                this.customDialogConfirmed = () => { };
                this.removeAppt(apptId);
            };
            this.customDialogVisible = true;
        },
        resetCustomDialog() {
            this.customDialogVisible = false;
            this.customDialogText = '';
            this.customDialogConfirmed = null;
            this.customDialogTitle = '';
        },
        async clickUpdateAppt() {

            if (this.apptName.trim().length > 0 || this.apptDateTime == null) {
                this.customDialogText = 'Updating Patient Appointments... Please Wait.';
                this.customDialogTitle = 'Updating Patient Appointment';
                this.customDialogConfirmed = null;
                this.customDialogVisible = true;
                var result = await this.updatePatientAppt();
                if (result['data']['code'] == 200) {
                    await this.fetchApptInfo();
                    this.customDialogText = 'Patient Appointment Updated';
                    this.customDialogTitle = 'Patient Appointment Updated';
                    this.customDialogConfirmed = () => {
                        this.resetCustomDialog();
                        this.apptName = '';
                        this.apptMsg = '';
                    };
                    this.customDialogVisible = true;
                } else {
                    this.customDialogText = 'Unable to update patient appointment. Please try again later.';
                    this.customDialogTitle = 'Patient Appointment Update Failed';
                    this.customDialogConfirmed = () => {
                        this.resetCustomDialog();
                    };
                    this.customDialogVisible = true;
                }
            } else {
                this.customDialogText = 'Appointment Name cannot be empty!';
                this.customDialogTitle = 'Appointment Name is empty!';
                this.customDialogConfirmed = () => {
                    this.resetCustomDialog();
                };
                this.customDialogVisible = true;
            }
        },
    }
}

</script>