import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:pill_dispenser/main.dart';
import 'package:pill_dispenser/models/schedule.dart';
import 'package:timezone/timezone.dart' as tz;

class ScheduleController extends GetxController {
  int id = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool permission = false;
  Box? scheduleBox;
  Box? pillBox;

  @override
  void onInit() async {
    super.onInit();
  }

  Future<List<PendingNotificationRequest>> getAllPendingNotifications() {
    return flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> updatePillStatus(DateTime scheduledTime, DateTime now,
      String pillName, String userId) async {
    if (pillBox == null || formatDateToStr(now) != pillBox!.name) {
      pillBox = await Hive.openBox(formatDateToStr(now) + userId);
    }
    var existData = pillBox?.get(pillName, defaultValue: []);
    existData.add(
        {scheduledTime.millisecondsSinceEpoch: now.millisecondsSinceEpoch});
    pillBox?.put(pillName, existData);
  }

  tz.TZDateTime _getTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<bool> hasPermission() async {
    if (Platform.isIOS) {
      permission = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          false;
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      permission = await androidImplementation?.requestPermission() ?? false;
    }

    return permission;
  }

  String formatDateToStr(DateTime date) {
    String formattedDate = DateFormat('dd-MM-yyyy').format(date);
    return formattedDate;
  }

  Future<void> setBox(String userId) async {
    scheduleBox = await Hive.openBox(userId);
    // print(formatDateToStr(DateTime.now()));
    pillBox = await Hive.openBox(formatDateToStr(DateTime.now()) + userId);
  }

  Future<Map<dynamic, dynamic>> getCurrDayData(String userId) async {
    DateTime now = DateTime.now();
    if (pillBox == null || pillBox!.name != (formatDateToStr(now) + userId)) {
      pillBox = await Hive.openBox(formatDateToStr(now) + userId);
    }
    return pillBox?.toMap() ?? {};
  }

  Future<void> fetchOnlineData(String userId) async {
    DocumentReference ref = _firestore.collection("user_schedule").doc(userId);
    DocumentSnapshot doc = await ref.get();
    updateNotifications((doc.data() ?? {}) as Map);
  }

  Future<void> updateNotifications(Map data) async {
    hasPermission();
    await cancelAllNotifications();
    List<Schedule> formatted =
        formatToScheduleList(Map<dynamic, dynamic>.from(data));
    await scheduleBox?.clear();
    // print(formatted.length);
    for (Schedule sch in formatted) {
      scheduleBox?.put((sch.pill?.pill ?? "ERROR").trim(), sch.toMap());
      DateTime now = DateTime.now();
      sch.upToDate(now);
      await scheduleTimings(sch);
      // print(sch.scheduledTimes.length);
    }
    var notifications = await getAllPendingNotifications();
    for (var notification in notifications) {
      print("${notification.title} ${notification.body} ${notification.id}");
    }
  }

  List<Schedule> formatToScheduleList(Map<dynamic, dynamic> data) {
    List<Schedule> schedules = [];
    data.forEach((key, value) {
      Schedule schedule = Schedule.fromJson(Map<String, dynamic>.from(value));
      schedules.add(schedule);
    });

    return schedules;
  }

  Map<dynamic, dynamic> fetchOfflineData() {
    return scheduleBox?.toMap() ?? {};
  }

  Future<void> storeScheduleData(Schedule schedule, String userId) async {
    if (userId.isNotEmpty) {
      DocumentReference ref =
          _firestore.collection("user_schedule").doc(userId);
      ref.set({(schedule.pill?.pill ?? "ERROR").trim(): schedule.toMap()},
          SetOptions(merge: true));
      scheduleBox?.put(
          (schedule.pill?.pill ?? "ERROR").trim(), schedule.toMap());
    }
  }

  bool checkIfExists(String pillName) {
    if (pillName.isNotEmpty) {
      return scheduleBox?.get(pillName.trim()) == null;
    }
    return true;
  }

  Future<void> updateSchedule(Schedule schedule, String userId) async {
    await storeScheduleData(schedule, userId);
    await updateNotifications(fetchOfflineData());
  }

  Future<void> scheduleTimings(Schedule schedule) async {
    int id =
        (await flutterLocalNotificationsPlugin.pendingNotificationRequests())
            .length;
    for (var scheduledTime in schedule.scheduledTimes) {
      // print(_getTime(scheduledTime.hour, scheduledTime.minute).toString());hh
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id++,
        "${schedule.pill?.pill} ${(schedule.pill?.ingestType?.index ?? 0) == 0 ? 'after meal' : 'before meal'} ",
        // ignore: prefer_interpolation_to_compose_strings
        "Please take ${schedule.pill?.amount} number of pills." +
            "\n${schedule.pill?.frequency} a day",
        _getTime(scheduledTime.hour, scheduledTime.minute),
        const NotificationDetails(
            android: AndroidNotificationDetails('daily notification channel id',
                'daily notification channel name',
                // sound: RawResourceAndroidNotificationSound('notification'),
                channelDescription: 'daily notification description'),
            iOS: DarwinNotificationDetails(
                // sound: 'alarm.wav',
                categoryIdentifier: 'id_3',
                interruptionLevel: InterruptionLevel.active)),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        androidAllowWhileIdle: true,
      );
    }
  }

  Future<void> logOut() async {
    await cancelAllNotifications();
    await scheduleBox?.clear();
    scheduleBox = null;
  }

  Future<List<Map<dynamic, dynamic>>> getUpcomingNotifications(
      String userId) async {
    DateTime now = DateTime.now();
    if (now.subtract(Duration(minutes: 5)).day == now.day) {
      now = now.subtract(Duration(minutes: 5));
    }
    var completed = await getCurrDayData(userId);
    var schedules = formatToScheduleList(fetchOfflineData());
    List<Map<dynamic, dynamic>> data = [];
    for (Schedule schedule in schedules) {
      var completedTimings = completed[schedule.pill?.pill ?? ''] ?? [];
      // print(completedTimings);
      for (DateTime dt in schedule.scheduledTimes) {
        bool isCompleted = completedTimings.where(
          (element) {
            return element.keys.first == dt.millisecondsSinceEpoch;
          },
        ).isNotEmpty;
        if (compareTime(now, dt) <= 0) {
          data.add({
            'time': dt,
            'schedule': schedule,
            'completed': isCompleted,
          });
        }
      }
    }
    data.sort((a, b) {
      return compareTime(a['time'] as DateTime, b['time'] as DateTime);
    });

    return data;
  }

  int compareTime(DateTime a, DateTime b) {
    if (a.hour > b.hour) {
      return 1;
    } else if (a.hour < b.hour) {
      return -1;
    } else {
      if (a.minute > b.minute) {
        return 1;
      } else if (a.minute == b.minute) {
        return 0;
      } else {
        return -1;
      }
    }
  }

  Future<List<int>> getCompletedAmount(
      DateTime startDate, DateTime endDate, String userId) async {
    Duration diffDays = startDate.difference(endDate);
    DateTime date = startDate;
    List<int> completed = [];
    for (int i = 0; i < diffDays.inDays * -1; i++) {
      date = date.add(const Duration(days: 1));
      Box boxData = await Hive.openBox(formatDateToStr(date) + userId);
      Map dayData = boxData.toMap();
      int totalCompleted = 0;
      dayData.forEach((key, value) {
        if (value.runtimeType == List) {
          totalCompleted += (value as List).length;
        }
      });
      completed.add(totalCompleted);
    }
    return completed;
  }
}
