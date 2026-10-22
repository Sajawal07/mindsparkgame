import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/network_service.dart';

/// Provider for the singleton NetworkService.
final networkServiceProvider = Provider<NetworkService>((ref) {
  return NetworkService.instance;
});

/// Stream of internet connectivity changes.
final isOnlineStreamProvider = StreamProvider<bool>((ref) {
  final network = ref.watch(networkServiceProvider);
  return network.onConnectivityChanged;
});

/// Reactive boolean indicating whether device currently has internet access.
final isOnlineProvider = Provider<bool>((ref) {
  final streamVal = ref.watch(isOnlineStreamProvider);
  return streamVal.value ?? ref.watch(networkServiceProvider).isOnline;
});
