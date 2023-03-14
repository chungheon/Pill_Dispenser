import 'package:cloud_functions/cloud_functions.dart';

class PatientInfoMixin {
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-east2');

  Future<Map<String, dynamic>> fetchPatientsPillInformation(
      Map<String, dynamic> patientDetails) async {
    HttpsCallable callable =
        _functions.httpsCallable('fetchPatientPillInformation');
    final result = await callable.call({
      'patientUid': patientDetails['users_id'],
    });
    final data = result.data;
    if (data['code'] == 200) {
      return Map<String, dynamic>.from(data['data'] ?? {});
    }
    return {};
  }

  Future<Map<String, dynamic>> fetchPatientWeeklyReport(
      Map<String, dynamic> patientDetails) async {
    HttpsCallable callable = _functions.httpsCallable('fetchReportData');
    final result = await callable.call({
      'patientEmail': patientDetails['email'],
      'patientUid': patientDetails['users_id'],
    });
    final data = result.data;
    if (data['code'] == 200) {
      return Map<String, dynamic>.from(data['data'] ?? {});
    }
    return {};
  }

  Future<Map<String, dynamic>> fetchPatientScheduleData(
      Map<String, dynamic> patientDetails) async {
    HttpsCallable callable = _functions.httpsCallable('fetchPatientSchedule');
    final result = await callable.call({
      'patientEmail': patientDetails['email'],
      'patientUid': patientDetails['users_id'],
    });
    final data = result.data;
    if (data['code'] == 200) {
      return Map<String, dynamic>.from(data['data'] ?? {});
    }
    return {};
  }
}
