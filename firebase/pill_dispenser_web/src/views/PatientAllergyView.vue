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

#add-allergy-btn {
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
            <TextFormField label="Allergy" v-model="allergyName" width="100%" />
        </section>
        <section class="instruction-details">
            <button id="add-allergy-btn" @click="clickAddAllergy">Add Allergy</button>
        </section>
        <section class="display-details">
            <div>
                <h2>Allergies</h2>
            </div>
            <div v-for="name in Object.keys(patientData['allergies'] ?? {})">
                <div v-if="patientData['allergies'][name] == 'true'">
                    <h3>{{ name }}</h3>
                    <div style="margin: 0px 10px;" @click="onClickDelete(name)">
                        <h3 class="details-btn">Delete</h3>
                    </div>
                    <hr class="solid">
                </div>
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
            allergyName: '',
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
        updateAllergiesLocally(allergyName, toRemove) {
            console.log(state.patients[this.patientEmail]['allergies']);
            state.patients[this.patientEmail]['allergies'][allergyName] = (!toRemove).toString();
        },
        async addPatientAllergy() {
            /*
                var allergyName = data.allergyName;
                var patientUID = data.patientUid;
                var patientEmail = data.patientEmail;
            */
            const addPatientAllergy = httpsCallable(functions, 'addPatientAllergy');
            return await addPatientAllergy({
                'patientUid': state.patients[this.patientEmail]['users_id'],
                'patientEmail': this.patientEmail,
                'allergyName': this.allergyName,
            });
        },
        async removePatientAllergy(allergyName) {
            const removePatientAllergy = httpsCallable(functions, 'removePatientAllergy');
            return await removePatientAllergy({
                'patientUid': state.patients[this.patientEmail]['users_id'],
                'patientEmail': this.patientEmail,
                'allergyName': allergyName,
            }).then(async (result) => {
                var data = result.data;
                if (data['code'] == 200) {
                    this.updateAllergiesLocally(allergyName, true);
                    this.customDialogTitle = 'Allergy removed';
                    this.customDialogText = 'Allergy has been removed';
                    this.customDialogConfirmed = () => {
                        this.resetCustomDialog();
                        this.customDialogConfirmed = null;
                    };
                }
            });
        },
        onClickDelete(allergyName) {
            this.customDialogTitle = 'Are you sure?';
            this.customDialogText = 'Are you sure you want to delete?';
            this.customDialogAllowCancel = true;
            this.customDialogConfirmed = () => {
                this.customDialogTitle = 'Removing Allergy';
                this.customDialogText = 'Removing Allergy from Patient...';
                this.customDialogAllowCancel = false;
                this.customDialogConfirmed = () => { };
                this.removePatientAllergy(allergyName);
            };
            this.customDialogVisible = true;
        },
        resetCustomDialog() {
            this.customDialogVisible = false;
            this.customDialogText = '';
            this.customDialogConfirmed = null;
            this.customDialogTitle = '';
        },
        async clickAddAllergy() {
            if (this.allergyName.trim().length > 0) {
                this.customDialogText = 'Adding Allergy... Please Wait.';
                this.customDialogTitle = 'Adding Allergy';
                this.customDialogConfirmed = null;
                this.customDialogVisible = true;
                var result = await this.addPatientAllergy();
                if (result['data']['code'] == 200) {
                    this.updateAllergiesLocally(this.allergyName, false);
                    this.customDialogText = 'Allergy has been added for patient.';
                    this.customDialogTitle = 'Allergy Added';
                    this.customDialogConfirmed = () => {
                        this.resetCustomDialog();
                        this.allergyName = '';
                    };
                    this.customDialogVisible = true;
                } else {
                    this.customDialogText = 'Unable to add allergy. Please try again later.';
                    this.customDialogTitle = 'Allergy Add Failed';
                    this.customDialogConfirmed = () => {
                        this.resetCustomDialog();
                    };
                    this.customDialogVisible = true;
                }
            } else {
                this.customDialogText = 'Allergy Name cannot be empty!';
                this.customDialogTitle = 'Allergy Name is empty!';
                this.customDialogConfirmed = () => {
                    this.resetCustomDialog();
                };
                this.customDialogVisible = true;
            }
        }
    }
}

</script>