import 'dart:js_interop';

@JS('window.showWebNotification')
external void _showWebNotification(
  JSString title,
  JSString body,
  JSString? imageUrl,
  JSString? deepLink,
);

void showBrowserNotification({
  required String title,
  required String body,
  String? imageUrl,
  String? deepLink,
}) {
  try {
    _showWebNotification(
      title.toJS,
      body.toJS,
      imageUrl?.toJS,
      deepLink?.toJS,
    );
  } catch (_) {}
}
