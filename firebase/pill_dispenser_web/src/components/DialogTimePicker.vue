<template>
    <div class="dialog" v-if="visible">
        <div class="dialog-overlay" @click="close"></div>
        <div class="dialog-content">
            <h2>{{ title }}</h2>
            <TimePicker :currHour="hour" :currMinute="min" @on-update="setSelectedTime" />
            <div class="dialog-buttons">
                <button @click="confirm">Select</button>
                <button @click="close">Cancel</button>
            </div>
        </div>
    </div>
</template>
  
<script>
import TimePicker from '../components/TimePicker.vue';

export default {
    props: {
        title: String,
        hour: String,
        min: String,
        visible: Boolean,
        
    },
    data(){
        return {
            selectedTime : null,
        }
    },
    components: {
        TimePicker,
    },
    methods: {
        close() {
            this.$emit('update:visible', false)
        },
        confirm() {
            this.$emit('confirmed', this.selectedTime)
            this.close()
        },
        setSelectedTime(time){
            this.selectedTime = time;
        },
        
    }
}
</script>
  
<style>
.dialog {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 9999;
}

.dialog-overlay {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
}

.dialog-content {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    background-color: white;
    padding: 20px;
    border-radius: 5px;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.3);
}

.dialog-buttons {
    text-align: right;
    margin-top: 20px;
}

.dialog-buttons button {
    margin-left: 10px;
}
</style>
  