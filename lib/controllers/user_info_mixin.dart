import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserInfoMixin {
  final RxString displayName = RxString('');
  final RxString contactDetails = RxString('');
  final Rxn<DateTime> birthday = Rxn<DateTime>();
  final RxList<String> allergies = RxList<String>();
  final Rxn<User> user = Rxn<User>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-east2');
  final RxMap<String, dynamic> requests = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> guardian = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> patient = <Map<String, dynamic>>[].obs;
  static const GRD_PAT_PATH = 'guardian_patient_list';

  void clearUserData() {
    displayName.value = '';
    contactDetails.value = '';
    birthday.value = null;
    patient.clear();
    guardian.clear();
  }

  Future<bool> addAllergy(String allergyName) async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users_list').doc(user.email).set(
          {
            'allergies': {allergyName: 'true'},
          },
          SetOptions(merge: true),
        ).onError((error, stackTrace) => throw Exception(error));
      } catch (e) {
        return false;
      }
      return true;
    }

    return false;
  }

  Future<bool> updateDisplayName(String name) async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users_list').doc(user.email).set({
          'name': name,
        }, SetOptions(merge: true)).onError(
            (error, stackTrace) => throw Exception(error));
        displayName.value = name;
      } catch (e) {
        return false;
      }
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> fetchGrdRequests() async {
    HttpsCallable callable = _functions.httpsCallable('fetchReq');
    final result = (await callable.call()).data;
    if (result['code'] == 200) {
      return Map<String, dynamic>.from(result['data'] ?? {});
    }

    return Future.error(result['message'] ?? '');
  }

  Future<Map<String, dynamic>> fetchRelationships() async {
    HttpsCallable callable = _functions.httpsCallable('fetchRelationships');
    final result = await callable.call();
    final data = result.data;
    if (data['code'] == 200) {
      var res = <String, dynamic>{};
      res['guardians'] = Map<String, dynamic>.from(data['guardians'] ?? {});
      res['patients'] = Map<String, dynamic>.from(data['patients'] ?? {});

      return res;
    }

    return Future.error(data['message'] ?? '');
  }

  Future<void> updateRelationships() async {
    await fetchRelationships().then((relationships) {
      var guardians = relationships['guardians'];
      var patients = relationships['patients'];
      patient.clear();
      guardian.clear();
      for (var key in guardians.keys) {
        var data = guardians[key];
        guardian.add(Map<String, dynamic>.from(data));
      }

      for (var key in patients.keys) {
        var data = patients[key];
        if (data == 'pending') {
          patient.add({key: 'pending'});
        } else {
          patient.add(Map<String, dynamic>.from(data));
        }
      }
    });
  }

  Future<void> fetchUserDetailsOnline() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      var userRef = _firestore.collection('users_list').doc(user.email);
      var userDoc = await userRef.get();
      updateDetailsFromMap(userDoc.data() ?? {});
    }
  }

  Future<void> fetchUserDetails() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      await fetchUserDetailsOnline();
      fetchRelationships().then((relationships) {
        var guardians = relationships['guardians'];
        var patients = relationships['patients'];
        patient.clear();
        guardian.clear();
        for (var key in guardians.keys) {
          var data = guardians[key];
          guardian.add(Map<String, dynamic>.from(data));
        }

        for (var key in patients.keys) {
          var data = patients[key];
          if (data == 'pending') {
            patient.add({key: 'pending'});
          } else {
            patient.add(Map<String, dynamic>.from(data));
          }
        }
      });

      requests.clear();
      fetchGrdRequests().then((requests) {
        this.requests.addAll(requests);
      });
    }
  }

  void updateDetailsFromMap(Map<String, dynamic> userMap) {
    birthday.value = userMap['birthday'] == null
        ? userMap['birthday']
        : DateTime.fromMillisecondsSinceEpoch(userMap['birthday']);
    contactDetails.value = userMap['contact_details'] ?? '';
    displayName.value = userMap['name'] ?? '';
    var allergiesData = Map<String, dynamic>.from(userMap['allergies'] ?? {});
    allergies.clear();
    for (var key in allergiesData.keys) {
      if (allergiesData[key] == 'true') {
        allergies.add(key);
      }
    }
    allergies.refresh();
  }

  Future<bool> reqGuardian(String email) async {
    HttpsCallable callable = _functions.httpsCallable('reqGuardian');
    final result = (await callable.call(<String, dynamic>{
      'patientEmail': email,
      'grdEmail': user.value?.email ?? 'ERROR',
    }));
    final data = Map<String, dynamic>.from(result.data);
    if ((data['code'] ?? 400) == 200) {
      return true;
    }
    return false;
  }

  Future<bool> acceptGuardian(
      String grdEmail, String grdUid, bool accept) async {
    HttpsCallable callable = _functions.httpsCallable('acceptGuardian');
    final result = (await callable.call(<String, dynamic>{
      'grdUID': grdUid,
      'grdEmail': grdEmail,
      'response': accept,
    }));
    final data = Map<String, dynamic>.from(result.data);
    if ((data['code'] ?? 400) == 200) {
      return true;
    }
    return false;
  }

  Future<bool> removeGuardian(String grdEmail) async {
    return true;
  }

  Future<bool> updateUserDetails(
      String name, String contact, DateTime? bday) async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users_list').doc(user.email).set({
          'contact_details': contact,
          'birthday': bday?.millisecondsSinceEpoch,
          'name': name,
        }, SetOptions(merge: true)).onError(
            (error, stackTrace) => throw Exception(error));
      } catch (e) {
        return false;
      }

      displayName.value = name;
      contactDetails.value = contact;
      birthday.value = bday;
      return true;
    }
    return false;
  }
}
