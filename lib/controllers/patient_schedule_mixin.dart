import 'package:cloud_functions/cloud_functions.dart';

class PatientSchedulerMixin {
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-east2');

  /*
    var pillName = data.pillName;
    var pillAmount = data.pillAmount;
    var pillFrequency = data.pillFrequency;
    var type = data.type;
    var scheduledTimes = data.scheduledTimes;
    var patientUID = data.patientUid;
  */
  Future<bool> schedulePillForPatient(
      String pillName,
      int pillAmount,
      int pillFrequency,
      int type,
      List<int> scheduledTimes,
      String patientEmail,
      String patientUID) async {
    HttpsCallable callable = _functions.httpsCallable('schedulePatientPill');
    final result = (await callable.call(<String, dynamic>{
      'pillName': pillName,
      'pillAmount': pillAmount,
      'pillFrequency': pillFrequency,
      'type': type,
      'scheduledTimes': scheduledTimes,
      'patientEmail': patientEmail,
      'patientUid': patientUID,
    }));
    final data = Map<String, dynamic>.from(result.data);
    if ((data['code'] ?? 400) == 200) {
      return true;
    }
    return false;
  }
}
