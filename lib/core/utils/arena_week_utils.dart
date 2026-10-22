/// UTC week helpers for Arena weekly AP reset (Monday 00:00 UTC).
abstract final class ArenaWeekUtils {
  /// Date key (`yyyy-MM-dd`) of the Monday that starts the current UTC week.
  static String currentWeekKey() {
    final now = DateTime.now().toUtc();
    final daysFromMonday = now.weekday - DateTime.monday;
    final monday = DateTime.utc(now.year, now.month, now.day)
        .subtract(Duration(days: daysFromMonday));
    return '${monday.year.toString().padLeft(4, '0')}-'
        '${monday.month.toString().padLeft(2, '0')}-'
        '${monday.day.toString().padLeft(2, '0')}';
  }
}
