import 'puzzle_result_model.dart';

class DailySessionModel {
  const DailySessionModel({
    required this.dateKey,
    this.puzzleResults = const [],
    this.brainScore = 0,
    this.iqRank = '',
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.isComplete = false,
  });

  final String dateKey;
  final List<PuzzleResultModel> puzzleResults;
  final int brainScore;
  final String iqRank;
  final int coinsEarned;
  final int xpEarned;
  final bool isComplete;

  int get completedPuzzleCount =>
      puzzleResults.where((r) => r.isComplete).length;

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'puzzleResults': puzzleResults.map((r) => r.toJson()).toList(),
        'brainScore': brainScore,
        'iqRank': iqRank,
        'coinsEarned': coinsEarned,
        'xpEarned': xpEarned,
        'isComplete': isComplete,
      };

  factory DailySessionModel.fromJson(Map<String, dynamic> json) {
    final results = (json['puzzleResults'] as List<dynamic>?)
            ?.map((e) => PuzzleResultModel.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [];
    return DailySessionModel(
      dateKey: json['dateKey'] as String? ?? '',
      puzzleResults: results,
      brainScore: json['brainScore'] as int? ?? 0,
      iqRank: json['iqRank'] as String? ?? '',
      coinsEarned: json['coinsEarned'] as int? ?? 0,
      xpEarned: json['xpEarned'] as int? ?? 0,
      isComplete: json['isComplete'] as bool? ?? false,
    );
  }

  DailySessionModel copyWith({
    String? dateKey,
    List<PuzzleResultModel>? puzzleResults,
    int? brainScore,
    String? iqRank,
    int? coinsEarned,
    int? xpEarned,
    bool? isComplete,
  }) {
    return DailySessionModel(
      dateKey: dateKey ?? this.dateKey,
      puzzleResults: puzzleResults ?? this.puzzleResults,
      brainScore: brainScore ?? this.brainScore,
      iqRank: iqRank ?? this.iqRank,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      xpEarned: xpEarned ?? this.xpEarned,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}
