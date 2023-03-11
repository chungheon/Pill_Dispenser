import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pill_dispenser/constants.dart';
import 'package:pill_dispenser/controllers/user_state_controller.dart';
import 'package:pill_dispenser/screens/forget_password_page.dart';
import 'package:pill_dispenser/widgets/standard_app_bar.dart';
import 'package:pill_dispenser/widgets/standard_scaffold.dart';

class GuardianRequestsListPage extends StatelessWidget {
  GuardianRequestsListPage({Key? key}) : super(key: key);

  final UserStateController _userStateController =
      Get.find<UserStateController>();

  @override
  Widget build(BuildContext context) {
    return StandardScaffold(
      appBar: const StandardAppBar().appBar(),
      child: Obx(
        () {
          if (_userStateController.requests.isEmpty) {
            return const Center(
                child: Text(
              'There are no requests',
              style: TextStyle(fontSize: 25.0),
            ));
          }

          return ListView.builder(
            itemCount: _userStateController.requests.length,
            itemBuilder: (context, index) {
              var keys = _userStateController.requests.keys;
              var data = _userStateController.requests[keys.elementAt(index)];
              return Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 15.0),
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: Constants.white,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                        color: Constants.black.withOpacity(0.2),
                        blurRadius: 10.0)
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Name: ${data["name"]}',
                            style: const TextStyle(fontSize: 17.0),
                          ),
                          Text(
                            'Email: ${data["email"]}',
                            style: const TextStyle(fontSize: 17.0),
                          ),
                          Text(
                            'Contact Details: ${data["contact_details"]}',
                            style: const TextStyle(fontSize: 17.0),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                        onLongPress: () async {
                          bool result =
                              await _userStateController.acceptGuardian(
                            data["email"] ?? 'ERROR',
                            data['users_id'] ?? 'ERROR',
                            false,
                          );
                          if (result) {
                            _userStateController.requests
                                .remove(keys.elementAt(index));
                            showDialog(
                                context: context,
                                builder: (dContext) {
                                  return const DefaultDialog(
                                    title: 'Successfully REJECTED',
                                    message:
                                        'You have rejected the user\'s request',
                                  );
                                });
                          }
                        },
                        child: const Center(
                            child: Icon(
                          Icons.remove,
                          size: 40.0,
                          color: Constants.primary,
                        ))),
                    GestureDetector(
                        onTap: () async {
                          bool result =
                              await _userStateController.acceptGuardian(
                            data["email"] ?? 'ERROR',
                            data['users_id'] ?? 'ERROR',
                            true,
                          );
                          if (result) {
                            _userStateController.requests
                                .remove(keys.elementAt(index));
                            showDialog(
                                context: context,
                                builder: (dContext) {
                                  return const DefaultDialog(
                                    title: 'Successfully Accepted',
                                    message:
                                        'You have accepted the user\'s request',
                                  );
                                });
                          }
                        },
                        child: const Center(
                            child: Icon(
                          Icons.add,
                          size: 40.0,
                          color: Constants.primary,
                        ))),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
