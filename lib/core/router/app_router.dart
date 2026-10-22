import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:go_router/go_router.dart';



import '../../data/providers/game_providers.dart';
import '../../features/login/login_screen.dart';

import '../../features/arena_store/arena_store_screen.dart';

import '../../features/challenges/challenges_screen.dart';

import '../../features/currency_shop/currency_shop_screen.dart';
import '../../features/daily_result/daily_result_screen.dart';

import '../../features/home/home_screen.dart';

import '../../features/leaderboard/leaderboard_screen.dart';

import '../../features/modes/arena_mode_screen.dart';
import '../../features/modes/arena_round_result_screen.dart';

import '../../features/modes/blitz_mode_screen.dart';

import '../../features/modes/practice_mode_screen.dart';

import '../../features/onboarding/onboarding_screen.dart';

import '../../features/profile/profile_screen.dart';

import '../../features/puzzles/focus_find/focus_find_screen.dart';

import '../../features/puzzles/math_blitz/math_blitz_screen.dart';

import '../../features/puzzles/memory_flip/memory_flip_screen.dart';

import '../../features/puzzles/pattern_iq/pattern_iq_screen.dart';

import '../../features/puzzles/puzzle_hub_screen.dart';

import '../../features/puzzles/puzzle_result_extra.dart';

import '../../features/puzzles/puzzle_result_screen.dart';

import '../../features/puzzles/word_snap/word_snap_screen.dart';

import '../../features/puzzles/who_am_i/who_am_i_screen.dart';

import '../../features/puzzles/science_snap/science_snap_screen.dart';

import '../../data/models/word_ladder_data.dart';
import '../../features/puzzles/word_ladder/word_ladder_difficulty_screen.dart';
import '../../features/puzzles/word_ladder/word_ladder_route_gate.dart';
import '../../features/puzzles/word_ladder/word_ladder_screen.dart';

import '../../features/puzzles/color_brain/color_brain_screen.dart';
import '../../features/puzzles/weight_balance/weight_balance_screen.dart';
import '../../features/puzzles/cup_shuffle/cup_shuffle_screen.dart';
import '../../features/puzzles/path_finder/path_finder_screen.dart';

import '../../features/legal/privacy_policy_screen.dart';
import '../../features/legal/terms_screen.dart';

import '../../features/settings/settings_screen.dart';

import '../../features/share/share_result_screen.dart';

import '../../features/splash/splash_screen.dart';

import '../../features/stats/stats_screen.dart';

import '../../features/store/store_screen.dart';

import '../../features/streak_rewards/streak_rewards_screen.dart';

import '../../shared/widgets/main_shell.dart';



abstract final class AppRoutes {

  static const login = '/login';

  static const splash = '/splash';

  static const onboarding = '/onboarding';

  static const home = '/home';

  static const puzzles = '/puzzles';

  static const challenges = '/challenges';

  static const store = '/store';

  static const profile = '/profile';

  static const practice = '/practice';

  static const blitz = '/blitz';

  static const arena = '/arena';

  static const arenaRoundResult = '/arena/round-result';

  static const settings = '/settings';

  static const privacyPolicy = '/privacy-policy';

  static const terms = '/terms';

  static const leaderboard = '/leaderboard';

  static const arenaStore = '/arena-store';

  static const streakRewards = '/streak-rewards';

  static const puzzleMath = '/puzzle/math';

  static const puzzleMemory = '/puzzle/memory';

  static const puzzlePattern = '/puzzle/pattern';

  static const puzzleWord = '/puzzle/word';

  static const puzzleFocus = '/puzzle/focus';

  static const puzzleWhoAmI = '/puzzle/who_am_i';

  static const puzzleScienceSnap = '/puzzle/science_snap';

  static const puzzleWordLadder = '/puzzle/word_ladder';
  static const puzzleWordLadderPlay = '/puzzle/word_ladder/play';

  static const puzzleColorBrain = '/puzzle/color_brain';
  static const puzzleCupShuffle = '/puzzle/cup_shuffle';
  static const puzzleWeightBalance = '/puzzle/weight_balance';
  static const puzzlePathFinder = '/puzzle/path_finder';

  static const puzzleResult = '/puzzle/result';

  static const dailyResult = '/daily-result';

  static const share = '/share';

  static const stats = '/stats';

  static const currencyShop = '/currency-shop';

}



String? _postSplashRoute(GameState gameState) {

  final player = gameState.save.player;

  if (!player.onboardingComplete) return AppRoutes.onboarding;

  return AppRoutes.home;

}



