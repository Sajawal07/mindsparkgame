enum WhoAmIDifficulty {
  easy,
  medium,
  hard,
  veryHard,
}

enum WhoAmICategory {
  worldScientist,
  inventor,
  historicLeader,
  pakistaniScientist,
  muslimScientist,
  pakistaniSports,
  pakistaniLiterature,
  pakistaniIcon,
  sports,
  explorer,
  artist,
  philosopher,
  religious,
}

extension WhoAmICategoryExt on WhoAmICategory {
  String get displayName {
    switch (this) {
      case WhoAmICategory.worldScientist:
        return 'World Scientist';
      case WhoAmICategory.inventor:
        return 'Inventor';
      case WhoAmICategory.historicLeader:
        return 'Historic Leader';
      case WhoAmICategory.pakistaniScientist:
        return 'Pakistani Scientist';
      case WhoAmICategory.muslimScientist:
        return 'Muslim Scientist';
      case WhoAmICategory.pakistaniSports:
        return 'Pakistani Sports';
      case WhoAmICategory.pakistaniLiterature:
        return 'Pakistani Literature';
      case WhoAmICategory.pakistaniIcon:
        return 'Pakistani Icon';
      case WhoAmICategory.sports:
        return 'Sports';
      case WhoAmICategory.explorer:
        return 'Explorer';
      case WhoAmICategory.artist:
        return 'Artist';
      case WhoAmICategory.philosopher:
        return 'Philosopher';
      case WhoAmICategory.religious:
        return 'Religious';
    }
  }
}

class WhoAmIQuestion {
  WhoAmIQuestion({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.category,
    required this.clues,
    required this.options,
    this.illustrationAsset,
    required this.funFact,
  }) {
    assert(
      options.contains(name),
      'Options must contain the correct answer (name).',
    );
  }

  final String id;
  final String name;
  final WhoAmIDifficulty difficulty;
  final WhoAmICategory category;
  
  /// Exactly 6 progressive clues.
  final List<String> clues;
  
  /// Exactly 4 options. The list must contain the correct [name].
  final List<String> options;
  
  /// Asset filename like 'einstein.png'.
  final String? illustrationAsset;
  
  /// A short fun fact shown on the result screen.
  final String funFact;

  bool get hasIllustration => illustrationAsset != null && illustrationAsset!.isNotEmpty;

  String get imagePath => 'assets/images/who_am_i/$illustrationAsset';
}
