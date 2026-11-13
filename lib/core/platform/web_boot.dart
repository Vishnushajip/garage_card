import 'package:flutter/widgets.dart';

import 'web_boot_stub.dart'
    if (dart.library.js_interop) 'web_boot_web.dart'
    as impl;

abstract final class WebBoot {
  static bool _done = false;

  static void appReady() {
    if (_done) return;
    _done = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => impl.notifyAppReady());
  }
}

