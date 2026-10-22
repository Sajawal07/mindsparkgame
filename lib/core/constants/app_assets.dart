/// Image and audio paths. Folder names match [assets/images] on disk.
abstract final class AppAssets {
  static const String _img = 'assets/images';
  static const String _audio = 'assets/audio';

  // App icon & splash
  static const String appIcon = '$_img/app_icon/App Icon.png';
  static const String splashLogo = '$_img/app_icon/Splash Screen Logo.png';
  static const String customLoader =
      '$_img/app_icon/Custom Loader Indicator.json';

  // Onboarding
  static const String onboardingSlide1 = '$_img/onboarding/Onboarding Slide 1.png';
  static const String onboardingSlide2 = '$_img/onboarding/Onboarding Slide 2.png';
  static const String onboardingSlide3 = '$_img/onboarding/Onboarding Slide 3.png';

  // Mode icons
  static const String iconDaily = '$_img/mode_icons/Daily Mode Icon.png';
  static const String iconPractice = '$_img/mode_icons/Practice Mode Icon.png';
  static const String iconBlitz = '$_img/mode_icons/Blitz Mode Icon.png';
  static const String iconArena = '$_img/mode_icons/Arena Mode Icon.png';

  // Home / mode portals
  static const String portalDaily = '$_img/home_screen assets/Daily Mode Portal Door.png';
  static const String portalPractice =
      '$_img/home_screen assets/Practice Mode Portal Door.png';
  static const String portalBlitz =
      '$_img/home_screen assets/Blitz Mode Portal Door.png';
  static const String portalArena =
      '$_img/home_screen assets/Arena Mode Portal Door.png';
  static const String streakFlame =
      '$_img/home_screen assets/Streak Flame Icon.png';
  static const String emptyState =
      '$_img/home_screen assets/Empty State Illustration.png';

  // Game selection zigzag (practice / daily)
  static const String gameSelectionBackground = '$_img/new/background.png';
  static const String islandMathBlitz = '$_img/new/maths blitz.png';
  static const String islandMemoryFlip = '$_img/new/memory flip.png';
  static const String islandPatternIq = '$_img/new/pattern iq.png';
  static const String islandWordSnap = '$_img/new/word snap.png';
  static const String islandFocusFind = '$_img/new/focus mind.png';
  static const String islandWhoAmI = '$_img/new/who am i.png';
  static const String islandScienceSnap = '$_img/new/science snap.png';
  static const String islandWordLadder = '$_img/new/word ladder.png';

  // Practice mode
  static const String practiceBackground =
      '$_img/practice_mode/Practice Mode Background.png';
  static const String practiceTrophy =
      '$_img/practice_mode/Personal Best Trophy.png';

  // Blitz mode (folder spelled "biltz_mode" on disk)
  static const String blitzBackground =
      '$_img/biltz_mode/Blitz Mode Background.png';
  static const String blitzMascot = '$_img/biltz_mode/Biltz Mode moscot.png';
  static const String blitzMultiplierX1 = '$_img/biltz_mode/x1.png';
  static const String blitzMultiplierX2 = '$_img/biltz_mode/x2.png';
  static const String blitzMultiplierX3 = '$_img/biltz_mode/3.png';
  static const String blitzMultiplierX5 = '$_img/biltz_mode/5.png';

  // Arena mode
  static const String arenaBackground =
      '$_img/arena_mode/Arena Mode Background.png';
  static const String arenaVictory =
      '$_img/arena_mode/Arena Victory Illustration.png';
  static const String arenaDefeat =
      '$_img/arena_mode/Arena Defeat Illustration.png';
  static const String arenaPointsBadge =
      '$_img/arena_mode/Arena Points Badge.png';

  // Puzzle hub icons
  static const String mathBlitzIcon =
      '$_img/puzzle_hub_icons/Math Blitz Icon.png';
  static const String memoryFlipIcon =
      '$_img/puzzle_hub_icons/Memory Flip Icon.png';
  static const String patternIqIcon =
      '$_img/puzzle_hub_icons/Pattern IQ Icon.png';
  static const String wordSnapIcon =
      '$_img/puzzle_hub_icons/Word Snap Icon.png';
  static const String focusFindIcon =
      '$_img/puzzle_hub_icons/Focus Find Icon.png';
  static const String whoAmIIcon = '$_img/who_am_i/Aristotle.png';
  static const String scienceSnapIcon = '$_img/science_snap/ELEM_FE.png';
  static const String wordLadderIcon =
      '$_img/puzzle_hub_icons/word ladder.png';

