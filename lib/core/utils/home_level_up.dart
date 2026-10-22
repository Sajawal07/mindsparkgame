import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../../data/providers/game_providers.dart';

/// Call after navigation that may land on the Modes home screen.
void scheduleHomeLevelUpCheck(BuildContext context, WidgetRef ref) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    if (GoRouter.of(context).state.matchedLocation != AppRoutes.home) return;
    ref.read(gameStateProvider).notifyHomeVisible();
  });
}
