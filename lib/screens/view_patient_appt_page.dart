import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pill_dispenser/constants.dart';
import 'package:pill_dispenser/controllers/schedule_controller.dart';
import 'package:pill_dispenser/controllers/user_state_controller.dart';
import 'package:pill_dispenser/widgets/standard_app_bar.dart';
import 'package:pill_dispenser/widgets/standard_scaffold.dart';

import '../widgets/loading_dialog.dart';

class ViewPatientApptPage extends StatelessWidget {
  ViewPatientApptPage(this.patientData, {Key? key}) : super(key: key);
  final ScheduleController _scheduleController = Get.find<ScheduleController>();
  final UserStateController _userStateController =
      Get.find<UserStateController>();
  final Map<String, dynamic> patientData;

  @override
  Widget build(BuildContext context) {
    return StandardScaffold(
      appBar: const StandardAppBar().appBar(),
      child: ListView.builder(
        itemCount: Map<String, dynamic>.from(patientData['appts'] ?? {}).length,
        itemBuilder: ((context, index) {
          Map<String, dynamic> patientAppts =
              Map<String, dynamic>.from(patientData['appts'] ?? {});
          var key = patientAppts.keys.elementAt(index);
          var data = patientAppts[key];
          String dateStr = _scheduleController.formatDateToStr(
              DateTime.fromMillisecondsSinceEpoch(data['apptDateTime'] ??
                  DateTime.fromMillisecondsSinceEpoch(0)
                      .millisecondsSinceEpoch),
              showDay: true);
          String timeStr = _scheduleController.formatDateToStrTime(
            DateTime.fromMillisecondsSinceEpoch(data['apptDateTime'] ??
                DateTime.fromMillisecondsSinceEpoch(0).millisecondsSinceEpoch),
          );
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
            margin:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'] ?? "ERROR",
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
                        'Message: ${data["message"]}',
                        style: const TextStyle(fontSize: 18.0),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                    onTap: () async {
                      bool result = await LoadingDialog.showLoadingDialog(
                          _scheduleController.removePatientAppt(
                            key,
                            patientData['email'],
                            patientData['users_id'],
                          ),
                          context, () {
                        return ModalRoute.of(context)?.isCurrent != true;
                      });
                      if (result) {
                        _userStateController.fetchPatientData(
                            patientData['users_id'],
                            refreshAppt: true);
                        Get.back();
                      }
                    },
                    child: const Icon(Icons.delete, size: 40.0))
              ],
            ),
          );
        }),
      ),
    );
  }
}
