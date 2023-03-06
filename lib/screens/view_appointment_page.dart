import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pill_dispenser/constants.dart';
import 'package:pill_dispenser/controllers/schedule_controller.dart';
import 'package:pill_dispenser/controllers/user_state_controller.dart';
import 'package:pill_dispenser/widgets/standard_app_bar.dart';
import 'package:pill_dispenser/widgets/standard_scaffold.dart';

class ViewAppointmentPage extends StatelessWidget {
  ViewAppointmentPage({Key? key}) : super(key: key);
  final ScheduleController _scheduleController = Get.find<ScheduleController>();
  final UserStateController _userStateController =
      Get.find<UserStateController>();
  final RxList<Appointment> appointments = RxList<Appointment>();

  Future<void> fetchAppointmentData() async {
    var apptList = await _scheduleController.fetchAppointmentsOnline(
        _userStateController.user.value?.uid ?? 'ERROR');
    apptList.sort(((a, b) {
      if (a.apptDateTime == null || b.apptDateTime == null) {
        return -1;
      }
      if (a.apptDateTime!.isBefore(b.apptDateTime!)) {
        return -1;
      } else {
        return 1;
      }
    }));
    appointments.value = apptList;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(((timeStamp) {
      fetchAppointmentData();
    }));
    return StandardScaffold(
        appBar: const StandardAppBar().appBar(),
        child: Obx(() {
          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: ((context, index) {
              String dateStr = _scheduleController.formatDateToStr(
                  appointments[index].apptDateTime ??
                      DateTime.fromMillisecondsSinceEpoch(0),
                  showDay: true);
              String timeStr = _scheduleController.formatDateToStrTime(
                  appointments[index].apptDateTime ??
                      DateTime.fromMillisecondsSinceEpoch(0));
              return Container(
                decoration: BoxDecoration(
                  color: Constants.white,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Constants.black.withOpacity(0.2),
                      blurRadius: 10.0,
                    )
                  ],
                ),
                margin: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointments[index].name ?? "ERROR",
                      style: const TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      'Date: $dateStr',
                      style: const TextStyle(fontSize: 18.0),
                    ),
                    Text(
                      'Time: $timeStr',
                      style: const TextStyle(fontSize: 18.0),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      'Message: ${appointments[index].message}',
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ],
                ),
              );
            }),
          );
        }));
  }
}

class Appointment {
  Appointment({this.name, this.apptDateTime, this.message});
  String? name;
  String? message;
  DateTime? apptDateTime;

  Appointment.fromJson(Map<String, dynamic> data) {
    name = data['name'];
    apptDateTime =
        DateTime.fromMillisecondsSinceEpoch(data['apptDateTime'] ?? 0);
    message = data['message'];
  }

  Appointment.fromSchedule(this.name, DateTime apptDate, DateTime apptTime,
      {this.message}) {
    apptDateTime = DateTime(apptDate.year, apptDate.month, apptDate.day,
        apptTime.hour, apptTime.minute);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'apptDateTime': apptDateTime?.millisecondsSinceEpoch ?? 0,
      'message': message,
    };
  }
}
