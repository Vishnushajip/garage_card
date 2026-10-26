import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityStatus { online, offline }

class ConnectivityController extends Notifier<ConnectivityStatus> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  ConnectivityStatus build() {
    ref.onDispose(() {
      try {
        _subscription?.cancel();
      } catch (_) {}
    });

    Future.microtask(_initConnectivity);
    return ConnectivityStatus.online;
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _handleResults(results);
      _subscription = _connectivity.onConnectivityChanged.listen(
        _handleResults,
        onError: (_) {
          state = ConnectivityStatus.online;
        },
      );
    } catch (_) {
      await _checkViaSocket();
    }
  }

  void _handleResults(List<ConnectivityResult> results) {
    if (results.isEmpty ||
        results.every((result) => result == ConnectivityResult.none)) {
      state = ConnectivityStatus.offline;
    } else {
      state = ConnectivityStatus.online;
    }
  }

  Future<void> _checkViaSocket() async {
    if (kIsWeb) {
      state = ConnectivityStatus.online;
      return;
    }

    try {
      final addresses = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 2));
      if (addresses.isNotEmpty && addresses.first.rawAddress.isNotEmpty) {
        state = ConnectivityStatus.online;
      } else {
        state = ConnectivityStatus.offline;
      }
    } catch (_) {
      state = ConnectivityStatus.offline;
    }
  }

  Future<bool> retry() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _handleResults(results);
      return state == ConnectivityStatus.online;
    } catch (_) {
      await _checkViaSocket();
      return state == ConnectivityStatus.online;
    }
  }
}

final connectivityControllerProvider =
    NotifierProvider<ConnectivityController, ConnectivityStatus>(
      ConnectivityController.new,
    );

final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityControllerProvider) == ConnectivityStatus.online;
});
