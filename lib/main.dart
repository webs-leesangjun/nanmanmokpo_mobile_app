import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nangmanmokpo/WebView/core/webview.dart';
import 'package:nangmanmokpo/firebase_options.dart';
import 'package:nangmanmokpo/service/local_notification_service.dart';

/**
 * FCM 공식 문서 https://firebase.google.com/docs/cloud-messaging/flutter/receive?hl=ko
 */

/**
 * Firebase Background Messaging 핸들러
 */
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // showLocalNotification(message);
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print('## Handling a background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await LocalNotificationService().initialize();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 앱 상태 Background에서 실행 중일 때 수신한 푸시 알림 처리
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

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

