<script setup>
import { defineComponent } from 'vue';
import { Chart, registerables } from 'chart.js';
import { Line, mixins } from 'vue-chartjs';
</script>

<script>
Chart.register(...registerables);

export default defineComponent({
  extends: Line,
  mixins: [mixins.reactiveProp],
  props: ['chartData', 'options'],
  mounted() {
    this.renderChart(this.chartData, this.options);
  },
  beforeUnmount() {
    if (this._chart) {
      this._chart.destroy();
    }
  }
});
</script>