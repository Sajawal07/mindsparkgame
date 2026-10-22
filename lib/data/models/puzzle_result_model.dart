import 'puzzle_type.dart';

class PuzzleResultModel {
  const PuzzleResultModel({
    required this.puzzleType,
    required this.score,
    required this.accuracy,
    required this.timeTakenSeconds,
    required this.xpEarned,
    required this.isComplete,
  });

  final PuzzleType puzzleType;
  final int score;
  final double accuracy;
  final int timeTakenSeconds;
  final int xpEarned;
  final bool isComplete;

  Map<String, dynamic> toJson() => {
        'puzzleType': puzzleType.name,
        'score': score,
        'accuracy': accuracy,
        'timeTakenSeconds': timeTakenSeconds,
        'xpEarned': xpEarned,
        'isComplete': isComplete,
      };

  factory PuzzleResultModel.fromJson(Map<String, dynamic> json) {
    return PuzzleResultModel(
      puzzleType: PuzzleType.values.byName(json['puzzleType'] as String),
      score: json['score'] as int? ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0,
      timeTakenSeconds: json['timeTakenSeconds'] as int? ?? 0,
      xpEarned: json['xpEarned'] as int? ?? 0,
      isComplete: json['isComplete'] as bool? ?? false,
    );
  }
}
