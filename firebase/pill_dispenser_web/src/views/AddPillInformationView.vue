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

#add-pill-info-btn {
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
            <TextFormField label="Pill Name" v-model="pillName" width="100%" />
            <TextFormField label="Pill Information" v-model="pillInformation" width="100%" />
        </section>
        <section class="instruction-details">
            <p>If you enter a pill name that exists, it would replace the exisiting data. Capitalization is taken into
                account.</p>
            <button id="add-pill-info-btn" @click="clickAddPill">Add Pill Information</button>
        </section>
        <section class="display-details">
            <div>
                <h2>Pills Information</h2>
            </div>
            <div v-for="name in Object.keys(patientData['pill_info'] ?? {})">
                <h3>{{ name }}</h3>
                <p>{{ (patientData['pill_info'] ?? {})[name] }}</p>
                <div style="margin: 0px 10px;" @click="onClickDelete(name)">
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
            pillName: '',
            pillInformation: '',
            customDialogTitle: '',
            customDialogVisible: false,
            customDialogText: '',
            customDialogConfirmed: null,
            customDialogAllowCancel: false,
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
    },
    methods: {
        async fetchPillInfo() {
            const pillInfo = httpsCallable(functions, 'fetchPatientPillInformation');
            var patientEmail = this.$route?.params['patientEmail'];
            await pillInfo({ 'patientUid': state.patients[patientEmail]['users_id'] })
                .then((result) => {
                    const data = result.data;
                    state.patients[patientEmail]['pill_info'] = data['data'];
                });
        },
        async addPillInformation() {
            /*
                var pillName = data.pillName;
                var pillInfo = data.pillInfo;
                var patientUID = data.patientUid;
            */
            const addPillInfo = httpsCallable(functions, 'updatePillsInformation');
            return await addPillInfo({
                'patientUid': state.patients[this.patientEmail]['users_id'],
                'pillName': this.pillName,
                'pillInfo': this.pillInformation,
            });
        },
        async removePillInformation(pillName) {
            const addPillInfo = httpsCallable(functions, 'removePillInformation');
            return await addPillInfo({
                'patientUid': state.patients[this.patientEmail]['users_id'],
                'pillNames': [pillName],
            }).then(async (result) => {
                var data = result.data;
                if (data['code'] == 200) {
                    await this.fetchPillInfo();
                    this.customDialogTitle = 'Information removed';
                    this.customDialogText = 'Pill information has been removed';
                    this.customDialogConfirmed = () => {
                        this.resetCustomDialog();
                        this.customDialogConfirmed = null;
                    };
                }
            });
        },
        onClickDelete(pillName) {
            this.customDialogTitle = 'Are you sure?';
            this.customDialogText = 'Are you sure you want to delete?';
            this.customDialogAllowCancel = true;
            this.customDialogConfirmed = () => {
                this.customDialogTitle = 'Removing Information';
                this.customDialogText = 'Removing pill information from database...';
                this.customDialogAllowCancel = false;
                this.customDialogConfirmed = () => { };
                this.removePillInformation(pillName);
            };
            this.customDialogVisible = true;
        },
        resetCustomDialog() {
            this.customDialogVisible = false;
            this.customDialogText = '';
            this.customDialogConfirmed = null;
            this.customDialogTitle = '';
        },
        async clickAddPill() {
            console.log(this.pillName.trim().length);
            console.log(this.pillName.trim)
            if (this.pillName.trim().length > 0) {
                this.customDialogText = 'Adding Pill Information... Please Wait.';
                this.customDialogTitle = 'Adding Pill Information';
                this.customDialogConfirmed = null;
                this.customDialogVisible = true;
                var result = await this.addPillInformation();
                console.log(result);
                if (result['data']['code'] == 200) {
                    await this.fetchPillInfo();
                    this.customDialogText = 'Pill information has been added for patient.';
                    this.customDialogTitle = 'Pill Information Added';
                    this.customDialogConfirmed = () => {
                        this.resetCustomDialog();
                        this.pillName = '';
                        this.pillInformation = '';
                    };
                    this.customDialogVisible = true;
                } else {
                    this.customDialogText = 'Unable to add pill information. Please try again later.';
                    this.customDialogTitle = 'Pill Information Add Failed';
                    this.customDialogConfirmed = () => {
                        this.resetCustomDialog();
                    };
                    this.customDialogVisible = true;
                }
            } else {
                this.customDialogText = 'Pill Name cannot be empty!';
                this.customDialogTitle = 'Pill Name is empty!';
                this.customDialogConfirmed = () => {
                    this.resetCustomDialog();
                };
                this.customDialogVisible = true;
            }
        }
    }
}

</script>