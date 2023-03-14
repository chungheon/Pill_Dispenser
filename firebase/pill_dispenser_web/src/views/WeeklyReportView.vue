Copy code
<template>
    <div>
        <apexchart type="line" :options="chartOptions" :series="chartSeries"></apexchart>
    </div>
</template>

<script>
export default {
    data() {
        return {
            chartOptions: {
                chart: {
                    id: 'mychart'
                },
                xaxis: {
                    categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul']
                }
            },
            chartSeries: [{
                name: 'My Data',
                data: [30, 40, 35, 50, 49, 60, 70]
            }]
        }
    }
}
</script>