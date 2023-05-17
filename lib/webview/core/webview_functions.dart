import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// pure functions

/// JS 에서 window.open() 요청이 들어왔을 때 사용하는 함수.
/// 앱쪽에서 웹뷰를 가진 다이얼로그를 띄우고 JS 요청을 내부 웹뷰에서 처리함.
Future<bool?> showSubDialogWebView(
    BuildContext context, CreateWindowAction createWindowAction) {
  BuildContext dialogContext;

  return showDialog(
    context: context,
    builder: (context) {
      dialogContext = context;

      return InAppWebView(
        windowId: createWindowAction.windowId,
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(),
        ),
        onCloseWindow: (controller) => Navigator.pop(dialogContext, true),
      );
    },
  );
}