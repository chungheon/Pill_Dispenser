import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class InformationController extends GetxController {
  final RxMap<String, dynamic> pillsList = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> searchList = <String, dynamic>{}.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void searchTerm(String searchTerm) {
    searchList.clear();
    searchList.value = Map<String, dynamic>.from(pillsList.value);
    searchList.removeWhere((key, value) {
      return !key.toLowerCase().contains(searchTerm.toLowerCase());
    });
  }

  Future<void> downloadPillData(String userID) async {
    final DocumentReference docRef =
        _firestore.collection('information').doc(userID);
    final DocumentSnapshot docs = await docRef.get();
    if (docs.exists) {
      pillsList.value = Map<String, dynamic>.from((docs.data() ?? {}) as Map);
    }
  }
}
