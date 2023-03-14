import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pill_dispenser/constants.dart';
import 'package:pill_dispenser/controllers/information_controller.dart';
import 'package:pill_dispenser/controllers/user_state_controller.dart';
import 'package:pill_dispenser/main.dart';
import 'package:pill_dispenser/screens/login_home_page.dart';
import 'package:pill_dispenser/widgets/custom_input_text_box_widget.dart';
import 'package:pill_dispenser/widgets/standard_app_bar.dart';
import 'package:pill_dispenser/widgets/standard_scaffold.dart';

class PillsInformationPage extends StatelessWidget {
  PillsInformationPage({Key? key}) : super(key: key) {
    onTapRefresh();
  }
  final InformationController _informationController =
      Get.find<InformationController>();
  final UserStateController _userStateController =
      Get.find<UserStateController>();
  final isLoading = false.obs;
  final RxString searchTerm = ''.obs;

  Future<void> onTapRefresh() async {
    if (!isLoading.value) {
      isLoading.value = true;
      await _informationController
          .downloadPillData(_userStateController.user.value?.uid ?? '');
      isLoading.value = false;
    }
  }

  Widget _refreshIcon() {
    return GestureDetector(
      onTap: onTapRefresh,
      child: Container(
        height: 40.0,
        width: 40.0,
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        alignment: Alignment.center,
        child: const Icon(
          Icons.refresh,
          color: Constants.black,
          size: 35.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StandardScaffold(
      appBar: StandardAppBar(action: _refreshIcon()).appBar(),
      child: Column(
        children: [
          const SizedBox(height: 15.0),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            decoration: BoxDecoration(
                color: Constants.white,
                borderRadius: BorderRadius.circular(15.0)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search,
                  size: 24.0,
                  color: Constants.grey,
                ),
                Expanded(
                  child: CustomInputTextBox(
                    inputObs: searchTerm,
                    title: 'Search',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(
              () {
                if (isLoading.value) {
                  return Center(
                    child: Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                            color: Constants.white,
                            borderRadius: BorderRadius.circular(15.0)),
                        child: const CircularProgressIndicator(
                          color: Constants.black,
                        )),
                  );
                }
                if (searchTerm.isNotEmpty) {
                  _informationController.searchTerm(searchTerm.value);
                }
                return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 15.0),
                  decoration: BoxDecoration(
                      color: Constants.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                            color: Constants.black.withOpacity(0.2),
                            blurRadius: 10.0)
                      ]),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'Information on Pills',
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: const ScrollBehavior()
                              .copyWith(overscroll: false),
                          child: Obx(
                            () => ListView.builder(
                              itemCount: searchTerm.isNotEmpty
                                  ? _informationController
                                      .searchList.value.length
                                  : _informationController
                                      .pillsList.value.length,
                              itemBuilder: (context, index) {
                                String pillKey = searchTerm.isNotEmpty
                                    ? _informationController
                                        .searchList.value.keys
                                        .elementAt(index)
                                    : _informationController
                                        .pillsList.value.keys
                                        .elementAt(index)
                                        .toString();
                                return itemWidget(
                                    pillKey,
                                    searchTerm.isNotEmpty
                                        ? _informationController
                                            .searchList[pillKey]
                                        : _informationController
                                            .pillsList[pillKey]);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget itemWidget(String pillName, String pillInformation) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(
          color: Constants.black,
          width: 2.0,
        )),
      ),
      child: Column(
        children: [
          Text(
            pillName,
            style: const TextStyle(fontSize: 21.0, fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Text(
            pillInformation
                .toString()
                .replaceAll("\\n", '\n')
                .replaceAll('\\', ''),
            style: const TextStyle(
              fontSize: 21.0,
            ),
          ),
        ],
      ),
    );
  }
}
