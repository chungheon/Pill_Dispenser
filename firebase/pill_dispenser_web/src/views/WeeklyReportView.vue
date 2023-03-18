\<style scoped>
.report {
    min-width: 600px;
}

.report-chart {
    width: 60%;
    padding: 10px 20px;
}

.pill-name {
    font-size: 20px;
    font-weight: 500;
}

.patient_details {
    padding: 0px 20px;
    display: flex;
}

.details {
    width: 50%;
    padding: 10px 0px 10px 10px;
}
</style>

<template>
    <section class="patient_details">
        <TextDetails class="details" label="Patient's Name" :modelValue="patientData['name']" />
        <TextDetails class="details" label="Contact" :modelValue="patientData['contact_details']" />
    </section>
    <section>
        <div class="report" v-for="series, index in reportSeries">
            <div class="report-chart">
                <p class="pill-name">Pill Name: {{ pillNames[index] }}</p>
                <apexchart type="line" :options="reportOptions[index]" :series="series"></apexchart>
            </div>
        </div>
    </section>
</template>


<script>
import TextDetails from '../components/TextDetailsField.vue';
import {state} from '../GlobalState';

export default {
    data() {
        return {
            reportSeries: [],
            reportOptions: [],
            pillNames: [],
            patientEmail: null,
            patientData: {},
        }
    },
    components:{
        TextDetails
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
        var currDate = new Date;
        var dateKeys = this.getArrayOfDateKeys(currDate, 7, this.patientData['users_id']);
        this.pillNames = Object.keys(this.patientData['schedule']);
        var reportMap = this.getPillsStatistics(this.pillNames, dateKeys, this.patientData['report']);
        var dateNames = this.getDateNames(currDate, 7);
        for (var pill of this.pillNames) {
            var series = [{
                name: pill,
                data: reportMap[pill],
            }];
            var option = {
                chart: {
                    id: pill,
                },
                xaxis: {
                    categories: dateNames,
                    labels: {
                        style: {
                            fontSize: '15px', // reduce font size to 12 pixels
                        }, rotate: -80
                    }
                },
            };
            this.reportSeries.push(series);
            this.reportOptions.push(option);
        }
    },
    methods: {
        async fetchScheduleData() {
            const reportData = httpsCallable(functions, 'fetchReportData');
            await reportData({ 'patientUid': this.patientDatapatientData['users_id'] })
                .then((result) => {
                    const data = result.data;
                    state.patients[this.patientEmail]['schedule'] = data['data'];
                });
        },
        getPillsStatistics(pills, dateKeys, reportData) {
            var reportMap = {};
            for (let pill of pills) {
                reportMap[pill] = [];
            }
            for (var dateKey of dateKeys) {
                var dateReport = reportData[dateKey];
                if (dateReport != null) {
                    for (let pill of pills) {
                        if (dateReport[pill] != null) {
                            reportMap[pill].push(dateReport[pill].split(',').length);
                        } else {
                            reportMap[pill].push(0);
                        }
                    }
                } else {
                    for (let pill of pills) {
                        reportMap[pill].push(0);
                    }
                }

            }
            return reportMap;
        },
        getArrayOfDateKeys(date, numOfDays = 7, patientUID) {
            var dateKeysArray = [];
            var dateData = new Date;
            dateData.setHours(0);
            dateData.setMinutes(0);
            dateData.setFullYear(date.getFullYear());
            dateData.setMonth(date.getMonth());
            dateData.setDate(date.getDate());
            for (var i = 0; i < numOfDays; i++) {
                var dateStr = this.getDateFormatStr(dateData);
                var reportKey = dateStr + patientUID;
                dateKeysArray.push(reportKey);
                dateData.setDate(dateData.getDate() - 1);
            }
            return dateKeysArray.reverse();
        }, getDateNames(date, numOfDays = 7) {
            var dateNames = [];
            var dateData = new Date;
            dateData.setHours(0);
            dateData.setMinutes(0);
            dateData.setFullYear(date.getFullYear());
            dateData.setMonth(date.getMonth());
            dateData.setDate(date.getDate());
            for (var i = 0; i < numOfDays; i++) {
                var dateStr = this.getDateFormatStr(dateData, false, true);
                dateNames.push(dateStr);
                dateData.setDate(dateData.getDate() - 1);
            }
            return dateNames.reverse();
        },
        getDateFormatStr(date, showYear = true, showMonth = false) {
            var month = date.getMonth() + 1;
            if (showMonth) {
                var months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEPT', 'OCT', 'NOV', 'DEC'];
                month = months[month - 1];
            }
            return (date.getDate() + "").padStart(2, 0) + "-" + (month + "").padStart(2, 0) + (showYear ? "-" + date.getFullYear() : "");
        }
    }
}
</script>