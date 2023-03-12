import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class InformationController extends GetxController {
  final RxMap<String, dynamic> pillsList = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> searchList = <String, dynamic>{}.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Box? infoBox;

  @override
  void onReady() async {
    infoBox = await Hive.openBox('information');
    await loadData();
  }

  void searchTerm(String searchTerm) {
    searchList.clear();
    searchList.value = Map<String, dynamic>.from(pillsList.value);
    searchList.removeWhere((key, value) {
      return !key.toLowerCase().contains(searchTerm.toLowerCase());
    });
  }

  Future<void> downloadPillData() async {
    final DocumentReference docRef =
        _firestore.collection('information').doc('pills');
    final DocumentSnapshot docs = await docRef.get();
    if (docs.exists) {
      infoBox?.put("info", docs.data());
      await loadData();
    }
  }

  Future<void> loadData() async {
    var data = infoBox?.get("info") ?? {};
    try {
      Map<String, dynamic> pillData = Map<String, dynamic>.from(data);
      if (pillData.isEmpty) {
        await downloadPillData();
      }
      data = infoBox?.get("info") ?? {};
      pillData = Map<String, dynamic>.from(data);
      pillsList.value = pillData;
    } catch (e) {
      return;
    }
  }
}
