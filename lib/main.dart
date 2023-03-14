import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pill_dispenser/controllers/information_controller.dart';
import 'package:pill_dispenser/controllers/schedule_controller.dart';
import 'package:pill_dispenser/controllers/user_state_controller.dart';
import 'package:pill_dispenser/screens/home_page.dart';
import 'package:pill_dispenser/screens/qr_scan_page.dart';
import 'package:responsive_framework/responsive_wrapper.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

String initialRoute = '/';

int id = 0;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

const MethodChannel platform = MethodChannel('pill_dispenser');

const String portName = 'notification_send_port';

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;

/// A notification action which triggers a url launch event
const String urlLaunchActionId = 'id_1';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

NotificationAppLaunchDetails? notificationAppLaunchDetails;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initHive();
  await _configureLocalTimeZone();

  String initialRoute = '/';
  notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload =
        notificationAppLaunchDetails!.notificationResponse?.payload;
  }

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('user');

  final List<DarwinNotificationCategory> darwinNotificationCategories =
      <DarwinNotificationCategory>[
    DarwinNotificationCategory(
      darwinNotificationCategoryText,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.text(
          'text_1',
          'Action 1',
          buttonTitle: 'Send',
          placeholder: 'Placeholder',
        ),
      ],
    ),
    DarwinNotificationCategory(
      darwinNotificationCategoryPlain,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain('id_1', 'Action 1'),
        DarwinNotificationAction.plain(
          'id_2',
          'Action 2 (destructive)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
        ),
        DarwinNotificationAction.plain(
          navigationActionId,
          'Action 3 (foreground)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
        DarwinNotificationAction.plain(
          'id_4',
          'Action 4 (auth required)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.authenticationRequired,
          },
        ),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    )
  ];

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    onDidReceiveLocalNotification:
        (int id, String? title, String? body, String? payload) async {
      didReceiveLocalNotificationStream.add(
        ReceivedNotification(
          id: id,
          title: title,
          body: body,
          payload: payload,
        ),
      );
    },
    notificationCategories: darwinNotificationCategories,
  );
  final LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(
    defaultActionName: 'Open notification',
    defaultIcon: AssetsLinuxIcon('/assets/icons/user.png'),
  );
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
    linux: initializationSettingsLinux,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) {
      switch (notificationResponse.notificationResponseType) {
        case NotificationResponseType.selectedNotification:
          selectNotificationStream.add(notificationResponse.payload);
          break;
        case NotificationResponseType.selectedNotificationAction:
          if (notificationResponse.actionId == navigationActionId) {
            selectNotificationStream.add(notificationResponse.payload);
          }
          break;
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  runApp(const MyApp());
}

Future<void> initHive() async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String appDocPath = appDocDir.path;
  Hive.init(appDocPath);
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Permission.notification.request();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        Get.put(UserStateController(), permanent: true);
        Get.put(ScheduleController(), permanent: true);
        Get.put(InformationController(), permanent: true);
      }),
      navigatorObservers: [routeObserver],
      builder: (context, child) => ResponsiveWrapper(
          shrinkWrap: true,
          maxWidth: 1200,
          minWidth: 480,
          defaultScale: true,
          mediaQueryData: MediaQuery.of(context),
          breakpoints: const [
            ResponsiveBreakpoint.resize(480, name: MOBILE),
            ResponsiveBreakpoint.autoScale(800, name: TABLET),
            ResponsiveBreakpoint.resize(1000, name: DESKTOP),
          ],
          background: Container(color: const Color(0xFFF5F5F5)),
          child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: KeyboardAvoider(child: child!))),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/home': (context) => HomePage(),
        '/scanner': (context) => QrScanPage(),
      },
    );
  }
}

class KeyboardAvoider extends StatelessWidget {
  final Widget child;

  const KeyboardAvoider({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).viewInsets.bottom);
    return AnimatedContainer(
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom > 0
            ? (ResponsiveWrapper.of(context).screenHeight *
                    MediaQuery.of(context).viewInsets.bottom) /
                ResponsiveWrapper.of(context).screenHeight
            : 0,
      ),
      duration: const Duration(milliseconds: 100),
      child: child,
    );
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  void transitToHome(BuildContext context) {
    Get.offAndToNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(((timeStamp) async {
      Future.delayed(const Duration(seconds: 2))
          .then((value) => transitToHome(context));
    }));
    return MediaQuery(
      data: Get.mediaQuery.copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 80.0),
              padding: const EdgeInsets.all(40.0),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF5F5F5),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/hero_image.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(
              height: 5.0,
            ),
            const Center(
                child: Text(
              "Pill Dispenser",
              style: TextStyle(fontSize: 40.0),
            )),
          ],
        ),
      ),
    );
  }
}
