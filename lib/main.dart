import 'package:flutter/material.dart';
import 'package:nangmanmokpo/WebView/core/webview.dart';
import 'package:nangmanmokpo/firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Create a [AndroidNotificationChannel] for heads up notifications
// late AndroidNotificationChannel channel;
//
// bool isFlutterLocalNotificationsInitialized = false;
//
// Future<void> setupFlutterNotifications() async {
//   if (isFlutterLocalNotificationsInitialized) {
//     return;
//   }
//   channel = const AndroidNotificationChannel(
//     'high_importance_channel', // id
//     'High Importance Notifications', // title
//     description: 'This channel is used for important notifications.', // description
//     importance: Importance.high,
//   );
//
//   flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   /// Create an Android Notification Channel.
//   ///
//   /// We use this channel in the `AndroidManifest.xml` file to override the
//   /// default FCM channel to enable heads up notifications.
//   await flutterLocalNotificationsPlugin
//       ?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);
//
//   /// Update the iOS foreground notification presentation options to allow
//   /// heads up notifications.
//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );
//   isFlutterLocalNotificationsInitialized = true;
// }
//
// /**
//  * Firebase Background Messaging 핸들러
//  */
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//
//   // 공식 문서에서는 아래 호출 https://firebase.flutter.dev/docs/messaging/usage/
//   // await Firebase.initializeApp();
//   print('Handling a background message ${message.messageId}');
// }
//
// /**
//  * Firebase Foreground Messaging 핸들러
//  */
// Future<void> fbMsgForegroundHandler(
//     RemoteMessage message,
//     FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
//     AndroidNotificationChannel? channel) async {
//   print('[FCM - Foreground] MESSAGE : ${message.data}');
//
//   // if (message.notification != null) {
//   //   print('Message also contained a notification: ${message.notification}');
//   //   flutterLocalNotificationsPlugin.show(
//   //       message.hashCode,
//   //       message.notification?.title,
//   //       message.notification?.body,
//   //       NotificationDetails(
//   //           android: AndroidNotificationDetails(
//   //             channel.id,
//   //             channel.name,
//   //             channelDescription: channel.description,
//   //             icon: '@mipmap/ic_launcher',
//   //           ),
//   //           iOS: const DarwinNotificationDetails(
//   //             badgeNumber: 1,
//   //             subtitle: 'the subtitle',
//   //             sound: 'slow_spring_board.aiff',
//   //           )));
//   // }
// }
//
// void showFlutterNotification(RemoteMessage message) {
//   RemoteNotification? notification = message.notification;
//   AndroidNotification? android = message.notification?.android;
//
//   if (notification != null && android != null) {
//     flutterLocalNotificationsPlugin?.show(
//       notification.hashCode,
//       notification.title,
//       notification.body,
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           channel.id,
//           channel.name,
//           channelDescription: channel.description,
//           icon: '@mipmap/ic_launcher',
//         ),
//       ),
//     );
//   }
// }
//
// /**
//  * FCM 메시지 클릭 이벤트 정의
//  */
// Future<void> setupInteractedMessage(FirebaseMessaging fbMsg) async {
//   RemoteMessage? initialMessage = await fbMsg.getInitialMessage();
//   // 종료상태에서 클릭한 푸시 알림 메세지 핸들링
//   if (initialMessage != null) clickMessageEvent(initialMessage);
//   // 앱이 백그라운드 상태에서 푸시 알림 클릭 하여 열릴 경우 메세지 스트림을 통해 처리
//   FirebaseMessaging.onMessageOpenedApp.listen(clickMessageEvent);
// }
// void clickMessageEvent(RemoteMessage message) {
//   print('message : ${message.notification!.title}');
//   // Get.toNamed('/');
// }
//
// FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
//
Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // // LocalNotificationService.initialize();
  //
  // FirebaseMessaging fbMsg = FirebaseMessaging.instance;
  // String? fcmToken = await fbMsg.getToken();
  // print('token : ${fcmToken}');
  //
  // // Background messages
  // FirebaseMessaging.onMessage.listen(showFlutterNotification);
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // FirebaseMessaging.instance.getInitialMessage();
  //
  // await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );
  //
  // await setupFlutterNotifications();

  runApp(const MyApp());
}

/**
 * iOS 권한을 요청하는 함수
 */
// Future reqIOSPermission(FirebaseMessaging fbMsg) async {
//   NotificationSettings settings = await fbMsg.requestPermission(
//     alert: true,
//     announcement: false,
//     badge: true,
//     carPlay: false,
//     criticalAlert: false,
//     provisional: false,
//     sound: true,
//   );
// }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WebViewPage(),
    );
  }
}
