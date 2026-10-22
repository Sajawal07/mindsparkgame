import 'dart:math';

/// Difficulty tiers for the grid-based Word Ladder.
enum WordLadderDifficulty {
  easy,
  medium,
  hard;

  String get label => switch (this) {
        WordLadderDifficulty.easy => 'Easy',
        WordLadderDifficulty.medium => 'Medium',
        WordLadderDifficulty.hard => 'Hard',
      };

  int get columns => switch (this) {
        WordLadderDifficulty.easy => 4,
        WordLadderDifficulty.medium => 5,
        WordLadderDifficulty.hard => 7,
      };

  int get rows => switch (this) {
        WordLadderDifficulty.easy => 8,
        WordLadderDifficulty.medium => 12,
        WordLadderDifficulty.hard => 20,
      };
}

/// One row in the puzzle template (before shuffle).
class WordLadderRowTemplate {
  const WordLadderRowTemplate({
    required this.correctWord,
    required this.distractors,
  });

  final String correctWord;
  final List<String> distractors;
}

/// Static puzzle definition; [buildPlayable] shuffles row words per game.
class WordLadderGridPuzzle {
  const WordLadderGridPuzzle({
    required this.difficulty,
    required this.startWord,
    required this.targetWord,
    required this.correctPath,
    required this.rowTemplates,
  });

  final WordLadderDifficulty difficulty;
  final String startWord;
  final String targetWord;
  final List<String> correctPath;
  final List<WordLadderRowTemplate> rowTemplates;

  WordLadderPlayablePuzzle buildPlayable([Random? random]) {
    final rng = random ?? Random();
    final rows = rowTemplates.map((template) {
      final words = [template.correctWord, ...template.distractors];
      _shuffleInPlace(words, rng);
      return WordLadderPlayableRow(words: words);
    }).toList();

    return WordLadderPlayablePuzzle(
      difficulty: difficulty,
      startWord: startWord,
      targetWord: targetWord,
      correctPath: correctPath,
      rows: rows,
    );
  }

  static void _shuffleInPlace(List<String> list, Random rng) {
    for (var i = list.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final tmp = list[i];
      list[i] = list[j];
      list[j] = tmp;
    }
  }
}

class WordLadderPlayableRow {
  const WordLadderPlayableRow({required this.words});
  final List<String> words;
}

class WordLadderPlayablePuzzle {
  const WordLadderPlayablePuzzle({
    required this.difficulty,
    required this.startWord,
    required this.targetWord,
    required this.correctPath,
    required this.rows,
  });

  final WordLadderDifficulty difficulty;
  final String startWord;
  final String targetWord;
  final List<String> correctPath;
  final List<WordLadderPlayableRow> rows;

  int get rowCount => rows.length;
  int get columnCount => difficulty.columns;

  String? hintWordAfter(String currentWord) {
    final i = correctPath.indexOf(currentWord);
    if (i < 0 || i >= correctPath.length - 1) return null;
    return correctPath[i + 1];
  }
}

abstract final class WordLadderPuzzleCatalog {
  static List<WordLadderGridPuzzle> forDifficulty(WordLadderDifficulty d) =>
      switch (d) {
        WordLadderDifficulty.easy => _easy,
        WordLadderDifficulty.medium => _medium,
        WordLadderDifficulty.hard => _hard,
      };

  /// Daily / arena: easy until level 5, then scales like other puzzles.
  static WordLadderDifficulty difficultyForPlayerLevel(int playerLevel) {
    final level = playerLevel.clamp(1, 30);
    if (level <= 5) return WordLadderDifficulty.easy;
    if (level <= 15) return WordLadderDifficulty.medium;
    return WordLadderDifficulty.hard;
  }

