import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/puzzle_session_config.dart';

final puzzleSessionProvider = StateProvider<PuzzleSessionConfig>(
  (ref) => PuzzleSessionConfig.daily,
);
