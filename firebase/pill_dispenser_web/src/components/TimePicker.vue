<template>
    <div class="time-picker">
        <label>Hour:</label>
        <select v-model="selectedHour">
            <option v-for="hour in hours" :value="hour">{{ hour }}</option>
        </select>
        <label>Minute:</label>
        <select v-model="selectedMinute">
            <option v-for="minute in minutes" :value="minute">{{ minute }}</option>
        </select>
    </div>
</template>

<style scoped>
select,
label {
    padding: 10px;
}

.time-picker {
    display: inline-flex;
    border: 1px solid black;
    border-radius: 10px;
    background-color: rgba(249, 82, 82, 0.384);
}
</style>
  
<script>
export default {
    data() {
        return {
            selectedHour: null,
            selectedMinute: null,
        }
    },
    beforeMount() {
        this.selectedHour = this.currHour;
        this.selectedMinute = this.currMinute;
    },
    props: {
        currHour: String,
        currMinute: String
    },
    computed: {
        hours() {
            const hours = []
            for (let i = 0; i < 24; i++) {
                hours.push(i.toString().padStart(2, '0'))
            }
            return hours
        },
        minutes() {
            const minutes = []
            for (let i = 0; i < 31; i += 30) {
                minutes.push(i.toString().padStart(2, '0'))
            }
            return minutes
        }
    },
    watch: {
        selectedHour() {
            this.updateTime()
        },
        selectedMinute() {
            this.updateTime()
        }
    },
    methods: {
        updateTime() {
            const time = `${this.selectedHour}:${this.selectedMinute}`
            let selectedTime = new Date;
            selectedTime.setMinutes(parseInt(this.selectedMinute));
            selectedTime.setHours(parseInt(this.selectedHour));
            selectedTime.setSeconds(0);
            this.$emit('on-update', selectedTime)
        }
    }
}
</script>
  