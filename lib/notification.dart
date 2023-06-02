//
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// class FlutterLocalNotification {
//   FlutterLocalNotification._();
//
//   static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   static init() async {
//     const DarwinInitializationSettings initializationSettingsIOS =
//     DarwinInitializationSettings(
//       requestAlertPermission: false,
//       requestBadgePermission: false,
//       requestSoundPermission: false,
//     );
//     const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const InitializationSettings initializationSettings =
//     InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );
//
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
//         switch (notificationResponse.notificationResponseType) {
//           case NotificationResponseType.selectedNotification:
//             selectNotificationStream.add(notificationResponse.payload);
//             break;
//           case NotificationResponseType.selectedNotificationAction:
//             if (notificationResponse.actionId == navigationActionId) {
//               selectNotificationStream.add(notificationResponse.payload);
//             }
//             break;
//         }
//       },
//       onDidReceiveBackgroundNotificationResponse: notificationTapBackground,);
//   }
// }