  static bool differsByOneLetter(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) diff++;
      if (diff > 1) return false;
    }
    return diff == 1;
  }

  static bool isValidChain(List<String> chain) {
    if (chain.length < 2) return false;
    for (var i = 0; i < chain.length - 1; i++) {
      if (!differsByOneLetter(chain[i], chain[i + 1])) return false;
    }
    return true;
  }

  /// 1-based step index where chain breaks, or null if valid.
  static int? brokenStepIndex(List<String> chain) {
    for (var i = 0; i < chain.length - 1; i++) {
      if (!differsByOneLetter(chain[i], chain[i + 1])) return i + 1;
    }
    return null;
  }

  static final _easy = [
    _puzzle(WordLadderDifficulty.easy, _e1),
    _puzzle(WordLadderDifficulty.easy, _e2),
    _puzzle(WordLadderDifficulty.easy, _e3),
    _puzzle(WordLadderDifficulty.easy, _e4),
    _puzzle(WordLadderDifficulty.easy, _e5),
    _puzzle(WordLadderDifficulty.easy, _e6),
    _puzzle(WordLadderDifficulty.easy, _e7),
  ];

  static final _medium = [
    _puzzle(WordLadderDifficulty.medium, _m1),
    _puzzle(WordLadderDifficulty.medium, _m2),
    _puzzle(WordLadderDifficulty.medium, _m3),
    _puzzle(WordLadderDifficulty.medium, _m4),
    _puzzle(WordLadderDifficulty.medium, _m5),
    _puzzle(WordLadderDifficulty.medium, _m6),
    _puzzle(WordLadderDifficulty.medium, _m7),
  ];

  static final _hard = [
    _puzzle(WordLadderDifficulty.hard, _h1),
    _puzzle(WordLadderDifficulty.hard, _h2),
    _puzzle(WordLadderDifficulty.hard, _h3),
    _puzzle(WordLadderDifficulty.hard, _h4),
    _puzzle(WordLadderDifficulty.hard, _h5),
    _puzzle(WordLadderDifficulty.hard, _h6),
  ];

  // --- Easy (8 steps each) ---
  static const _e1 = [
    'SLEEP', 'BLEEP', 'BLEED', 'BREED', 'CREED', 'GREED', 'TREED', 'TREAD',
  ];
  static const _e2 = [
    'STONE', 'STORE', 'SCORE', 'SCARE', 'STARE', 'STATE', 'STALE', 'STALL',
  ];
  static const _e3 = [
    'SMOKE', 'SPOKE', 'STOKE', 'STOVE', 'STOLE', 'STALE', 'STALK', 'STALL',
  ];
  static const _e4 = [
    'BREAD', 'BROAD', 'BROOD', 'BROOK', 'BROOM', 'GROOM', 'GLOOM', 'BLOOM',
  ];
  static const _e5 = [
    'FLAME', 'FLAKE', 'FLARE', 'GLARE', 'GLADE', 'BLADE', 'BLAME', 'BLARE',
  ];
  static const _e6 = [
    'GLASS', 'GRASS', 'BRASS', 'BRASH', 'BRUSH', 'CRUSH', 'CRUST', 'TRUST',
  ];
  static const _e7 = [
    'BLACK', 'SLACK', 'SLICK', 'SLICE', 'SPICE', 'SPINE', 'SHINE', 'WHINE',
  ];

  // --- Medium (12 steps each) ---
  static const _m1 = [
    'BLACK', 'CLACK', 'SLACK', 'SLICK', 'SLICE', 'SPICE', 'SPICY', 'SPINY',
    'SHINY', 'SHINE', 'WHINE', 'WHILE',
  ];
  static const _m2 = [
    'CRACK', 'BRACK', 'BLACK', 'SLACK', 'SLICK', 'SLICE', 'SPICE', 'SPICY',
    'SPINY', 'SHINY', 'SHINE', 'WHINE',
  ];
  static const _m3 = [
    'STONE', 'STORE', 'SCORE', 'SCARE', 'STARE', 'STATE', 'STALE', 'STALL',
    'STILL', 'STILT', 'STINT', 'STING',
  ];
  static const _m4 = [
    'CRACK', 'BRACK', 'BLACK', 'BLANK', 'BLAND', 'BLEND', 'BLEED', 'BREED',
    'CREED', 'GREED', 'TREED', 'TREAD',
  ];
  static const _m5 = [
    'SMOKE', 'SPOKE', 'STOKE', 'STOVE', 'STOLE', 'STALE', 'STALK', 'STALL',
    'STILL', 'STILT', 'STINT', 'STING',
  ];
  static const _m6 = [
    'BEACH', 'PEACH', 'PEACE', 'PLACE', 'PLANE', 'PLATE', 'SLATE', 'SKATE',
    'STATE', 'STALE', 'SCALE', 'SCARE',
  ];
  static const _m7 = [
    'LIGHT', 'TIGHT', 'EIGHT', 'FIGHT', 'SIGHT', 'MIGHT', 'SIGHT', 'RIGHT',
    'FIGHT', 'EIGHT', 'TIGHT', 'NIGHT',
  ];

  // --- Hard (20 steps each) ---
  static const _h1 = [
    'SLEEP', 'SHEEP', 'SHEER', 'CHEER', 'CHEEK', 'CREEK', 'CREED', 'BREED',
    'BLEED', 'BLEND', 'BLOND', 'BLAND', 'BLANK', 'FLANK', 'FRANK', 'CRANK',
    'CRACK', 'TRACK', 'TRACE', 'BRACE',
  ];
  static const _h2 = [
    'BLACK', 'SLACK', 'STACK', 'STICK', 'STINK', 'SLINK', 'BLINK', 'BLIND',
    'BLOND', 'BLAND', 'BLIND', 'BLINK', 'BLANK', 'FLANK', 'FRANK', 'CRANK',
    'CRACK', 'TRACK', 'TRACE', 'BRACE',
  ];
  static const _h3 = [
    'FLAME', 'FLAKE', 'FLARE', 'GLARE', 'BLARE', 'BLAME', 'BLADE', 'GLADE',
    'GLIDE', 'GUIDE', 'GLIDE', 'SLIDE', 'SLIME', 'SLICE', 'SPICE', 'SPINE',
    'SHINE', 'WHINE', 'WHITE', 'WHILE',
  ];
  static const _h4 = [
    'STONE', 'STORE', 'SNORE', 'SNARE', 'SPARE', 'SPACE', 'SPICE', 'SLICE',
    'SLIME', 'SLIDE', 'SLICE', 'SPICE', 'SPIRE', 'SPARE', 'SPARK', 'STARK',
    'STACK', 'STICK', 'STINK', 'STING',
  ];
  static const _h5 = [
    'BREAD', 'TREAD', 'TREED', 'BREED', 'CREED', 'CREEK', 'CHEEK', 'CHEER',
    'SHEER', 'SHEEP', 'SHEER', 'CHEER', 'CHEEK', 'CREEK', 'CREED', 'TREED',
    'TREND', 'TREAD', 'BREAD', 'BREAK',
  ];
  static const _h6 = [
    'BEACH', 'PEACH', 'PEACE', 'PLACE', 'PLATE', 'SLATE', 'STATE', 'STALE',
    'STOLE', 'STOKE', 'SPOKE', 'SPIKE', 'SPICE', 'SLICE', 'SLIDE', 'GLIDE',
    'GLADE', 'GRADE', 'GRACE', 'BRACE',
  ];

  static WordLadderGridPuzzle _puzzle(
    WordLadderDifficulty difficulty,
    List<String> path,
  ) {
    assert(path.length == difficulty.rows);
    assert(isValidChain(path));
    final distractorCount = difficulty.columns - 1;
    final used = path.toSet();
    return WordLadderGridPuzzle(
      difficulty: difficulty,
      startWord: path.first,
      targetWord: path.last,
      correctPath: path,
      rowTemplates: [
        for (var i = 0; i < path.length; i++)
          WordLadderRowTemplate(
            correctWord: path[i],
            distractors: _distractorsFor(
              path[i],
              used,
              distractorCount,
              i,
            ),
          ),
      ],
    );
  }

  static const _distractorPool = [
    'PHONE', 'GRAPE', 'CHAIR', 'CLOCK', 'RIVER', 'MAPLE', 'TIGER', 'FROST',
    'PEARL', 'SWAMP', 'PIANO', 'EMBER', 'QUILL', 'JOUST', 'FLUTE', 'CRANE',
    'BLANK', 'BRACK', 'TRACK', 'STACK', 'CLICK', 'CLANK', 'SMACK', 'SNACK',
    'STICK', 'SNICK', 'SLIDE', 'SLIME', 'SPACE', 'SPARE', 'SPARK', 'STAGE',
    'STEAK', 'STEEL', 'STOOL', 'STORM', 'STORY', 'STOVE', 'SHARK', 'SHARP',
    'SHAKE', 'SHARE', 'SHORE', 'SCALE', 'SCARF', 'SCENE', 'SCOUT', 'DRAIN',
    'TRAIN', 'BRAIN', 'GRAND', 'GRADE', 'GRAVE', 'GROVE', 'FORGE', 'VERGE',
    'VERSE', 'PRESS', 'DRESS', 'CHEST', 'CHECK', 'CHEAP', 'CHEAT', 'WHEAT',
    'WHEEL', 'WHALE', 'WHOLE', 'CHILE', 'CHORD', 'CHORE', 'CHASE', 'PHASE',
    'PATCH', 'MATCH', 'WATCH', 'PITCH', 'WITCH', 'BATCH', 'CATCH', 'TOAST',
    'ROAST', 'COAST', 'HOIST', 'MOIST', 'FOIST', 'GUEST', 'QUEST', 'BEAST',
    'LEAST', 'FEAST', 'HEART', 'SMART', 'START', 'STARK', 'STAMP', 'STAND',
    'STAFF', 'STILL', 'STOCK', 'BLOCK', 'FLOCK', 'FLICK', 'FLINT', 'FLIRT',
    'FLOAT', 'FLOOD', 'FLOOR', 'GLOBE', 'GLOVE', 'GLOOM', 'GROOM', 'BROOM',
    'BROOK', 'BROOD', 'BROAD', 'BRAKE', 'BRAVE', 'BRINE', 'BRING', 'BRICK',
    'PRIDE', 'PRIME', 'PRINT', 'PROBE', 'PUNCH', 'PUPIL', 'QUEEN', 'QUIET',
    'QUICK', 'QUOTE', 'RADAR', 'RADIO', 'RALLY', 'RANGE', 'RAPID', 'REACH',
    'REACT', 'READY', 'REALM', 'RELAX', 'REPLY', 'RIDER', 'RIDGE', 'RIGHT',
    'RIGID', 'RIVAL', 'RIVER', 'ROBOT', 'ROCKY', 'ROGUE', 'ROUGH', 'ROUND',
    'ROUTE', 'ROYAL', 'RULER', 'RURAL', 'SALAD', 'SALON', 'SAUCE', 'SAVED',
    'SCENT', 'SCRAP', 'SENSE', 'SERVE', 'SEVEN', 'SHADE', 'SHALL', 'SHAME',
    'SHAPE', 'SHEET', 'SHELF', 'SHELL', 'SHIFT', 'SHIPS', 'SHIRT', 'SHOCK',
    'SHOPS', 'SHORT', 'SHOUT', 'SIGHT', 'SINCE', 'SIXTH', 'SKATE', 'SKILL',
    'SKIRT', 'SLATE', 'SLAVE', 'SLEEK', 'SLOPE', 'SMALL', 'SMASH', 'SMILE',
    'SNACK', 'SNAKE', 'SNEAK', 'SNORE', 'SOBER', 'SOLAR', 'SOLID', 'SOLVE',
    'SOUND', 'SOUTH', 'SPEAK', 'SPEAR', 'SPEED', 'SPELL', 'SPEND', 'SPIKE',
    'SPOIL', 'SPOON', 'SPORT', 'SPOTS', 'SPRAY', 'SQUAD', 'STAFF', 'STAIN',
    'STAIR', 'STAYS', 'STEAL', 'STEAM', 'STEEP', 'STEER', 'STEMS', 'STEPS',
    'STIFF', 'STOIC', 'STOMP', 'STOOL', 'STORK', 'STRAP', 'STRAW', 'STRAY',
    'STUCK', 'STUDY', 'STUFF', 'STYLE', 'SUGAR', 'SUITE', 'SUNNY', 'SUPER',
    'SURGE', 'SUSHI', 'SWAMP', 'SWEAR', 'SWEAT', 'SWEET', 'SWELL', 'SWIFT',
    'SWING', 'SWISS', 'SWORD', 'TABLE', 'TAKEN', 'TALES', 'TALKS', 'TANKS',
    'TASTE', 'TEACH', 'TEAMS', 'TEARS', 'TEASE', 'TEETH', 'TEMPO', 'TENTH',
    'TERMS', 'TESTS', 'THANK', 'THEFT', 'THEME', 'THICK', 'THIEF', 'THIGH',
    'THING', 'THINK', 'THIRD', 'THORN', 'THOSE', 'THREE', 'THREW', 'THROW',
    'THUMB', 'TILES', 'TIMER', 'TIMES', 'TIRED', 'TITLE', 'TODAY', 'TOKEN',
    'TONES', 'TOOLS', 'TOOTH', 'TOPIC', 'TORCH', 'TOTAL', 'TOWEL', 'TOWER',
    'TOXIC', 'TRAIL', 'TRAIT', 'TRAMP', 'TRASH', 'TREES', 'TREND', 'TRIAL',
    'TRIPE', 'TRUCK', 'TRULY', 'TRUNK', 'TRUTH', 'TULIP', 'TUNER', 'TUNES',
    'TUTOR', 'TWICE', 'TWINS', 'TWIST', 'UNCLE', 'UNDER', 'UNION', 'UNITE',
    'UNITY', 'UNTIL', 'UPPER', 'UPSET', 'URBAN', 'USAGE', 'USUAL', 'VALUE',
    'VALVE', 'VAPOR', 'VAULT', 'VENOM', 'VENUE', 'VIDEO', 'VIEWS', 'VILLA',
    'VINYL', 'VIOLA', 'VIRAL', 'VIRUS', 'VISIT', 'VITAL', 'VIVID', 'VOCAL',
    'VOICE', 'VOTER', 'WAGES', 'WAGON', 'WAIST', 'WASTE', 'WAVES', 'WEARY',
    'WEAVE', 'WEDGE', 'WEIGH', 'WEIRD', 'WHERE', 'WHICH', 'WHIPS', 'WHOSE',
    'WIDEN', 'WIDOW', 'WIDTH', 'WIELD', 'WOMAN', 'WOMEN', 'WORLD', 'WORMS',
    'WORRY', 'WORSE', 'WORTH', 'WOULD', 'WOUND', 'WRATH', 'WRECK', 'WREST',
    'WRIST', 'WRITE', 'WRONG', 'WROTE', 'YACHT', 'YEARS', 'YEAST', 'YIELD',
    'YOUNG', 'YOUTH', 'ZEBRA', 'ZONES',
  ];

  static List<String> _distractorsFor(
    String correct,
    Set<String> usedInPath,
    int count,
    int rowIndex,
  ) {
    final out = <String>[];
    var offset = rowIndex;
    for (var round = 0; round < 3 && out.length < count; round++) {
      for (var i = 0; i < _distractorPool.length && out.length < count; i++) {
        final w = _distractorPool[(offset + i) % _distractorPool.length];
        if (w == correct || usedInPath.contains(w) || out.contains(w)) continue;
        out.add(w);
      }
      offset += 17;
    }
    return out.take(count).toList();
  }
}
