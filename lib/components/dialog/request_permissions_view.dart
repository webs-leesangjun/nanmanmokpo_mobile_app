import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class RequestPermissionsView extends StatefulWidget {
  const RequestPermissionsView({Key? key}) : super(key: key);

  @override
  State<RequestPermissionsView> createState() => RequestPermissionsViewState();
}

class RequestPermissionsViewState extends State<RequestPermissionsView> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: Column(
            children: [
              const Text(
                '낭만 목포 앱을 이용하기 위해 아래 권한들이 필요해요.',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              const Text('백그라운드 위치 정보 접근 권한 및 보관',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  '- 만보기 기능 사용\n- 사용자 편의 기능 제공',
                  style: TextStyle(
                      color: const Color(0xff000000).withOpacity(0.6)),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              Text(
                '미허용시 해당 기능 이용이 어렵습니다.',
                style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xff000000).withOpacity(0.6)),
              ),
            ],
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start),
        actions: [
          OutlinedButton(
            onPressed: () {
              close();
            },
            child: const Text('거절'),
          ),
          ElevatedButton(
            onPressed: () {
              handlePermissionsCheckClick();
            },
            child: const Text('확인'),
            style: ElevatedButton.styleFrom(elevation: 0),
          ),
        ]);
  }

  void handlePermissionsCheckClick() async {
    var requestStatus = await Permission.location.request();
    var status = await Permission.location.status;

    if (await requestStatus.isGranted ) {
      // isLimited - 제한적 동의 (ios 14 < )
      return close();
    } else if (requestStatus.isPermanentlyDenied ||
        status.isPermanentlyDenied) {
      // 권한 요청 거부, 해당 권한에 대한 요청에 대해 다시 묻지 않음 선택하여 설정화면에서 변경해야함. android
      print("isPermanentlyDenied");
      openAppSettings();
    } else if (status.isRestricted) {
      // 권한 요청 거부, 해당 권한에 대한 요청을 표시하지 않도록 선택하여 설정화면에서 변경해야함. ios
      print("isRestricted");
      openAppSettings();
    } else if (status.isDenied) {
      // 권한 요청 거절
      print("isDenied");
    }

    // requestPermissions();
  }

  void requestPermissions() async {
    await Permission.location.request();
  }

  void close() {
    Navigator.pop(context, true);
  }
}
