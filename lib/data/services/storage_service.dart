import 'package:hive_flutter/hive_flutter.dart';

abstract final class StorageKeys {
  static const String player = 'player';
  static const String dailySession = 'daily_session';
  static const String settings = 'settings';
  static const String meta = 'meta';
  static const String processedPurchases = 'processed_purchases';
}

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    await Hive.openBox<Map>(StorageKeys.player);
    await Hive.openBox<Map>(StorageKeys.dailySession);
    await Hive.openBox(StorageKeys.settings);
    await Hive.openBox<Map>(StorageKeys.meta);
    await Hive.openBox<String>(StorageKeys.processedPurchases);
    _initialized = true;
  }

  Box<Map> get _playerBox => Hive.box<Map>(StorageKeys.player);
  Box<Map> get _sessionBox => Hive.box<Map>(StorageKeys.dailySession);
  Box<Map> get _metaBox => Hive.box<Map>(StorageKeys.meta);
  Box get _settingsBox => Hive.box(StorageKeys.settings);

  Map<String, dynamic>? readMap(Box<Map> box, String key) {
    final raw = box.get(key);
    if (raw == null) return null;
    return Map<String, dynamic>.from(raw);
  }

  Future<void> writeMap(Box<Map> box, String key, Map<String, dynamic> value) {
    return box.put(key, value);
  }

  Map<String, dynamic>? getPlayerData() => readMap(_playerBox, 'data');

  Future<void> savePlayerData(Map<String, dynamic> data) =>
      writeMap(_playerBox, 'data', data);

  Map<String, dynamic>? getDailySession(String dateKey) =>
      readMap(_sessionBox, dateKey);

  Future<void> saveDailySession(
    String dateKey,
    Map<String, dynamic> data,
  ) =>
      writeMap(_sessionBox, dateKey, data);

  bool hasNotificationsPreference() =>
      _settingsBox.containsKey('notificationsEnabled');

  Future<void> ensureNotificationsDefaultEnabled() async {
    if (!hasNotificationsPreference()) {
      await _settingsBox.put('notificationsEnabled', true);
    }
  }

  bool getNotificationsEnabled() =>
      _settingsBox.get('notificationsEnabled', defaultValue: true) as bool;

  Future<void> setNotificationsEnabled(bool value) =>
      _settingsBox.put('notificationsEnabled', value);

  Map<String, dynamic>? getMetaData() => readMap(_metaBox, 'data');

  Future<void> saveMetaData(Map<String, dynamic> data) =>
      writeMap(_metaBox, 'data', data);

  Map<String, dynamic>? getAudioSettings() {
    final raw = _settingsBox.get('audioSettings');
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  Future<void> saveAudioSettings(Map<String, dynamic> data) =>
      _settingsBox.put('audioSettings', data);

  String? getSettingString(String key) {
    final raw = _settingsBox.get(key);
    return raw is String ? raw : null;
  }

  Future<void> setSettingString(String key, String value) =>
      _settingsBox.put(key, value);

  Box<String> get _purchasesBox => Hive.box<String>(StorageKeys.processedPurchases);

  bool isPurchaseProcessed(String transactionId) {
    if (transactionId.isEmpty) return false;
    try {
      return _purchasesBox.containsKey(transactionId);
    } catch (_) {
      return false;
    }
  }

  Future<void> markPurchaseProcessed(String transactionId) async {
    if (transactionId.isEmpty) return;
    try {
      await _purchasesBox.put(transactionId, DateTime.now().toIso8601String());
    } catch (_) {}
  }
}