  // IQ rank illustrations
  static const String iqBeyondEinstein =
      '$_img/famous_mind_illustrations/Einstein Illustration.png';
  static const String iqEinstein =
      '$_img/famous_mind_illustrations/Einstein Illustration.png';
  static const String iqDaVinci =
      '$_img/famous_mind_illustrations/Da Vinci Illustration.png';
  static const String iqNewton =
      '$_img/famous_mind_illustrations/Newton Illustration.png';
  static const String iqScholar =
      '$_img/famous_mind_illustrations/Scholar Level Illustration.png';
  static const String iqAverage =
      '$_img/famous_mind_illustrations/Average Thinker Illustration.png';
  static const String iqWarmingUp =
      '$_img/famous_mind_illustrations/Just Warming Up Illustration.png';

  // Memory flip
  static const String cardBack = '$_img/memoryflip_card/Card Back Design.png';
  static const String cardFaceSet =
      '$_img/memoryflip_card/Card Face Symbols Set.png';

  // Celebrations
  static const String dailyCompleteCelebration =
      '$_img/celebrations/Daily Complete Celebration.png';
  static const String levelUpIllustration =
      '$_img/celebrations/Level Up Illustration.png';

  // Achievements
  static const String badgeEinsteinMoment =
      '$_img/acheivements/einstein moment badge.png';
  static const String badgeLegendaryCrown =
      '$_img/acheivements/Legendary Crown Badge (Level 30).png';
  static const String badgeMonthMind =
      '$_img/acheivements/Month Mind Badge.png';
  static const String badgePerfectWeek =
      '$_img/acheivements/Perfect Week Badge.png';
  static const String badgeWeekWarrior =
      '$_img/acheivements/Week Warrior Badge Icogn.png';

  // Share card
  static const String shareCardBackground =
      '$_img/share_result_card_background/Share Card Background.png';

  // Currency
  static const String mainCoinCurrency =
      '$_img/currency/Main Coin Currency Symbol.png';
  static const String arenaPointsCurrency =
      '$_img/currency/Arena Points Currency Symbol.png';

  // Store theme previews
  static const String themeDarkGalaxy =
      '$_img/store_screen_theme/Dark Galaxy Theme Preview.png';
  static const String themeNatureZen =
      '$_img/store_screen_theme/Nature Zen Theme Preview.png';
  static const String themeNeonCity =
      '$_img/store_screen_theme/Neon City Theme Preview.png';
  static const String themeRetroArcade =
      '$_img/store_screen_theme/Retro Arcade Theme Preview.png';
  static const String themeGoldenLuxury =
      '$_img/store_screen_theme/Golden Luxury.png';
  static const String themeOceanDeep = '$_img/store_screen_theme/Ocean Deep.png';
  static const String themeAncientWisdom =
      '$_img/store_screen_theme/Ancient Wisdom.png';
  static const String themeEquationStorm =
      '$_img/store_screen_theme/Equation Storm.png';
  static const String themeNeuronNetwork =
      '$_img/store_screen_theme/Neuron Network.png';
  static const String themePeriodicTable =
      '$_img/store_screen_theme/Periodic Table.png';

  // Stats
  static const String emptyStats = '$_img/stats/Empty Stats Illustration.png';

  // Audio — SFX
  static const String sfxCorrect = '$_audio/correct answer.mp3';
  static const String sfxWrong = '$_audio/Wrong answer.mp3';
  static const String sfxPuzzleComplete = '$_audio/Puzzle_complete.mp3';
  static const String sfxDailyComplete = '$_audio/game_level_complete.mp3';
  static const String sfxCoin = '$_audio/coin_rewards.mp3';
  static const String sfxLevelUp = '$_audio/Achievement_unlock.mp3';
  static const String sfxAchievement = '$_audio/Achievement.mp3';
  static const String sfxButton = '$_audio/Button_click.mp3';
  static const String sfxPageChange = '$_audio/Button_click.mp3';
  static const String sfxCardShuffle = '$_audio/shuffle_cards.mp3';
  static const String sfxCardFlip = '$_audio/Card_flip.mp3';
  static const String sfxBlitzTick = '$_audio/3_second_countdown.mp3';
  static const String sfxBlitzMultiplier = '$_audio/Biltz_multiplier_increase.mp3';
  static const String sfxArenaVictory = '$_audio/arena_victory.mp3';
  static const String sfxArenaDefeat = '$_audio/Arena_defeat.mp3';
  static const String sfxStreakReward = '$_audio/Streak_reward.mp3';
  static const String sfxSoftTap = '$_audio/soft tap.mp3';
  static const String sfxWhoosh = '$_audio/whoosh.mp3';
}
