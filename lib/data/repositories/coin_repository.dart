/// Abstract contract for coin storage and transactions.
/// Can be implemented by [LocalCoinRepository] (current) or
/// [FirebaseCoinRepository] (future backend migration).
abstract class CoinRepository {
  /// Returns the current coin balance.
  Future<int> getBalance();

  /// Adds [amount] coins to the account and returns the updated balance.
  Future<int> addCoins(int amount);

  /// Deducts [amount] coins if sufficient balance exists.
  /// Returns `true` if coins were spent, or `false` if balance was insufficient.
  Future<bool> spendCoins(int amount);

  /// Returns `true` if current balance is greater than or equal to [amount].
  Future<bool> hasEnoughCoins(int amount);

  /// Stream of balance updates for reactive UI.
  Stream<int> watchBalance();

  /// Clean up any resources/controllers when repository is disposed.
  void dispose();
}