final appRouterProvider = Provider<GoRouter>((ref) {

  final gameState = ref.read(gameStateProvider);



  return GoRouter(

    initialLocation: AppRoutes.splash,

    refreshListenable: gameState,

    redirect: (context, state) {

      final loc = state.matchedLocation;
      final user = FirebaseAuth.instance.currentUser;
      final isLoggedIn = user != null;

      // Agar game state load nahi hua toh sirf splash allow karo
      if (!gameState.isLoaded) {
        return loc == AppRoutes.splash ? null : AppRoutes.splash;
      }

      // Agar logged in nahi hai, toh login screen, terms, ya privacy policy allow karo
      if (!isLoggedIn) {
        if (loc == AppRoutes.login || loc == AppRoutes.terms || loc == AppRoutes.privacyPolicy) {
          return null;
        }
        return AppRoutes.login;
      }

      // Agar logged in hai aur splash/login par hai, toh aage bhejo
      if (loc == AppRoutes.splash || loc == AppRoutes.login) {
        return _postSplashRoute(gameState);
      }

      final player = gameState.save.player;
      if (!player.onboardingComplete && loc != AppRoutes.onboarding) {
        return AppRoutes.onboarding;
      }

      return null;

    },

    routes: [

      GoRoute(

        path: AppRoutes.login,

        builder: (context, state) => const LoginScreen(),

      ),

      GoRoute(

        path: AppRoutes.splash,

        builder: (context, state) => const SplashScreen(),

      ),

      GoRoute(

        path: AppRoutes.onboarding,

        builder: (context, state) => const OnboardingScreen(),

      ),

      GoRoute(

        path: AppRoutes.dailyResult,

        builder: (context, state) => const DailyResultScreen(),

      ),

      GoRoute(

        path: AppRoutes.share,

        builder: (context, state) => const ShareResultScreen(),

      ),

      GoRoute(

        path: AppRoutes.stats,

        builder: (context, state) => const StatsScreen(),

      ),

      GoRoute(

        path: AppRoutes.currencyShop,

        builder: (context, state) => const CurrencyShopScreen(),

      ),

      GoRoute(

        path: AppRoutes.practice,

        builder: (context, state) => const PracticeModeScreen(),

      ),

      GoRoute(

        path: AppRoutes.blitz,

        builder: (context, state) => const BlitzModeScreen(),

      ),

      GoRoute(

        path: AppRoutes.arena,

        builder: (context, state) => const ArenaModeScreen(),

      ),

      GoRoute(

        path: AppRoutes.arenaRoundResult,

        builder: (context, state) {
          final extra = state.extra;
          if (extra is! ArenaRoundResultExtra) {
            return const ArenaModeScreen();
          }
          return ArenaRoundResultScreen(extra: extra);
        },

      ),

      GoRoute(

        path: AppRoutes.settings,

        builder: (context, state) => const SettingsScreen(),

      ),

      GoRoute(

        path: AppRoutes.privacyPolicy,

        builder: (context, state) => const PrivacyPolicyScreen(),

      ),

      GoRoute(

        path: AppRoutes.terms,

        builder: (context, state) => const TermsScreen(),

      ),

      GoRoute(

        path: AppRoutes.leaderboard,

        builder: (context, state) => const LeaderboardScreen(),

      ),

      GoRoute(

        path: AppRoutes.arenaStore,

        builder: (context, state) => const ArenaStoreScreen(),

      ),

      GoRoute(

        path: AppRoutes.streakRewards,

        builder: (context, state) => const StreakRewardsScreen(),

      ),

      GoRoute(

        path: AppRoutes.puzzleResult,

        builder: (context, state) {

          final extra = state.extra;

          if (extra is! PuzzleResultExtra) {

            return const PuzzleHubScreen();

          }

          return PuzzleResultScreen(extra: extra);

        },

      ),

      GoRoute(

        path: AppRoutes.puzzleMath,

        builder: (context, state) => const MathBlitzScreen(),

      ),

      GoRoute(

        path: AppRoutes.puzzleMemory,

        builder: (context, state) => const MemoryFlipScreen(),

      ),

      GoRoute(

        path: AppRoutes.puzzlePattern,

        builder: (context, state) => const PatternIqScreen(),

      ),

      GoRoute(

        path: AppRoutes.puzzleWord,

        builder: (context, state) => const WordSnapScreen(),

      ),

      GoRoute(

        path: AppRoutes.puzzleFocus,

        builder: (context, state) => const FocusFindScreen(),

      ),

      GoRoute(

        path: AppRoutes.puzzleWhoAmI,

        builder: (context, state) => const WhoAmIScreen(),

      ),

      GoRoute(

        path: AppRoutes.puzzleScienceSnap,

        builder: (context, state) => const ScienceSnapScreen(),

      ),

      GoRoute(

        path: AppRoutes.puzzleWordLadder,

        builder: (context, state) => const WordLadderRouteGate(),

      ),

      GoRoute(

        path: AppRoutes.puzzleWordLadderPlay,

        builder: (context, state) {
          final difficulty = state.extra as WordLadderDifficulty?;
          if (difficulty == null) {
            return const WordLadderDifficultyScreen();
          }
          return WordLadderScreen(difficulty: difficulty);
        },

      ),

      GoRoute(
        path: AppRoutes.puzzleColorBrain,
        builder: (context, state) => const ColorBrainScreen(),
      ),

      GoRoute(
        path: AppRoutes.puzzleCupShuffle,
        builder: (context, state) => const CupShuffleScreen(),
      ),

      GoRoute(
        path: AppRoutes.puzzleWeightBalance,
        builder: (context, state) => const WeightBalanceScreen(),
      ),

      GoRoute(
        path: AppRoutes.puzzlePathFinder,
        builder: (context, state) => const PathFinderScreen(),
      ),

      StatefulShellRoute.indexedStack(

        builder: (context, state, navigationShell) =>

            MainShell(navigationShell: navigationShell),

        branches: [

          StatefulShellBranch(

            routes: [

              GoRoute(

                path: AppRoutes.home,

                builder: (context, state) => const HomeScreen(),

              ),

            ],

          ),

          StatefulShellBranch(

            routes: [

              GoRoute(

                path: AppRoutes.puzzles,

                builder: (context, state) => const PuzzleHubScreen(),

              ),

            ],

          ),

          StatefulShellBranch(

            routes: [

              GoRoute(

                path: AppRoutes.challenges,

                builder: (context, state) => const ChallengesScreen(),

              ),

            ],

          ),

          StatefulShellBranch(

            routes: [

              GoRoute(

                path: AppRoutes.store,

                builder: (context, state) => const StoreScreen(),

              ),

            ],

          ),

          StatefulShellBranch(

            routes: [

              GoRoute(

                path: AppRoutes.profile,

                builder: (context, state) => const ProfileScreen(),

              ),

            ],

          ),

        ],

      ),

    ],

  );

});

