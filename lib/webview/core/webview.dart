import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:location/location.dart' as locationLib;
import 'package:nangmanmokpo/components/dialog/request_permissions_view.dart';
import 'package:pedometer/pedometer.dart';
import 'package:webview_flutter/platform_interface.dart';
import '../../service/local_notification_service.dart';
import 'webview_controller_extensions.dart';
import 'webview_functions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// class ReceivedNotification {
//   ReceivedNotification({
//     required this.id,
//     required this.title,
//     required this.body,
//     required this.payload,
//   });
//
//   final int id;
//   final String? title;
//   final String? body;
//   final String? payload;
// }


void showLocalNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  if (message.data["title"] != null) {
    LocalNotificationService().showNotification(notification.hashCode, message.data["title"], message.data["body"], message.data["link"]);
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key}) : super(key: key);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> with WidgetsBindingObserver {
  String homeUrl = "https://dev.nangmanmokpo.kr/";
  StreamSubscription<PedestrianStatus>? pedestrianStatusSubscription;
  StreamSubscription<StepCount>? stepCountStreamSubscription;

  String _status = '?', _steps = '?';

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
  locationLib.Location location = locationLib.Location();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    // addPostFrameCallback은 Widget build 이후에 한번만 실행
    WidgetsBinding.instance.addPostFrameCallback((_) => {
      _widgetBuildAfter()
    });

    _configureSelectNotificationSubject();

    // Terminated State
    FirebaseMessaging.instance.getInitialMessage().then((event) async {
      if (event != null) {
        setState(() {
          notificationMsg = "### Terminate : ${event!.data["link"]}";
        });
        final link = event!.data["link"];

        while (_webViewController == null) {
          // _webViewController가 null이 아닐 때까지 대기
          await Future.delayed(Duration(milliseconds: 100));
        }
        _webViewController!.loadUrl(urlRequest: URLRequest(url: Uri.parse(link)));

        notificationHandler.sendNotification(link);
      }
    });

    // Foreground State
    FirebaseMessaging.onMessage.listen((event) {
      setState(() {
        notificationMsg = "### onMessage : ${event!.data["link"]}";
      });
      showLocalNotification(event);
    });

    // Background State
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      setState(() {
        notificationMsg = "### onMessageOpenedApp : ${event!.data["link"]}";
        final link = event!.data["link"];
        notificationHandler.sendNotification(link);
      });
    });

    // init();
    // _configureLocalTimeZone();
    // FlutterNativeSplash.remove();
