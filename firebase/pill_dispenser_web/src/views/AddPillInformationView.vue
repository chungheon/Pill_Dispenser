<script setup>
import { functions } from '../FirebaseConfig';
import { httpsCallable } from '@firebase/functions';
import TextFormField from '../components/TextFormField.vue';
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
</style>

<template>
    <main>
        <section class="edit-details">
            <TextFormField label="Pill Name" :v-model="pillName" width="100%" />
            <TextFormField label="Pill Information" :v-model="pillInformation" width="100%" />
        </section>
        <section class="instruction-details">
            <p>If you enter a pill name that exists, it would replace the exisiting data. Capitalization is taken into
                account.</p>
        </section>
        <section class="display-details">
            <div>
                <h2>Pills Information</h2>
            </div>
            <div v-for="name in Object.keys(patientData['pill_info'] ?? {})">
                <h3>{{ name }}</h3>
                <p>{{ (patientData['pill_info'] ?? {})[name] }}</p>
                <hr class="solid">
            </div>
        </section>
    </main>
</template>

<script>
export default {
    data() {
        return {
            patientData: null,
            pillName: '',
            pillInformation: '',
        }
    },
    beforeMount() {
        var patientEmail = this.$route?.params['patientEmail'];
        this.patientData = state.patients[patientEmail];
        if (this.patientData == null) {
            this.$router.push({ name: 'notfound' });
        }
    },
    methods: {
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

        async addPillInformation() {
            const addPillInfo = httpsCallable(functions, '');
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