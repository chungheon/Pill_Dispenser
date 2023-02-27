import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pill_dispenser/constants.dart';
import 'package:pill_dispenser/controllers/schedule_controller.dart';
import 'package:pill_dispenser/controllers/user_state_controller.dart';
import 'package:pill_dispenser/widgets/standard_app_bar.dart';
import 'package:pill_dispenser/widgets/standard_scaffold.dart';

class WeeklyReportPage extends StatelessWidget {
  WeeklyReportPage({Key? key}) : super(key: key);

  final ScheduleController _scheduleController = Get.find<ScheduleController>();
  final UserStateController _userStateController =
      Get.find<UserStateController>();
  final RxList<int> completedValues = <int>[].obs;
  final RxInt highestValue = 0.obs;
  final RxInt totalNotifications = 0.obs;

  LineTouchData get lineTouchData1 => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        ),
      );
  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    String text = _scheduleController
        .formatDateToStr(
            DateTime.now().subtract(Duration(days: 7 - value.toInt())))
        .substring(0, 5);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: Text(value == 0 ? '' : text, style: style),
    );
  }

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: Border(
          bottom:
              BorderSide(color: Constants.primary.withOpacity(0.2), width: 4),
          left: const BorderSide(color: Constants.primary),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      );

  FlTitlesData get titlesData1 => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles(),
        ),
      );

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    int split = (highestValue.value / 25).toInt();
    String text = "0";
    switch (split) {
      case 0:
        text = value.toInt().toString();
        break;
      case 1:
        text = (value.toInt() % 2 == 0 ? value.toInt() : '').toString();
        break;
      default:
        text = (value.toInt() % split == 0 ? value.toInt() : '').toString();
        break;
    }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  SideTitles leftTitles() => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        interval: 1,
        reservedSize: 40,
      );

  LineChartBarData getData(List<int> values) {
    return LineChartBarData(
      isCurved: false,
      color: Constants.black,
      barWidth: 8,
      isStrokeCapRound: true,
      dotData: FlDotData(show: true),
      belowBarData: BarAreaData(show: false),
      spots: [
        for (int i = 0; i < values.length; i++)
          FlSpot(i + 1, values[i].toDouble())
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(((timeStamp) async {
      DateTime now = DateTime.now();
      List<int> completed = await _scheduleController.getCompletedAmount(
          now.subtract(const Duration(days: 7)),
          now,
          _userStateController.user.value?.uid ?? "ERROR");
      var scheduleData = _scheduleController.fetchOfflineData();
      int total = 0;
      scheduleData.forEach((key, value) {
        var timings = value['scheduledTimes'];
        if (timings.runtimeType == List<int>) {
          total += (timings as List).length;
        }
      });
      completedValues.value = completed;
      highestValue.value = completed.reduce(max) + 1;
      totalNotifications.value = total;

      // labelX.clear();
      // for (int i = 6; i >= 0; i--) {
      //   labelX.add(_scheduleController
      //       .formatDateToStr(now.subtract(Duration(days: i)))
      //       .substring(0, 5));
      // }
      // labelY.value = [for (var i = 0; i <= completed.last; i++) i.toString()];
      // features.clear();
      // features.add(Feature(
      //   title: "Completed",
      //   color: Constants.primary,
      //   data: completed.map((e) => e.toDouble()).toList(),
      // ));
    }));
    return StandardScaffold(
        appBar: const StandardAppBar().appBar(),
        child: Column(
          children: [
            const SizedBox(
              height: 20.0,
            ),
            const Center(
              child: Text('Last 7 Days Completion',
                  style:
                      TextStyle(fontSize: 25.0, fontWeight: FontWeight.w500)),
            ),
            Column(
              children: [
                Obx(
                  () {
                    return Container(
                      width: Get.width,
                      height: Get.width * 1.5,
                      padding: const EdgeInsets.only(right: 15.0, top: 15.0),
                      child: LineChart(
                        getLineChartData(completedValues.value),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 15.0,
                ),
                Center(
                  child: Obx(
                    () => Text(
                        'Total Notifications: ${totalNotifications.value.toString()}',
                        style: const TextStyle(
                            fontSize: 25.0, fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            )
          ],
        ));
  }

  LineChartData getLineChartData(List<int> values) {
    return LineChartData(
      lineTouchData: lineTouchData1,
      gridData: FlGridData(show: false),
      titlesData: titlesData1,
      borderData: borderData,
      lineBarsData: [getData(values)],
      minX: 0,
      maxX: 7,
      maxY: (highestValue.value).toDouble(),
      minY: 0,
    );
  }
}
