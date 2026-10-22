import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/game_providers.dart';
import '../repositories/coin_repository.dart';
import '../repositories/local_coin_repository.dart';

/// Central manager for coin balance and transactions.
/// Provides a clean abstraction between the UI/Game layers and the underlying
/// repository ([LocalCoinRepository] now, or [FirebaseCoinRepository] in future).
class CoinManager {
  CoinManager(this._repository);

  final CoinRepository _repository;

  /// Returns the current coin balance.
  Future<int> getBalance() => _repository.getBalance();

  /// Adds [amount] coins to the player account.
  Future<int> addCoins(int amount) => _repository.addCoins(amount);

  /// Deducts [amount] coins from the player account if affordable.
  Future<bool> spendCoins(int amount) => _repository.spendCoins(amount);

  /// Returns `true` if the player has at least [amount] coins.
  Future<bool> hasEnoughCoins(int amount) => _repository.hasEnoughCoins(amount);

  /// Reactive stream of coin balance changes.
  Stream<int> watchBalance() => _repository.watchBalance();

  void dispose() => _repository.dispose();
}

/// Provider for the active [CoinRepository].
/// Currently injects [LocalCoinRepository] connected to [SaveService] and Hive.
final coinRepositoryProvider = Provider<CoinRepository>((ref) {
  final gameState = ref.watch(gameStateProvider);
  final repo = LocalCoinRepository(
    getSaveService: () => gameState.save,
  );
  ref.onDispose(repo.dispose);
  return repo;
});

/// Provider for [CoinManager].
final coinManagerProvider = Provider<CoinManager>((ref) {
  final repo = ref.watch(coinRepositoryProvider);
  return CoinManager(repo);
});

/// Stream provider for reactive UI consumption of current coin balance.
final coinBalanceStreamProvider = StreamProvider<int>((ref) {
  final manager = ref.watch(coinManagerProvider);
  return manager.watchBalance();
});
