import '../../core/constants/app_assets.dart';

enum IqRank {
  beyondEinstein,
  einstein,
  daVinci,
  newton,
  scholar,
  average,
  warmingUp;

  static IqRank fromBrainScore(int score) {
    if (score >= 950) return IqRank.beyondEinstein;
    if (score >= 850) return IqRank.einstein;
    if (score >= 750) return IqRank.daVinci;
    if (score >= 650) return IqRank.newton;
    if (score >= 550) return IqRank.scholar;
    if (score >= 400) return IqRank.average;
    return IqRank.warmingUp;
  }

  String get displayName => switch (this) {
        IqRank.beyondEinstein => 'Beyond Einstein',
        IqRank.einstein => 'Einstein Level',
        IqRank.daVinci => 'Da Vinci Level',
        IqRank.newton => 'Newton Level',
        IqRank.scholar => 'Scholar Level',
        IqRank.average => 'Average Thinker',
        IqRank.warmingUp => 'Just Warming Up',
      };

  String get comparison => switch (this) {
        IqRank.beyondEinstein =>
          'Even Einstein would take notes from you!',
        IqRank.einstein =>
          'You think like the greatest mind in history!',
        IqRank.daVinci =>
          'A true Renaissance mind — art and science in one!',
        IqRank.newton => 'Gravity cannot hold your brain down!',
        IqRank.scholar => 'Sharp, focused, and always growing!',
        IqRank.average => 'A solid mind — keep training daily!',
        IqRank.warmingUp =>
          'Your brain is just getting started — do not give up!',
      };

  String get iqEstimate => switch (this) {
        IqRank.beyondEinstein => '145+',
        IqRank.einstein => '135–144',
        IqRank.daVinci => '125–134',
        IqRank.newton => '115–124',
        IqRank.scholar => '105–114',
        IqRank.average => '90–104',
        IqRank.warmingUp => 'Below 90',
      };

  String get illustrationAsset => switch (this) {
        IqRank.beyondEinstein => AppAssets.iqBeyondEinstein,
        IqRank.einstein => AppAssets.iqEinstein,
        IqRank.daVinci => AppAssets.iqDaVinci,
        IqRank.newton => AppAssets.iqNewton,
        IqRank.scholar => AppAssets.iqScholar,
        IqRank.average => AppAssets.iqAverage,
        IqRank.warmingUp => AppAssets.iqWarmingUp,
      };
}
