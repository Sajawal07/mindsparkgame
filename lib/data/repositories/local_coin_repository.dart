import 'dart:async';

import '../services/save_service.dart';
import '../services/storage_service.dart';
import 'coin_repository.dart';

/// Local implementation of [CoinRepository] using Hive via [StorageService]
/// and synchronized with [SaveService].
class LocalCoinRepository implements CoinRepository {
  LocalCoinRepository({
    StorageService? storageService,
    SaveService Function()? getSaveService,
  })  : _storage = storageService ?? StorageService.instance,
        _getSaveService = getSaveService;

  final StorageService _storage;
  final SaveService Function()? _getSaveService;
  final _balanceController = StreamController<int>.broadcast();

  SaveService? get _saveService => _getSaveService?.call();

  @override
  Future<int> getBalance() async {
    final save = _saveService;
    if (save != null) {
      return save.player.coins;
    }
    final playerData = _storage.getPlayerData();
    return (playerData?['coins'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<int> addCoins(int amount) async {
    if (amount <= 0) return getBalance();

    final save = _saveService;
    int newBalance;

    if (save != null) {
      newBalance = await save.addCoins(amount);
    } else {
      final current = await getBalance();
      newBalance = current + amount;
      final currentData = _storage.getPlayerData() ?? <String, dynamic>{};
      currentData['coins'] = newBalance;
      await _storage.savePlayerData(currentData);
    }

    _balanceController.add(newBalance);
    return newBalance;
  }

  @override
  Future<bool> spendCoins(int amount) async {
    if (amount <= 0) return false;

    final current = await getBalance();
    if (current < amount) return false;

    final save = _saveService;
    bool success;

    if (save != null) {
      success = await save.spendCoins(amount);
    } else {
      final newBalance = current - amount;
      final currentData = _storage.getPlayerData() ?? <String, dynamic>{};
      currentData['coins'] = newBalance;
      await _storage.savePlayerData(currentData);
      success = true;
    }

    if (success) {
      final updated = await getBalance();
      _balanceController.add(updated);
    }
    return success;
  }

  @override
  Future<bool> hasEnoughCoins(int amount) async {
    if (amount <= 0) return true;
    final current = await getBalance();
    return current >= amount;
  }

  @override
  Stream<int> watchBalance() async* {
    yield await getBalance();
    yield* _balanceController.stream;
  }

  @override
  void dispose() {
    _balanceController.close();
  }
}
