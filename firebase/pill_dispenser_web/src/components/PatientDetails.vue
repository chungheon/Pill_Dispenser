<script setup>
import { RouterLink } from 'vue-router';
import TextDetails from './TextDetailsField.vue';
</script>

<script>
export default {
    props: ["patientData"],
    components: { RouterLink }
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
    width: 100%;
}

a:hover {
    background-color: #474EDD;
    top: 4px;
    box-shadow: 0 0 0 1px #163772 inset, 0 0 0 2px rgba(255, 255, 255, 0.15) inset, 0 0 0 0 #333797, 0 0 0 1px rgba(0, 0, 0, 0.4), 0 0px 8px 1px rgba(0, 0, 0, 0.5);
}
</style>

<template>
    <section class="patient_section">
        <div class="patient_details">
            <TextDetails class="details" label="Name" :modelValue="patientData['name']" />
            <TextDetails label="Email" :modelValue="patientData['email']" />
            <TextDetails label="Contact" :modelValue="patientData['contact_details']" />
        </div>
        <div class="options">
            <div class="option">
                <RouterLink :to="{ name: 'pillschedule', params: { patientEmail: patientData['email'] } }">Add Patient's Pill
                </RouterLink>
            </div>
            <div class="option">
                <RouterLink to="/">View Weekly Report</RouterLink>
            </div>
            <div class="option">
                <RouterLink to="/">Add Pill Information</RouterLink>
            </div>

        </div>
    </section>
</template>
