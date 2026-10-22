import 'package:intl/intl.dart';

import '../catalog/challenge_catalog.dart';
import '../models/challenge_model.dart';
import '../models/daily_session_model.dart';
import '../models/game_meta_model.dart';
import '../models/player_model.dart';
import '../models/puzzle_result_model.dart';
import '../models/puzzle_type.dart';

class ChallengeService {
  GameMetaModel ensureChallenges(GameMetaModel meta, String todayKey) {
    var challenges = meta.challenges.isEmpty
        ? ChallengeCatalog.createDefaults()
        : List<ChallengeModel>.from(meta.challenges);

    var result = meta.copyWith(challenges: challenges);

    if (meta.dailyChallengeResetKey != todayKey) {
      challenges = _resetType(challenges, ChallengeType.daily);
      result = result.copyWith(
        challenges: challenges,
        dailyChallengeResetKey: todayKey,
      );
    }

    final weekKey = _weekKey(DateTime.now());
    if (meta.weeklyChallengeResetKey != weekKey) {
      challenges = _resetType(result.challenges, ChallengeType.weekly);
      var newCounters = Map<String, int>.from(result.lifetimeCounters);
      newCounters.remove('math_140_week');
      newCounters.remove('memory_week');
      newCounters.remove('word_week');
      newCounters.remove('focus_week');
      newCounters.remove('brain_800_week');
      
      result = result.copyWith(
        challenges: challenges,
        weeklyChallengeResetKey: weekKey,
        lifetimeCounters: newCounters,
      );
    }

    return evaluateLifetimeChallenges(result, const PlayerModel());
  }

  GameMetaModel evaluateLifetimeChallenges(GameMetaModel meta, PlayerModel player) {
    var challenges = List<ChallengeModel>.from(meta.challenges);

    if (player.level >= 10) {
      challenges = _completeChallenge(challenges, 'life_level_10');
    }
    if (player.level >= 20) {
      challenges = _completeChallenge(challenges, 'life_level_20');
    }
    if (player.level >= 30) {
      challenges = _completeChallenge(challenges, 'life_level_30');
    }

    if (player.streak >= 7) {
      challenges = _completeChallenge(challenges, 'life_week_warrior');
      challenges = _setProgress(
        challenges,
        'weekly_7_day_warrior',
        player.streak.clamp(0, 7),
      );
    }
    if (player.streak >= 30) {
      challenges = _completeChallenge(challenges, 'life_month_mind');
    }

    return meta.copyWith(challenges: challenges);
  }

  List<ChallengeModel> _resetType(
    List<ChallengeModel> all,
    ChallengeType type,
  ) {
    final defaults =
        ChallengeCatalog.createDefaults().where((c) => c.type == type);
    final kept = all.where((c) => c.type != type);
    return [...kept, ...defaults];
  }

  String _weekKey(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return DateFormat('yyyy-MM-dd').format(monday);
  }

