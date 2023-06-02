import 'dart:async';

class NotificationHandler {
  final StreamController<String?> selectNotificationStream = StreamController<String?>.broadcast();

  void sendNotification(String? message) {
    // 선택 알림 페이로드 전송
    selectNotificationStream.add(message);
  }
}