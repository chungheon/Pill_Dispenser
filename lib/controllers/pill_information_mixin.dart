import 'package:get/get.dart';

class PillInformationMixin {
  final RxMap<String, dynamic> pillsList = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> searchList = <String, dynamic>{}.obs;

  void searchTerm(String searchTerm) {
    searchList.clear();
    searchList.value = Map<String, dynamic>.from(pillsList.value);
    searchList.removeWhere((key, value) {
      return !key.toLowerCase().contains(searchTerm.toLowerCase());
    });
  }

  void setPillData(Map<String, dynamic> pillsInfo) async {
    pillsList.value = pillsInfo;
  }
}
