import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service responsible for monitoring real internet connectivity.
/// Uses connectivity_plus to listen for network interface changes,
/// and verifies real internet reachability via DNS/socket lookup.
class NetworkService {
  NetworkService._();
  static final NetworkService instance = NetworkService._();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  bool _isOnline = true;
  bool get isOnline => _isOnline;
  Stream<bool> get onConnectivityChanged => _controller.stream;

  StreamSubscription? _subscription;
  bool _initialized = false;

  /// Optional override for testing.
  bool? _testOnlineOverride;
  @visibleForTesting
  void setTestOnlineOverride(bool? override) {
    _testOnlineOverride = override;
    if (override != null) {
      _isOnline = override;
      _controller.add(override);
    }
  }

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    if (_testOnlineOverride != null) {
      _isOnline = _testOnlineOverride!;
      return;
    }

    try {
      final results = await _connectivity.checkConnectivity();
      _isOnline = await _verifyConnection(results);
      _controller.add(_isOnline);

      _subscription = _connectivity.onConnectivityChanged.listen((results) async {
        final online = await _verifyConnection(results);
        if (online != _isOnline) {
          _isOnline = online;
          _controller.add(_isOnline);
        }
      });
    } catch (e) {
      debugPrint('NetworkService init error: $e');
      _isOnline = true; // Fallback to optimistic
    }
  }

  /// Actively checks and updates internet reachability status.
  Future<bool> checkInternet() async {
    if (_testOnlineOverride != null) {
      return _testOnlineOverride!;
    }

    try {
      final results = await _connectivity.checkConnectivity();
      final online = await _verifyConnection(results);
      if (online != _isOnline) {
        _isOnline = online;
        _controller.add(_isOnline);
      }
      return online;
    } catch (e) {
      debugPrint('NetworkService checkInternet error: $e');
      return _isOnline;
    }
  }

  Future<bool> _verifyConnection(List<ConnectivityResult> results) async {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return false;
    }

    // In unit test environment, don't attempt external network requests
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return true;
    }

    try {
      final lookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(milliseconds: 2500));
      return lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
    } catch (_) {
      try {
        final socket = await Socket.connect('8.8.8.8', 53,
            timeout: const Duration(milliseconds: 2000));
        socket.destroy();
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
