import 'package:pill_dispenser/models/pill.dart';

class Schedule {
  Schedule({List<DateTime>? scheduledTimes, this.pill}) {
    this.scheduledTimes.addAll(scheduledTimes ?? []);
  }
  List<DateTime> scheduledTimes = [];
  Pill? pill;

  Schedule.fromJson(Map<String, dynamic> json) {
    scheduledTimes =
        List<DateTime>.from((json['scheduledTimes'] ?? []).map((msEpoch) {
      return DateTime.fromMillisecondsSinceEpoch(msEpoch);
    }));
    pill = Pill.fromJson(json);
  }

  Map<String, dynamic> toMap() {
    return {
      'scheduledTimes': scheduledTimes.map<int>((e) {
        return e.millisecondsSinceEpoch;
      }).toList(),
    }..addAll(pill?.toMap() ?? {});
  }

  void upToDate(DateTime now) {
    scheduledTimes = scheduledTimes.map((e) {
      DateTime newDateTime;
      if (now.isAfter(e)) {
        newDateTime =
            DateTime(now.year, now.month, now.day + 1, e.hour, e.minute);
      } else {
        newDateTime = DateTime(now.year, now.month, now.day, e.hour, e.minute);
      }

      return newDateTime;
    }).toList();
  }
}
