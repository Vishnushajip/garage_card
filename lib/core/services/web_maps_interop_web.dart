import 'dart:async';
import 'dart:js_interop';

@JS('wefixSearchPlaces')
external void _wefixSearchPlaces(
  JSString query,
  JSNumber? lat,
  JSNumber? lng,
  JSFunction callback,
);

@JS('wefixReverseGeocode')
external void _wefixReverseGeocode(
  JSNumber lat,
  JSNumber lng,
  JSFunction callback,
);

Future<String?> callWebSearchPlaces(String query, double? lat, double? lng) {
  final completer = Completer<String?>();
  try {
    final jsCallback = ((JSString result) {
      if (!completer.isCompleted) {
        completer.complete(result.toDart);
      }
    }).toJS;

    _wefixSearchPlaces(query.toJS, lat?.toJS, lng?.toJS, jsCallback);
  } catch (_) {
    if (!completer.isCompleted) completer.complete(null);
  }
  return completer.future.timeout(
    const Duration(seconds: 8),
    onTimeout: () => null,
  );
}

Future<String?> callWebReverseGeocode(double lat, double lng) {
  final completer = Completer<String?>();
  try {
    final jsCallback = ((JSString result) {
      if (!completer.isCompleted) {
        completer.complete(result.toDart);
      }
    }).toJS;

    _wefixReverseGeocode(lat.toJS, lng.toJS, jsCallback);
  } catch (_) {
    if (!completer.isCompleted) completer.complete(null);
  }
  return completer.future.timeout(
    const Duration(seconds: 8),
    onTimeout: () => null,
  );
}
