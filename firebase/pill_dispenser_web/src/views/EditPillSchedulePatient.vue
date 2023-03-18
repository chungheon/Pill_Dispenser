<script setup>
import TextDetails from '../components/TextDetailsField.vue';
import { state } from '../GlobalState';
import DialogTimePicker from '../components/DialogTimePicker.vue';
import TextFormField from '../components/TextFormField.vue';
import CustomDialog from '../components/DialogForm.vue';
import { httpsCallable } from '@firebase/functions';
import { functions } from '../FirebaseConfig';
</script>

<script>
export default {
    data() {
        return {
            patientData: {},
            patientEmail: null,
            selectedTime: null,
            dialogVisible: false,
            selectedHour: "00",
            selectedMinute: "00",
            isLoading: false,
            selectedDateTime: null,
            timingsList: [],
            selectedIndex: 0,
            amount: 1,
            freq: 1,
            name: '',
            ingestType: 0,
            customDialogTitle: '',
            customDialogVisible: false,
            customDialogText: '',
            customDialogConfirmed: null,
        }
    },
    components: {
        DialogTimePicker
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

        this.name = this.$route.params['pill'];
        if (this.patientData['schedule'][this.name] == null) {
            this.$router.push({ name: 'notfound' });
        }
        this.setData(this.patientData['schedule'][this.name]);
        if (this.timingsList.length == 0) {
            let currTime = new Date;
            currTime.setMinutes(currTime.getMinutes() < 30 ? 0 : 30);
            currTime.setSeconds(0);
            this.timingsList.push(currTime)
        }
    },
    methods: {
        setData(pillData) {
            console.log(pillData);
            this.amount = pillData['amount'];
            this.freq = pillData['frequency'];
            this.ingestType = pillData['ingestType'];
            this.timingsList = [];
            for (var timing of (pillData['scheduledTimes'] ?? [])) {
                console.log(timing);
                console.log(new Date(timing));
                this.timingsList.push(new Date(timing));
            }
        },
        toggleDialog(index) {
            this.selectedHour = this.timingsList[index].getHours().toString().padStart(2, '0');
            this.selectedMinute = this.timingsList[index].getMinutes() < 30 ? '00' : '30';
            this.selectedIndex = index;
            this.dialogVisible = !this.dialogVisible;
        },
        storeSelectedTime(selectedTime) {
            selectedTime.setSeconds(0);
            this.timingsList[this.selectedIndex] = selectedTime;
        },
        handleChange(event) {
            this.selectedDateTime = event.target.value;
        },
        incrementTimings() {
            let currTime = new Date;
            currTime.setMinutes(currTime.getMinutes() < 30 ? 0 : 30);
            currTime.setSeconds(0);
            this.timingsList.push(currTime);
        },
        decrementTimings(index) {
            this.timingsList.splice(index, 1);
        },
        displayTiming(timing) {
            let hour = timing.getHours();
            let minutes = timing.getMinutes();
            if (minutes < 30) {
                minutes = 0;
            } else {
                minutes = 30;
            }

            let timeStr = hour.toString().padStart(2, '0') + ":" + minutes.toString().padStart(2, '0');
            return timeStr;
        },
        validatePill() {
            let error = '';
            if (this.name.trim().length == 0) {
                error += "Name cannot be empty\n";
            }

            return error;
        },
        schedulePill() {
            /*
                var pillName = data.pillName;
                var pillAmount = data.pillAmount;
                var pillFrequency = data.pillFrequency;
                var type = data.type;
                var scheduledTimes = data.scheduledTimes;
                var patientUID = data.patientUid;
            */
            if (this.validatePill() == '') {
                let pillMap = {};
                pillMap['pillName'] = this.name;
                pillMap['pillAmount'] = this.amount;
                pillMap['pillFrequency'] = this.freq;
                pillMap['type'] = this.ingestType;
                let timingArray = [];
                for (let timeDate of this.timingsList) {
                    timingArray.push(timeDate.getTime());
                }
                pillMap['scheduledTimes'] = timingArray;
                pillMap['patientUid'] = this.patientData['users_id'];
                this.schedulePillForPatient(pillMap);
            } else {
                this.customDialogVisible = true;
                this.customDialogTitle = 'Unable to schedule pill';
                this.customDialogText = this.validatePill();
                this.customDialogConfirmed = () => {
                    this.resetCustomDialog();
                };
            }
        },
        async fetchScheduleData() {
            const scheduleData = httpsCallable(functions, 'fetchPatientSchedule');
            await scheduleData({ 'patientUid': this.patientData['users_id'] })
                .then((result) => {
                    const data = result.data;
                    if (data['code'] == 200) {
                        state.patients[this.patientData['email']]['schedule'] = data['data'];
                    }
                });
        },
        async schedulePillForPatient(pillData) {
            this.customDialogTitle = 'Scheduleing Pill!';
            this.customDialogText = 'Please wait while pill is scheduled!';
            this.customDialogVisible = true;
            const schedulePatientPill = httpsCallable(functions, 'schedulePatientPill');
            schedulePatientPill(pillData)
                .then(async (result) => {
                    const data = result.data;
                    if (data['code'] != 200) {
                        this.customDialogTitle = 'Unable to schedule pill';
                        this.customDialogText = data['message'];
                        this.customDialogConfirmed = () => {
                            this.resetCustomDialog();
                        };
                        this.customDialogVisible = true;
                    } else {
                        await this.fetchScheduleData();
                        this.customDialogTitle = 'Pill Scheduled!';
                        this.customDialogText = 'Pill has been scheduled!';
                        this.customDialogConfirmed = () => {
                            this.$router.back();
                            this.resetCustomDialog();
                        }
                        this.customDialogVisible = true;
                    }
                });
        },
        resetCustomDialog() {
            this.customDialogVisible = false;
            this.customDialogText = '';
            this.customDialogConfirmed = null;
            this.customDialogTitle = '';
        }
    }

}
</script>

