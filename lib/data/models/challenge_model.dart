enum ChallengeType { daily, weekly, lifetime }

class ChallengeModel {
  const ChallengeModel({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.target,
    required this.rewardCoins,
    this.progress = 0,
    this.isComplete = false,
    this.isClaimed = false,
  });

  final String id;
  final ChallengeType type;
  final String name;
  final String description;
  final int target;
  final int rewardCoins;
  final int progress;
  final bool isComplete;
  final bool isClaimed;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'name': name,
        'description': description,
        'target': target,
        'rewardCoins': rewardCoins,
        'progress': progress,
        'isComplete': isComplete,
        'isClaimed': isClaimed,
      };

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id'] as String,
      type: ChallengeType.values.byName(json['type'] as String),
      name: json['name'] as String,
      description: json['description'] as String,
      target: json['target'] as int? ?? 1,
      rewardCoins: json['rewardCoins'] as int? ?? 0,
      progress: json['progress'] as int? ?? 0,
      isComplete: json['isComplete'] as bool? ?? false,
      isClaimed: json['isClaimed'] as bool? ?? false,
    );
  }

  ChallengeModel copyWith({
    int? progress,
    bool? isComplete,
    bool? isClaimed,
  }) {
    return ChallengeModel(
      id: id,
      type: type,
      name: name,
      description: description,
      target: target,
      rewardCoins: rewardCoins,
      progress: progress ?? this.progress,
      isComplete: isComplete ?? this.isComplete,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}
