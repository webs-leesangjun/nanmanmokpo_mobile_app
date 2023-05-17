import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

extension WebViewControllerExtension on InAppWebViewController {
  Future<bool> ifCanGoBackThenGoBack(BuildContext context) async {
    if (await canGoBack()) {
      goBack();

      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
