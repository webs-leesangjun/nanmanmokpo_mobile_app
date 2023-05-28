import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:activity_recognition_flutter/activity_recognition_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:location/location.dart' as locationLib;
import 'package:nangmanmokpo/components/dialog/request_permissions_view.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'webview_controller_extensions.dart';
import 'webview_functions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
// import 'package:location/location.dart';

const homeUrl = "https://dev.nangmanmokpo.kr/";

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key}) : super(key: key);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> with WidgetsBindingObserver {

  // 웹뷰
  InAppWebViewController? _webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        javaScriptCanOpenWindowsAutomatically: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        supportMultipleWindows: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  // Location
  late locationLib.LocationData _currentPosition;
  locationLib.Location location = new locationLib.Location();

  // 로컬 FCM 노티
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // addPostFrameCallback은 Widget build 이후에 한번만 실행
    WidgetsBinding.instance.addPostFrameCallback((_) => {_validatePermissions()});

    // 퍼미션 요청
    requestPermissions();

    // 장치 토큰 반환
    final deviceToken = getDeviceToken();

    // _configureLocalTimeZone();
    initInfo();

    FlutterNativeSplash.remove();
    _init();

    // FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    //   RemoteNotification? notification = message.notification;
    //   AndroidNotification? android = message.notification?.android;
    //
    //   // var androidNotiDetails = AndroidNotificationDetails(
    //   //   channel.id,
    //   //   channel.name,
    //   //   channelDescription: channel.description,
    //   // );
    //   // var iOSNotiDetails = const IOSNotificationDetails();
    //   // var details =
    //   // NotificationDetails(android: androidNotiDetails, iOS: iOSNotiDetails);
    //   // if (notification != null) {
    //   //   flutterLocalNotificationsPlugin.show(
    //   //     notification.hashCode,
    //   //     notification.title,
    //   //     notification.body,
    //   //     details,
    //   //   );
    //   // }
    // });
    //
    // FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //   print(message);
    // });

    fetchLocation();
  }

  void requestPermissions() async {
    bool isPassed = await requestPermission();

    requestFCMPermissions();
  }

  void _init() async {
    // Android requires explicitly asking permission
    if (Platform.isAndroid) {
      if (await Permission.activityRecognition.request().isGranted) {
        _startTracking();
      }
    }

    // iOS does not
    else {
      _startTracking();
    }
  }

  void _startTracking() {
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      FlutterAppBadger.removeBadge();
    }
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName!));
  }

  initInfo() {
    Future<void> _initializeNotification() async {
      const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
      InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    }
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page


    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title ?? ''),
        content: Text(body ?? ''),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              // Navigator.of(context, rootNavigator: true).pop();
              // await Navigator.push(
              //   context,
              //   // MaterialPageRoute(
              //   //   builder: (context) => SecondScreen(payload),
              //   // ),
              // );
            },
          )
        ],
      ),
    );
  }

  Future<void> _registerMessage({
    required int hour,
    required int minutes,
    required message,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minutes,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'flutter_local_notifications',
      message,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'channel id',
          'channel name',
          importance: Importance.max,
          priority: Priority.high,
          ongoing: true,
          styleInformation: BigTextStyleInformation(message),
          icon: 'ic_notification',
        ),
        iOS: const DarwinNotificationDetails(
          badgeNumber: 1,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// FCM 발송을 위한 장치 토큰 반환
  Future<String?> getDeviceToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  fetchLocation() async {

    developer.log('### fetchLocation', name: 'my.app.category');

    bool _serviceEnabled;
    // PermissionStatus _permissionGranted;
    //
    // _serviceEnabled = await location.serviceEnabled();
    // if (!_serviceEnabled) {
    //   _serviceEnabled = await location.requestService();
    //   if (!_serviceEnabled) {
    //     return;
    //   }
    // }

    developer.log('### fetchLocation 222 ', name: 'my.app.category');

    // _permissionGranted = await Permission.location.isGranted
    // if (_permissionGranted == PermissionStatus.denied) {
    //   _permissionGranted = await location.requestPermission();
    //   if (_permissionGranted != PermissionStatus.granted) {
    //     return;
    //   }
    // }

    developer.log('### fetchLocation 333 ', name: 'my.app.category');

    _currentPosition = await location.getLocation();

    developer.log('latitude: ${_currentPosition.latitude}', name: 'my.app.category');

    location.onLocationChanged.listen((locationLib.LocationData currentLocation) {
      setState(() {
        _currentPosition = currentLocation;
        developer.log('latitude === : ${currentLocation.latitude}', name: 'my.app.category');

        _webViewController?.evaluateJavascript(source: 'receivedLocation(${currentLocation.longitude}, ${currentLocation.latitude}, ${currentLocation.speed})');
        // getAddress(_currentPosition.latitude, _currentPosition.longitude)
        //     .then((value) {
        //   setState(() {
        //     _address = "＄{value.first.addressLine}";
        //   });
        // });
      });
    });
  }


  Future<bool> requestPermission() async {
    Map<Permission, PermissionStatus> status =
    await [Permission.location,
      Permission.activityRecognition,
      Permission.camera,
      Permission.notification].request();

    if (await Permission.location.isGranted) {
      return Future.value(true);
    } else {
      return Future.value(false);
    }
  }

  _validatePermissions() async {

    if (await Permission.location.isDenied) {
      // 권한 부여가 거부되었습니다.
    }

    if (await Permission.location.isPermanentlyDenied) {
      // 권한 부여가 영구적으로 거부되었습니다.
    }

    if (await Permission.location.isRestricted) {
      // 권한이 제한되었습니다.
    }

    // if (await Permission.location.isDenied) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return const RequestPermissionsView();
          });
    // }
  }

  void requestFCMPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted permission");
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print("User granted provisional permission");
    } else {
      print("User declined or has not accepted permission");
    }

  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            body: SafeArea(child: _createCustomWebView(),
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.arrow_upward),
            onPressed: () async {
              // lo
              final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
              await _registerMessage(
                hour: now.hour,
                minutes: now.minute + 1,
                message: 'Hello, world!',
              );

              _currentPosition = await location.getLocation();

              developer.log('latitude : ${_currentPosition.latitude}', name: 'my.app.category');
              developer.log('longitude : ${_currentPosition.longitude}', name: 'my.app.category');
              developer.log('speed : ${_currentPosition.speed}', name: 'my.app.category');


              _webViewController?.evaluateJavascript(source: 'receivedLocation(${_currentPosition.longitude}, ${_currentPosition.latitude}, ${_currentPosition.speed})');
              // if (_webViewController != null) {
              //
              //   developer.log('javascript method call', name: 'my.app.category');
              //   _webViewController?.evaluateJavascript(
              //       source: 'fromFlutter("From Flutter")');xx
              // }
            },
          ),
        ),
        onWillPop: () => _handleGoBack(context));
  }

  JavascriptChannel _webToAppChange(BuildContext context) {
    return JavascriptChannel(
        name: 'webToAppChange',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          print("webToAppChange 메시지 : ${message.message}");
        });
  }

  Widget _createCustomWebView() {
    developer.log('uri: @@@@@', name: 'my.app.category');
    // final activity = _events[0];

    return InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(homeUrl)),
        initialOptions: options,
        onWebViewCreated: (InAppWebViewController controller) {
          _webViewController = controller;
        },
        onCreateWindow: (_, createWindowAction) =>
            showSubDialogWebView(context, createWindowAction),
        shouldOverrideUrlLoading: (controller, shouldOverrideUrlLoadingRequest) async {
          Uri? uri = shouldOverrideUrlLoadingRequest.request.url;
          developer.log('uri: ${uri.toString()}', name: 'my.app.category');
          developer.log('uri host: ${uri?.host}', name: 'my.app.category');

          // debugPrint('uri host: ${uri?.host}');
          // 맵 URI화면에 오면, GPS데이터 자바스크립트로 전송

          // if ((uri.toString()).startsWith('https://google.com')) {
          //   return NavigationActionPolicy.ALLOW;
          // } else {
          //   launchURL(uri.toString());
          //   return NavigationActionPolicy.CANCEL;
          // }
          return NavigationActionPolicy.ALLOW;
        },
        onLoadStop: (_, __) {
          developer.log("### DONE ###");
          FlutterNativeSplash.remove();
        },
        androidOnPermissionRequest: handleAndroidOnPermissionRequest,
        androidOnGeolocationPermissionsShowPrompt:
        handleAndroidOnGeolocationPermissionsShowPrompt);
  }

  Future<bool> _handleGoBack(BuildContext context) async {
    if (_webViewController == null) return true;
    return _webViewController!.ifCanGoBackThenGoBack(context);
  }

  void onDidReceiveNotificationResponse(NotificationResponse details) {
  }
}

Future<PermissionRequestResponse?> handleAndroidOnPermissionRequest(
    InAppWebViewController controller,
    String origin,
    List<String> resources) async {
  bool isRequestVideoCapture = resources
      .firstWhere((element) => element.contains("VIDEO_CAPTURE"))
      .isNotEmpty;

  if (isRequestVideoCapture) {
    // await Permission.camera.request();
    // await Permission.microphone.request();

    return PermissionRequestResponse(
        resources: resources, action: PermissionRequestResponseAction.GRANT);
  }

  return PermissionRequestResponse(
      resources: resources, action: PermissionRequestResponseAction.DENY);
}

Future<GeolocationPermissionShowPromptResponse?>
handleAndroidOnGeolocationPermissionsShowPrompt(
    InAppWebViewController controller, String origin) async =>
    GeolocationPermissionShowPromptResponse(
        origin: origin, allow: true, retain: true);
