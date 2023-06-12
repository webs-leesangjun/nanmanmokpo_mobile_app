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
        scrollable: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            // crossAxisAlignment: CrossAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '낭만 목포 앱을 이용하기 위해 아래 권한들이 필요해요.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              const Text('선택적 접근',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('카메라',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        '• QR코드 스캔 (포인트 적립 및 이벤트 참여)\n• 프로필 설정 시 사진촬영',
                        style: TextStyle(
                            color: const Color(0xff000000).withOpacity(0.6)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('위치정보',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        '• 트래킹 코스 정보 제공\n• 관광지 정보 제공',
                        style: TextStyle(
                            color: const Color(0xff000000).withOpacity(0.6)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('신체 활동',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        '• 만보기 걸음수',
                        style: TextStyle(
                            color: const Color(0xff000000).withOpacity(0.6)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('알림 수신',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        '• 목포의 다양한 소식을 듣고 싶다면 ',
                        style: TextStyle(
                            color: const Color(0xff000000).withOpacity(0.6)),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              const Divider(),
              const SizedBox(height: 10),
              Text(
                '비허용시 해당 기능 이용이 어렵습니다.',
                style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xff000000).withOpacity(0.6)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                  width: double.infinity,
                  height: 50.0,
                  child: ElevatedButton(
                  onPressed: () {
                    // handlePermissionsCheckClick();
                    close();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff000000),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ]),
       );
  }

  void close() {
    Navigator.pop(context, true);
  }
}
