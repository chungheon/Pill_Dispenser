import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pill_dispenser/controllers/schedule_controller.dart';
import 'package:pill_dispenser/controllers/user_state_controller.dart';
import 'package:pill_dispenser/screens/forget_password_page.dart';
import 'package:pill_dispenser/widgets/custom_splash_button.dart';
import 'package:pill_dispenser/widgets/standard_app_bar.dart';
import 'package:pill_dispenser/widgets/standard_scaffold.dart';
import 'package:pill_dispenser/widgets/time_spinner_dialog.dart';
import 'package:table_calendar/table_calendar.dart';

import '../constants.dart';
import '../widgets/custom_input_text_box_widget.dart';

class ScheduleAppointmentPage extends StatelessWidget {
  ScheduleAppointmentPage({Key? key}) : super(key: key);
  final ScheduleController _scheduleController = Get.find<ScheduleController>();
  final UserStateController _userStateController =
      Get.find<UserStateController>();
  final RxString appointmentName = ''.obs;
  final RxString msg = ''.obs;
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final Rx<DateTime> pageDate =
      Rx<DateTime>(DateTime.now().add(const Duration(days: 1)));
  final Rx<DateTime> currentDate = Rx<DateTime>(DateTime.now());
  final Rxn<DateTime> selectedTime = Rxn<DateTime>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: StandardScaffold(
          appBar: const StandardAppBar().appBar(),
          child: ListView(
            children: [
              const SizedBox(
                height: 10.0,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildEditInformationDisplay('Appointment Name',
                    appointmentName, 'Enter Appointment Name'),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildEditInformationDisplay(
                    'Message (Optional)', appointmentName, 'Message'),
              ),
              const SizedBox(
                height: 20.0,
              ),
              _buildCalenderDisplay(),
              Container(
                color: Constants.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 20.0),
                child: Obx(
                  () => CustomSplashButton(
                    title: selectedTime.value == null
                        ? "Select Time"
                        : _scheduleController
                            .formatDateToStrTime(selectedTime.value!),
                    onTap: () async {
                      selectedTime.value = await showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return TimeSpinnerDialog(
                              selectedTime.value ?? currentDate.value,
                              minutesInterval: 1,
                            );
                          });
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Obx(
                  () => _buildInformationDisplay(
                    'Selected Date And Time',
                    selectedDate.value == null
                        ? 'Select A Date And Time'
                        : '${_scheduleController.formatDateToStr(selectedDate.value!)}  ' +
                            '${selectedTime.value != null ? _scheduleController.formatDateToStrTime(selectedTime.value!) : ""}',
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: CustomSplashButton(
                  title: 'Schedule Appointment',
                  onTap: () async {
                    if (appointmentName.trim().isNotEmpty &&
                        selectedDate.value != null &&
                        selectedTime.value != null) {
                      await _scheduleController.scheduleAppointment(
                          _userStateController.user.value?.uid ?? 'ERROR',
                          appointmentName.value,
                          selectedDate.value ?? DateTime.now(),
                          selectedTime.value ?? DateTime.now(),
                          message: msg.value);
                      Get.back();
                    } else {
                      showDialog(
                          context: context,
                          builder: ((dContext) {
                            return const DefaultErrorDialog(
                              title: 'Unable to continue',
                              message:
                                  'Please enter a Name, Date and Time to continue.',
                            );
                          }));
                    }
                  },
                ),
              ),
            ],
          )),
    );
  }

  TextStyle textStyleCalendar() {
    return const TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: Constants.black,
    );
  }

  TextStyle textStyleHintCalender() {
    return const TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: Constants.grey,
    );
  }

  TextStyle textStyleCalendarDays() {
    return const TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: Constants.black,
    );
  }

  TextStyle textStyleParagraph() {
    return const TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: Constants.black);
  }

  Widget _buildCalenderDisplay() {
    return Obx(
      () {
        selectedDate.value;
        int pageMonth = pageDate.value.month;
        int pageYear = pageDate.value.year;
        DateTime futureDate = currentDate.value.add(const Duration(days: 365));
        bool right = pageMonth < futureDate.month || pageYear < futureDate.year;
        bool left = pageMonth > currentDate.value.month ||
            (pageYear > currentDate.value.year);
        return Container(
          color: Constants.white,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: TableCalendar(
              headerStyle: HeaderStyle(
                titleCentered: true,
                titleTextStyle: textStyleParagraph(),
                formatButtonVisible: false,
                headerPadding: EdgeInsets.only(
                  left: !left ? 80.0 : 0,
                  right: !right ? 80 : 0,
                  bottom: 15.0,
                ),
                rightChevronVisible: right,
                leftChevronVisible: left,
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: textStyleCalendarDays(),
                  weekendStyle: textStyleCalendarDays()),
              calendarStyle: CalendarStyle(
                defaultTextStyle: textStyleCalendar(),
                selectedDecoration: const BoxDecoration(
                  color: Constants.primary,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: textStyleCalendar(),
                disabledTextStyle: textStyleHintCalender(),
                weekendTextStyle: textStyleCalendar(),
                outsideTextStyle: textStyleCalendar(),
              ),
              focusedDay: pageDate.value,
              firstDay: currentDate.value.add(const Duration(days: 1)),
              lastDay: futureDate,
              onPageChanged: (date) {
                pageDate.value = date;
              },
              onDaySelected: (selectedDay, focusedDay) {
                selectedDate.value = selectedDay;
              },
              selectedDayPredicate: (day) {
                return day == selectedDate.value;
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildInformationDisplay(String title, String information) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18.0),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
          decoration: BoxDecoration(
            color: Constants.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                  color: Constants.black.withOpacity(0.2), blurRadius: 10.0)
            ],
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            information,
            style: const TextStyle(fontSize: 17.0),
          ),
        ),
      ],
    );
  }

  Widget _buildEditInformationDisplay(
      String title, RxString strObs, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18.0),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: Constants.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                  color: Constants.black.withOpacity(0.2), blurRadius: 10.0)
            ],
          ),
          alignment: Alignment.centerLeft,
          child: CustomInputTextBox(
            inputObs: strObs,
            title: hint,
          ),
        ),
      ],
    );
  }
}