  GameMetaModel onPuzzleComplete({
    required GameMetaModel meta,
    required PlayerModel player,
    required DailySessionModel session,
    required PuzzleType type,
    required PuzzleResultModel result,
  }) {
    var challenges = List<ChallengeModel>.from(meta.challenges);
    var counters = Map<String, int>.from(meta.lifetimeCounters);

    void bump(String key, [int by = 1]) {
      counters[key] = (counters[key] ?? 0) + by;
    }

    bump('total_puzzles');

    switch (type) {
      case PuzzleType.mathBlitz:
        if (result.score >= 140) bump('math_140');
        if (result.timeTakenSeconds < 15) {
          challenges = _completeChallenge(challenges, 'daily_speed_demon');
          bump('math_fast_15');
        }
        if (result.accuracy >= 1.0 && result.timeTakenSeconds < 10) {
          challenges = _completeChallenge(challenges, 'life_speed_legend');
        }
      case PuzzleType.memoryFlip:
        if (result.score >= 180) {
          challenges = _completeChallenge(challenges, 'daily_perfect_memory');
          bump('memory_perfect');
        }
      case PuzzleType.patternIq:
        if (result.score >= 200) {
          challenges = _completeChallenge(challenges, 'daily_pattern_master');
          bump('pattern_perfect');
        }
      case PuzzleType.wordSnap:
        if (result.accuracy >= 1.0) {
          challenges = _completeChallenge(challenges, 'daily_word_wizard');
          bump('word_perfect');
        }
      case PuzzleType.focusFind:
        if (result.score >= 280) {
          challenges = _completeChallenge(challenges, 'daily_eagle_eye');
          bump('focus_perfect');
        }
      case PuzzleType.whoAmI:
      case PuzzleType.scienceSnap:
      case PuzzleType.wordLadder:
      case PuzzleType.colorBrain:
      case PuzzleType.cupShuffle:
      case PuzzleType.weightBalance:
      case PuzzleType.pathFinder:
        break;
    }

    if (result.score >= 140 && type == PuzzleType.mathBlitz) {
      challenges = _incrementWeekly(
        challenges,
        'weekly_math_champion',
        counters['math_140_week'] ?? 0,
      );
      counters['math_140_week'] = (counters['math_140_week'] ?? 0) + 1;
    }

    if (type == PuzzleType.memoryFlip && result.score >= 180) {
      final c = (counters['memory_week'] ?? 0) + 1;
      counters['memory_week'] = c;
      challenges = _setProgress(challenges, 'weekly_memory_king', c);
    }

    if (type == PuzzleType.wordSnap && result.accuracy >= 1.0) {
      final c = (counters['word_week'] ?? 0) + 1;
      counters['word_week'] = c;
      challenges = _setProgress(challenges, 'weekly_vocabulary', c);
    }

    if (type == PuzzleType.focusFind && result.score >= 280) {
      final c = (counters['focus_week'] ?? 0) + 1;
      counters['focus_week'] = c;
      challenges = _setProgress(challenges, 'weekly_focused', c);
    }

    final allDone = PuzzleType.dailyOrder.every(
      (t) => session.puzzleResults.any((r) => r.puzzleType == t && r.isComplete),
    );
    if (allDone) {
      challenges = _completeChallenge(challenges, 'daily_full_session');
    }

    if (session.isComplete) {
      challenges = _completeChallenge(challenges, 'life_first_spark');
      if (player.streak >= 7) {
        challenges = _setProgress(
          challenges,
          'weekly_7_day_warrior',
          player.streak.clamp(0, 7),
        );
      }
      if (session.brainScore >= 800) {
        final c = (counters['brain_800_week'] ?? 0) + 1;
        counters['brain_800_week'] = c;
        challenges = _setProgress(challenges, 'weekly_brain_athlete', c);
      }
      if (session.brainScore >= 950) {
        challenges = _completeChallenge(challenges, 'life_einstein_moment');
      }

      if (session.brainScore >= 900) {
        bump('high_score_days');
        final streak = counters['high_score_streak'] ?? 0;
        counters['high_score_streak'] = streak + 1;
        challenges = _setProgress(
          challenges,
          'life_perfect_week',
          counters['high_score_streak']!,
        );
      } else {
        counters['high_score_streak'] = 0;
      }
    }

    challenges = _setProgress(
      challenges,
      'life_puzzle_completionist',
      counters['total_puzzles'] ?? 0,
    );
    challenges = _setProgress(
      challenges,
      'life_memory_legend',
      counters['memory_perfect'] ?? 0,
    );
    challenges = _setProgress(
      challenges,
      'life_pattern_genius',
      counters['pattern_perfect'] ?? 0,
    );

    var hasEinstein = meta.hasReachedEinsteinRank;
    if (session.brainScore >= 950) hasEinstein = true;

    return evaluateLifetimeChallenges(
      meta.copyWith(
        challenges: challenges,
        lifetimeCounters: counters,
        hasReachedEinsteinRank: hasEinstein,
      ),
      player,
    );
  }

  List<ChallengeModel> _completeChallenge(
    List<ChallengeModel> list,
    String id,
  ) {
    return list.map((c) {
      if (c.id != id) return c;
      return c.copyWith(
        progress: c.target,
        isComplete: true,
      );
    }).toList();
  }

  List<ChallengeModel> _setProgress(
    List<ChallengeModel> list,
    String id,
    int progress,
  ) {
    return list.map((c) {
      if (c.id != id) return c;
      final p = progress.clamp(0, c.target);
      return c.copyWith(
        progress: p,
        isComplete: p >= c.target,
      );
    }).toList();
  }

  List<ChallengeModel> _incrementWeekly(
    List<ChallengeModel> list,
    String id,
    int current,
  ) {
    return _setProgress(list, id, current + 1);
  }
}