<style scoped>
main {
    color: black;
    min-height: 95vh;
    width: 100%;
}

.patient_details {
    padding-left: 20px;
    padding-right: 20px;
    display: flex;
}

.details {
    width: 50%;
    padding: 10px 0px 10px 10px;
}

#schedule_timings {
    margin: 0px 25px 0px 25px;
}

.timing-item {
    border: 2px solid black;
    display: flex;
}

.timing-detail {
    font-size: 1.5em;
    width: 80%;
    align-self: center;
}

.icon {
    font-size: 1.7em;
    align-self: center;
    background-color: rgba(19, 219, 105, 1);
    padding: 10px;
    margin-right: 1%;
    width: 8%;
}

#schedule-pill-btn {
    width: 100%;
    padding: 10px;
    margin-top: 10px;
    font-size: 1.2em;
}

.ingest-type-input {
    display: flex;
}

.ingest-type-item {
    width: 40%;
    border: 1px solid black;
    margin: 0px 5%;
    border-radius: 10px;
    text-align: center;
}
</style>

<template>
    <main v-if="patientData != null">
        <section class="patient_details">
            <TextDetails class="details" label="Patient's Name" :modelValue="patientData['name']" />
            <TextDetails class="details" label="Contact" :modelValue="patientData['contact_details']" />
        </section>
        <section id="schedule_timings">
            <TextDetails label="Name" :modelValue="name" width="100%" />
            <TextFormField label="Amount" v-model="amount" hint="Amount per intake" type="number" inputLength="2"
                width="100%" min="1" max="10" onKeyDown="return false" />
            <TextFormField label="Frequency" v-model="freq" hint="Frequency per day" type="number" inputLength="2"
                width="100%" min="1" max="10" onKeyDown="return false" />
            <div class="ingest-type-input">
                <div class="ingest-type-item" @click="ingestType = 0"
                    v-bind:style="ingestType == 0 ? { 'background-color': 'rgba(19, 219, 105, 1)' } : { 'background-color': 'white' }">
                    <p>After Meal</p>
                </div>
                <div class="ingest-type-item" @click="ingestType = 1"
                    v-bind:style="ingestType == 1 ? { 'background-color': 'rgba(19, 219, 105, 1)' } : { 'background-color': 'white' }">
                    <p>Before Meal</p>
                </div>
            </div>
            <h1>Scheduled Timings</h1>
            <div v-for="timing, index in timingsList">
                <div class="timing-item">
                    <div class="timing-detail" @click="toggleDialog(index)">
                        <p>{{ displayTiming(timing) }}</p>
                    </div>
                    <font-awesome-icon class="icon" icon="fa-solid fa-plus" @click="incrementTimings"></font-awesome-icon>
                    <font-awesome-icon v-if="timingsList.length > 1" class="icon" @click="decrementTimings(index)"
                        icon="fa-solid fa-minus"></font-awesome-icon>
                </div>
            </div>
            <button id="schedule-pill-btn" @click="schedulePill">Schedule Pill</button>
        </section>
        <DialogTimePicker title="Update Schedule Timing" :hour="selectedHour" :min="selectedMinute" :visible="dialogVisible"
            @update:visible="dialogVisible = $event" @confirmed="storeSelectedTime" />
        <CustomDialog :title="customDialogTitle" :message="customDialogText" :visible="customDialogVisible"
            @update:visible="customDialogConfirmed" />
    </main>
</template>