//    _init();

    // _fetchLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    stopListeningToPedestrianStatus();
    stopListeningToPedestrianStep();

    super.dispose();
  }

  void _configureSelectNotificationSubject() {
    notificationHandler.selectNotificationStream.stream.listen((String? payload) {
      // 선택 알림 처리 로직
      if (payload != null) {
        print('### 선택 알림: $payload');
        bool nullable = false;
        if (_webViewController == null) {
          nullable = true;
        }
        print('### wc : ' + nullable.toString());
        _webViewController!.loadUrl(urlRequest: URLRequest(url: Uri.parse(payload)));
        // 추가 작업 수행
      }
    });
  }

  Future<bool> checkLocationPermission() async {
    PermissionStatus status = await Permission.location.status;
    return status.isGranted;
  }

  Future<bool> checkCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;
    return status.isGranted;
  }

  Future<bool> checkActivityRecognitionPermission() async {
    PermissionStatus status = await Permission.activityRecognition.status;
    return status.isGranted;
  }

  Future<bool> checkNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;
    return status.isGranted;
  }

  void _widgetBuildAfter() async {
    // 권한 확인
    final locationStatus = await checkLocationPermission();
    final cameraStatus = await checkCameraPermission();
    final activityRecognitionStatus = await checkActivityRecognitionPermission();
    final notificationStatus = await checkNotificationPermission();
    final fcmStatus = await _requestFCMPermissions();

    if (locationStatus && cameraStatus && activityRecognitionStatus && notificationStatus && fcmStatus) {
      // 카메라 및 위치 권한이 모두 허용된 경우 처리할 로직 작성
    } else {
      _requestMultiplePermissions();
      _showPermissionsDialog();
    }

    if (activityRecognitionStatus)  {
      startListeningToPedestrianStatus();
      startListeningToPedestrianStep();
    }

    // 장치 토큰 아이디 요청
    final deviceToken = await _requestDeviceToken();
    print("### deviceToken " + deviceToken!.toString());
  }

  Future<bool> _requestMultiplePermissions() async {
    final cameraStatus = await Permission.camera.request();
    final activityRecognitionStatus = await Permission.activityRecognition.request();
    final notificationStatus = await Permission.notification.request();
    final fcmStatus = await _requestFCMPermissions();
    final locationStatus = await Permission.location.request();

    if (cameraStatus.isGranted && locationStatus.isGranted && activityRecognitionStatus.isGranted && notificationStatus.isGranted && fcmStatus) {
      return Future.value(true);
      // 카메라 및 위치 권한이 모두 허용된 경우 처리할 로직 작성
    }

    // 권한이 거부되었거나 일부 권한이 허용되지 않은 경우 처리할 로직 작성x
    return Future.value(false);
  }

  Future<String?> _requestDeviceToken() async {
    return await getDeviceToken();
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

  /// FCM 발송을 위한 장치 토큰 반환
  Future<String?> getDeviceToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  /// 현재 위치의 위도, 경도, 속도
  void _fetchLocation() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    _currentPosition = await location.getLocation();

    print('latitude: ${_currentPosition.latitude}');

    location.onLocationChanged.listen((locationLib.LocationData currentLocation) {
      setState(() {
        _currentPosition = currentLocation;
        print('latitude === : ${currentLocation.latitude}');
        print('longitude === : ${currentLocation.longitude}');

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

  /// 모든 퍼미션이 허용이 아닐때 다이얼로그 보여줌
  void _showPermissionsDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const RequestPermissionsView();
        });
  }

  /// FCM 퍼미션 요청
  Future<bool> _requestFCMPermissions() async {
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
      // User granted permission
      print("### User FCM granted permission");
      return Future.value(true);
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      // User granted provisional permission
      print("### User FCM granted provisional permission");
      return Future.value(true);
    } else {
      // User declined or has not accepted permission
      print("### User FCM declined or has not accepted permission");
      return Future.value(false);
    }
  }

  /**
   * iOS 권한을 요청하는 함수
   */
  Future _reqIOSPermission(FirebaseMessaging fbMsg) async {
    NotificationSettings settings = await fbMsg.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  String notificationMsg = "Waiting for notification";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  // SizedBox(
                  //   height: 40,
                  //     child: Text("${_status} ${_steps}", textAlign: TextAlign.center)
                  // ),
                  Expanded(child: _createCustomWebView()),
                ],
              ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   child: const Icon(Icons.arrow_upward),
          //   onPressed: () async {
          //     // lo
          //
          //     await LocalNotificationService().showNotificationWithActions();
          //
          //     // final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
          //     // await _registerMessage(
          //     //   hour: now.hour,
          //     //   minutes: now.minute + 1,
          //     //   message: 'Hello, world!',
          //     // );
          //
          //     // _webViewController?.evaluateJavascript(source: 'receivedLocation(${_currentPosition.longitude}, ${_currentPosition.latitude}, ${_currentPosition.speed})');
          //     // if (_webViewController != null) {
          //     //
          //     //   developer.log('javascript method call', name: 'my.app.category');
          //     //   _webViewController?.evaluateJavascript(
          //     //       source: 'fromFlutter("From Flutter")');xx
          //     // }
          //   },
          // ),
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
    return InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(homeUrl)),
        initialOptions: options,
        onWebViewCreated: (InAppWebViewController controller) {
          setState(() {
            _webViewController = controller;
          });
        },
        onCreateWindow: (_, createWindowAction) =>
            showSubDialogWebView(context, createWindowAction),
        shouldOverrideUrlLoading: (controller, shouldOverrideUrlLoadingRequest) async {
          Uri? uri = shouldOverrideUrlLoadingRequest.request.url;
          print('uri: ${uri.toString()}');
          print('uri host: ${uri?.host}');

          // 맵 URI화면에 오면, GPS데이터 자바스크립트로 전송

          if ((uri.toString()).contains('company')) {
            _fetchLocation();
          }

          if ((uri.toString()).contains('/my/my_walk')) {
            // 권한이 없으면 권한 요청
            final permission = await checkActivityRecognitionPermission();
            if (permission == false) {
              _showPermissionsDialog();
              return NavigationActionPolicy.CANCEL;
            } else {
                startListeningToPedestrianStatus();
                startListeningToPedestrianStep();
            }
          }

          if ((uri.toString()).contains('qr')) {
            final permission = await checkCameraPermission();
            if (permission == false) {
              _showPermissionsDialog();
              return NavigationActionPolicy.CANCEL;
            }
          }
          //   return NavigationActionPolicy.ALLOW;
          // } else {
          //   launchURL(uri.toString());
          //   return NavigationActionPolicy.CANCEL;
          // }
          return NavigationActionPolicy.ALLOW;
        },
        onLoadStop: (_, __) {
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

  void startListeningToPedestrianStatus() {
    pedestrianStatusSubscription = Pedometer.pedestrianStatusStream.listen(
          (PedestrianStatus status) {

        // 보행자 상태 변화에 대한 처리
        print('보행자 상태: ${status.status}');
        _webViewController?.evaluateJavascript(source: 'receivedPedestrianStatus("${status.status}")');

        setState(() {
          _status = status.status;
        });
      },
    );
  }

  void stopListeningToPedestrianStatus() {
    pedestrianStatusSubscription?.cancel();
  }

  void startListeningToPedestrianStep() {
    stepCountStreamSubscription = Pedometer.stepCountStream.listen(
          (StepCount event) {
        // 보행자 상태 변화에 대한 처리
        print('보행자 걸음수: ${event.steps}');
        _webViewController?.evaluateJavascript(source: 'receivedPedestrianStep(${event.steps})');

        setState(() {
          _steps = event.steps.toString();
        });
      },
      onError: onStepCountError,
      onDone: onStepCountDone,
    );
  }

  void stopListeningToPedestrianStep() {
    stepCountStreamSubscription?.cancel();
  }


  void onPedestrianStatusError(error) {
    print("### onPedestrianStatusError: $error");
    _status = 'Pedestrian Status not available';

  }

  void onStepCountDone() {
    print("### onStepCountDone");
  }

  void onStepCountError(error) {
    print("### onStepCountError: $error");
    _steps = 'Step Count not available';
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
