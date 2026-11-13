import 'dart:js_interop';

@JS('wefixAppReady')
external JSFunction? get _wefixAppReady;

void notifyAppReady() => _wefixAppReady?.callAsFunction();
