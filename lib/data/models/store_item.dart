import '../../core/constants/app_assets.dart';

enum StoreCategory { theme, frame, powerUp, title, victoryFlair, avatar }
enum CurrencyType { coins, arenaPoints }

class StoreItem {
  const StoreItem({
    required this.id,
    required this.category,
    required this.name,
    required this.cost,
    required this.description,
    this.currencyType = CurrencyType.coins,
    this.assetPath,
    this.unlockRequirement,
    this.maxStock,
  });

  final String id;
  final StoreCategory category;
  final String name;
  final int cost;
  final String description;
  final CurrencyType currencyType;
  final String? assetPath;
  final String? unlockRequirement;
  final int? maxStock;
}

abstract final class StoreCatalog {
  static const defaultThemeId = 'theme_default';
  static const defaultAvatarId = 'avatar_classic_brain';

  /// Main Store only — paid with coins.
  static List<StoreItem> get mainStoreItems => [
    ...themes,
    ...frames,
    ...powerUps,
    ...titles,
    ...avatars,
  ];

  /// Arena Store only — paid with Arena Points.
  static List<StoreItem> get arenaStoreItems => [
    ...arenaThemes,
    ...arenaFrames,
    ...arenaTitles,
    ...arenaVictoryFlairs,
    ...arenaAvatars,
  ];

  static List<StoreItem> get all => [
    ...mainStoreItems,
    ...arenaStoreItems,
  ];

  // ─── THEMES ────────────────────────────────────────────────────────────────

  static const themes = [
    StoreItem(
      id: StoreCatalog.defaultThemeId,
      category: StoreCategory.theme,
      name: 'Default',
      cost: 0,
      description: 'The standard MindSpark look',
    ),
    StoreItem(
      id: 'theme_dark_galaxy',
      category: StoreCategory.theme,
      name: 'Dark Galaxy',
      cost: 500,
      description: 'Deep space background with star effects',
      assetPath: AppAssets.themeDarkGalaxy,
    ),
    StoreItem(
      id: 'theme_neon_city',
      category: StoreCategory.theme,
      name: 'Neon City',
      cost: 500,
      description: 'Cyberpunk neon aesthetic',
      assetPath: AppAssets.themeNeonCity,
    ),
    StoreItem(
      id: 'theme_nature_zen',
      category: StoreCategory.theme,
      name: 'Nature Zen',
      cost: 400,
      description: 'Calm green forest look',
      assetPath: AppAssets.themeNatureZen,
    ),
    StoreItem(
      id: 'theme_retro_arcade',
      category: StoreCategory.theme,
      name: 'Retro Arcade',
      cost: 600,
      description: '8-bit pixel art style',
      assetPath: AppAssets.themeRetroArcade,
    ),
    StoreItem(
      id: 'theme_golden_luxury',
      category: StoreCategory.theme,
      name: 'Golden Luxury',
      cost: 800,
      description: 'Premium gold and black theme',
      assetPath: AppAssets.themeGoldenLuxury,
    ),
    StoreItem(
      id: 'theme_ocean_deep',
      category: StoreCategory.theme,
      name: 'Ocean Deep',
      cost: 500,
      description: 'Underwater blue aesthetic',
      assetPath: AppAssets.themeOceanDeep,
    ),
    StoreItem(
      id: 'theme_ancient_wisdom',
      category: StoreCategory.theme,
      name: 'Ancient Wisdom',
      cost: 550,
      description: 'Scrolls, gold, and timeless knowledge',
      assetPath: AppAssets.themeAncientWisdom,
    ),
    StoreItem(
      id: 'theme_equation_storm',
      category: StoreCategory.theme,
      name: 'Equation Storm',
      cost: 600,
      description: 'Swirling formulas and electric focus',
      assetPath: AppAssets.themeEquationStorm,
    ),
    StoreItem(
      id: 'theme_neuron_network',
      category: StoreCategory.theme,
      name: 'Neuron Network',
      cost: 650,
      description: 'Glowing synapses and brain energy',
      assetPath: AppAssets.themeNeuronNetwork,
    ),
    StoreItem(
      id: 'theme_periodic_table',
      category: StoreCategory.theme,
      name: 'Periodic Table',
      cost: 500,
      description: 'Chemistry-inspired lab aesthetic',
      assetPath: AppAssets.themePeriodicTable,
    ),
  ];

  // ─── FRAMES ────────────────────────────────────────────────────────────────

  static const frames = [
    StoreItem(
      id: 'frame_lightning',
      category: StoreCategory.frame,
      name: 'Lightning Frame',
      cost: 300,
      description: 'Electric border for your avatar',
      assetPath: 'assets/images/store_assets/main_store/frames/Lightning Frame.png',
    ),
    StoreItem(
      id: 'frame_einstein_halo',
      category: StoreCategory.frame,
      name: 'Einstein Halo',
      cost: 550,
      description: 'Reach Einstein rank once to unlock',
      unlockRequirement: 'einstein_rank',
      assetPath: 'assets/images/store_assets/main_store/frames/Einstein Halo.png',
    ),
    StoreItem(
      id: 'frame_fire_streak',
      category: StoreCategory.frame,
      name: 'Fire Streak Frame',
      cost: 500,
      description: '14-day streak required',
      unlockRequirement: 'streak_14',
      assetPath: 'assets/images/store_assets/main_store/frames/Fire Streak Frame.png',
    ),
    StoreItem(
      id: 'frame_diamond',
      category: StoreCategory.frame,
      name: 'Diamond Frame',
      cost: 600,
      description: 'Available from Level 15',
      unlockRequirement: 'level_15',
      assetPath: 'assets/images/store_assets/main_store/frames/Diamond Frame.png',
    ),
    StoreItem(
      id: 'frame_legendary_crown',
      category: StoreCategory.frame,
      name: 'Legendary Crown',
      cost: 1000,
      description: 'Level 25+ only',
      unlockRequirement: 'level_25',
      assetPath:
          'assets/images/store_assets/main_store/frames/Legendary Crown Frame (1).png',
    ),
    StoreItem(
      id: 'frame_star_burst',
      category: StoreCategory.frame,
      name: 'Star Burst Frame',
      cost: 250,
      description: 'Sparkling star border',
      assetPath: 'assets/images/store_assets/main_store/frames/Star Burst Frame.png',
    ),
  ];

  // ─── POWER-UPS ─────────────────────────────────────────────────────────────

  static const powerUps = [
    StoreItem(
      id: 'powerup_extra_hint',
      category: StoreCategory.powerUp,
      name: 'Extra Hint',
      cost: 100,
      description: 'Reveal first letter in Word Snap',
      maxStock: 5,
      assetPath: 'assets/images/store_assets/main_store/power_ups/Extra Hint Icon.png',
    ),
    StoreItem(
      id: 'powerup_time_freeze',
      category: StoreCategory.powerUp,
      name: 'Time Freeze',
      cost: 150,
      description: 'Freeze timer for 5 seconds',
      maxStock: 3,
      assetPath:
          'assets/images/store_assets/main_store/power_ups/Time Freeze Icon.png',
    ),
    StoreItem(
      id: 'powerup_score_shield',
      category: StoreCategory.powerUp,
      name: 'Score Shield',
      cost: 120,
      description: 'Ignore one wrong answer penalty',
      maxStock: 3,
      assetPath:
          'assets/images/store_assets/main_store/power_ups/Score Shield Icon.png',
    ),
    StoreItem(
      id: 'powerup_streak_shield',
      category: StoreCategory.powerUp,
      name: 'Streak Shield',
      cost: 300,
      description: 'Protect streak for one missed day',
      maxStock: 2,
      assetPath:
          'assets/images/store_assets/main_store/power_ups/Streak Shield Icon.png',
    ),
    StoreItem(
      id: 'powerup_double_xp',
      category: StoreCategory.powerUp,
      name: 'Double XP 24h',
      cost: 200,
      description: '2× XP for 24 hours',
      maxStock: 3,
      assetPath:
          'assets/images/store_assets/main_store/power_ups/Double XP Icon.png',
    ),
    StoreItem(
      id: 'powerup_coin_booster',
      category: StoreCategory.powerUp,
      name: 'Coin Booster 24h',
      cost: 250,
      description: '1.5× coins for 24 hours',
      maxStock: 3,
      assetPath:
          'assets/images/store_assets/main_store/power_ups/Coin Booster Icon.png',
    ),
    StoreItem(
      id: 'powerup_whoami_clue',
      category: StoreCategory.powerUp,
      name: 'Extra Clue',
      cost: 50,
      description: 'Reveal one extra clue in Who Am I',
      maxStock: 10,
      assetPath:
      'assets/images/store_assets/main_store/power_ups/clue.png',
    ),
    StoreItem(
      id: 'powerup_whoami_clue_pack',
      category: StoreCategory.powerUp,
      name: 'Clue Pack (x3)',
      cost: 120,
      description: 'Get 3 extra clues for Who Am I',
      maxStock: 5,
      assetPath:
      'assets/images/store_assets/main_store/power_ups/clue.png',
    ),
    StoreItem(
      id: 'powerup_whoami_clue_chest',
      category: StoreCategory.powerUp,
      name: 'Clue Chest (x10)',
      cost: 350,
      description: 'Get 10 extra clues for Who Am I',
      maxStock: 3,
      assetPath:
      'assets/images/store_assets/main_store/power_ups/clue.png',
    ),
    StoreItem(
      id: 'powerup_genius_pass',
      category: StoreCategory.powerUp,
      name: 'Genius Pass',
      cost: 1500,
      description: 'Permanent: First clue is always free in Who Am I',
      maxStock: 1, // Only buy once
      assetPath:
      'assets/images/store_assets/main_store/power_ups/genious clue.png',
    ),
  ];

  // ─── TITLES ────────────────────────────────────────────────────────────────

  static final List<StoreItem> titles = [
    const StoreItem(
      id: 'title_mathematician',
      category: StoreCategory.title,
      name: 'The Mathematician',
      cost: 400,
      description: 'Score 140+ on Math Blitz 20 times',
      unlockRequirement: 'math_140_x20',
      assetPath:
          'assets/images/store_assets/main_store/title_badge/The Mathematician Title Badge.png',
    ),
    const StoreItem(
      id: 'title_memory_master',
      category: StoreCategory.title,
      name: 'Memory Master',
      cost: 400,
      description: '50 perfect Memory Flip games',
      unlockRequirement: 'memory_perfect_x50',
      assetPath:
          'assets/images/store_assets/main_store/title_badge/Memory Master Title Badge.png',
    ),
    const StoreItem(
      id: 'title_pattern_seeker',
      category: StoreCategory.title,
      name: 'Pattern Seeker',
      cost: 400,
      description: 'Perfect Pattern IQ 30 times',
      unlockRequirement: 'pattern_perfect_x30',
      assetPath:
          'assets/images/store_assets/main_store/title_badge/Pattern Seeker Title Badge.png',
    ),
    const StoreItem(
      id: 'title_word_wizard',
      category: StoreCategory.title,
      name: 'Word Wizard',
      cost: 400,
      description: 'All 6 words correct 30 times',
      unlockRequirement: 'word_perfect_x30',
      assetPath:
          'assets/images/store_assets/main_store/title_badge/Word Wizard Title Badge.png',
    ),
    const StoreItem(
      id: 'title_eagle',
      category: StoreCategory.title,
      name: 'The Eagle',
      cost: 400,
      description: 'Focus Find with no errors 25 times',
      unlockRequirement: 'focus_perfect_x25',
      assetPath:
          'assets/images/store_assets/main_store/title_badge/The Eagle Title Badge.png',
    ),
    const StoreItem(
      id: 'title_daily_champion',
      category: StoreCategory.title,
      name: 'Daily Champion',
      cost: 600,
      description: 'Complete daily challenges 50 times',
      unlockRequirement: 'daily_challenges_x50',
      assetPath:
          'assets/images/store_assets/main_store/title_badge/Daily Champion Title Badge.png',
    ),
    const StoreItem(
      id: 'title_streak_god',
      category: StoreCategory.title,
      name: 'Streak God',
      cost: 1000,
      description: 'Reach a 100-day streak',
      unlockRequirement: 'streak_100',
      assetPath:
          'assets/images/store_assets/main_store/title_badge/Streak God Title Badge.png',
    ),
  ];

  // ─── AVATARS (COINS) ───────────────────────────────────────────────────────

  static const avatars = [
    // Classic (free starter + paid)
    StoreItem(
      id: StoreCatalog.defaultAvatarId,
      category: StoreCategory.avatar,
      name: 'Classic Brain',
      cost: 0,
      description: 'Your default MindSpark brain',
      assetPath: 'assets/images/avatars/classic/Classic Brain.png',
    ),
    StoreItem(
      id: 'avatar_cool_brain',
      category: StoreCategory.avatar,
      name: 'Cool Brain',
      cost: 150,
      description: 'Keepin\' it cool',
      assetPath: 'assets/images/avatars/classic/Cool Brain.png',
    ),
    StoreItem(
      id: 'avatar_focused_brain',
      category: StoreCategory.avatar,
      name: 'Focused Brain',
      cost: 150,
      description: 'Eyes on the prize',
      assetPath: 'assets/images/avatars/classic/Fouced Brain.png',
    ),
    StoreItem(
      id: 'avatar_sleepy_brain',
      category: StoreCategory.avatar,
      name: 'Sleepy Brain',
      cost: 150,
      description: 'Still smarter than most',
      assetPath: 'assets/images/avatars/classic/Sleepy Brain.png',
    ),
    // Coin Store
    StoreItem(
      id: 'avatar_space_cadet',
      category: StoreCategory.avatar,
      name: 'Space Cadet',
      cost: 300,
      description: 'Shooting for the stars',
      assetPath: 'assets/images/avatars/coin store/Space Cadet.png',
    ),
    StoreItem(
      id: 'avatar_the_hacker',
      category: StoreCategory.avatar,
      name: 'The Hacker',
      cost: 350,
      description: 'Found the cheat codes',
      assetPath: 'assets/images/avatars/coin store/The Hacker.png',
    ),
    StoreItem(
      id: 'avatar_the_inventor',
      category: StoreCategory.avatar,
      name: 'The Inventor',
      cost: 350,
      description: 'Building something brilliant',
      assetPath: 'assets/images/avatars/coin store/The Inventor.png',
    ),
    StoreItem(
      id: 'avatar_the_sage',
      category: StoreCategory.avatar,
      name: 'The Sage',
      cost: 400,
      description: 'Ancient wisdom, modern mind',
      assetPath: 'assets/images/avatars/coin store/The Sage.png',
    ),
    // Funny Characters
    StoreItem(
      id: 'avatar_confused_professor',
      category: StoreCategory.avatar,
      name: 'Confused Professor',
      cost: 200,
      description: 'Brilliant but bewildered',
      assetPath: 'assets/images/avatars/funny characters/Confused Professor.png',
    ),
    StoreItem(
      id: 'avatar_copy_cat',
      category: StoreCategory.avatar,
      name: 'Copy Cat',
      cost: 200,
      description: 'Borrowing your answers',
      assetPath: 'assets/images/avatars/funny characters/Copy Cat.png',
    ),
    StoreItem(
      id: 'avatar_exam_survivor',
      category: StoreCategory.avatar,
      name: 'Exam Survivor',
      cost: 250,
      description: 'Made it through by a thread',
      assetPath: 'assets/images/avatars/funny characters/Exam Survivor.png',
    ),
    StoreItem(
      id: 'avatar_last_minute_larry',
      category: StoreCategory.avatar,
      name: 'Last Minute Larry',
      cost: 200,
      description: 'Always cutting it close',
      assetPath: 'assets/images/avatars/funny characters/Last Minute Larry.png',
    ),
    StoreItem(
      id: 'avatar_the_bluffer',
      category: StoreCategory.avatar,
      name: 'The Bluffer',
      cost: 250,
      description: 'Confidence is half the battle',
      assetPath: 'assets/images/avatars/funny characters/The Bluffer.png',
    ),
    StoreItem(
      id: 'avatar_know_it_all',
      category: StoreCategory.avatar,
      name: 'The Know It All',
      cost: 300,
      description: 'Probably right though',
      assetPath: 'assets/images/avatars/funny characters/The Know It All.png',
    ),
    StoreItem(
      id: 'avatar_nap_king',
      category: StoreCategory.avatar,
      name: 'The Nap King',
      cost: 200,
      description: 'Dreams of correct answers',
      assetPath: 'assets/images/avatars/funny characters/The Nap King.png',
    ),
    StoreItem(
      id: 'avatar_overthinker',
      category: StoreCategory.avatar,
      name: 'The Overthinker',
      cost: 250,
      description: 'But what does it really mean?',
      assetPath: 'assets/images/avatars/funny characters/The Overthinker.png',
    ),
    // Level Characters
    StoreItem(
      id: 'avatar_the_rookie',
      category: StoreCategory.avatar,
      name: 'The Rookie',
      cost: 0,
      description: 'Just getting started',
      assetPath: 'assets/images/avatars/level characters/The Rookie.png',
    ),
    StoreItem(
      id: 'avatar_the_analyst',
      category: StoreCategory.avatar,
      name: 'The Analyst',
      cost: 300,
      description: 'Numbers never lie',
      unlockRequirement: 'level_5',
      assetPath: 'assets/images/avatars/level characters/The Analyst.png',
    ),
    StoreItem(
      id: 'avatar_the_prodigy',
      category: StoreCategory.avatar,
      name: 'The Prodigy',
      cost: 400,
      description: 'Gifted beyond measure',
      unlockRequirement: 'level_10',
      assetPath: 'assets/images/avatars/level characters/The Prodigy.png',
    ),
    StoreItem(
      id: 'avatar_the_strategist',
      category: StoreCategory.avatar,
      name: 'The Strategist',
      cost: 500,
      description: 'Three steps ahead',
      unlockRequirement: 'level_15',
      assetPath: 'assets/images/avatars/level characters/The Strategist.png',
    ),
    StoreItem(
      id: 'avatar_the_mastermind',
      category: StoreCategory.avatar,
      name: 'The Mastermind',
      cost: 800,
      description: 'Elite-level brilliance',
      unlockRequirement: 'level_20',
      assetPath: 'assets/images/avatars/level characters/The Mastermind.png',
    ),
    // Scientists
    StoreItem(
      id: 'avatar_aristotle',
      category: StoreCategory.avatar,
      name: 'Aristotle',
      cost: 500,
      description: 'Father of logic',
      assetPath: 'assets/images/avatars/scientists/Aristotle Avatar.png',
    ),
    StoreItem(
      id: 'avatar_curie',
      category: StoreCategory.avatar,
      name: 'Marie Curie',
      cost: 500,
      description: 'Pioneer of radioactivity',
      assetPath: 'assets/images/avatars/scientists/Curie Avatar.png',
    ),
    StoreItem(
      id: 'avatar_da_vinci',
      category: StoreCategory.avatar,
      name: 'Da Vinci',
      cost: 600,
      description: 'Renaissance genius',
      unlockRequirement: 'level_10',
      assetPath: 'assets/images/avatars/scientists/Da Vinci Avatar.png',
    ),
    StoreItem(
      id: 'avatar_darwin',
      category: StoreCategory.avatar,
      name: 'Darwin',
      cost: 600,
      description: 'Survival of the fittest mind',
      assetPath: 'assets/images/avatars/scientists/Darwin Avatar.png',
    ),
    StoreItem(
      id: 'avatar_einstein',
      category: StoreCategory.avatar,
      name: 'Einstein',
      cost: 800,
      description: 'Reach Einstein rank to unlock',
      unlockRequirement: 'einstein_rank',
      assetPath: 'assets/images/avatars/scientists/Einstein Avatar.png',
    ),
    StoreItem(
      id: 'avatar_hawking',
      category: StoreCategory.avatar,
      name: 'Stephen Hawking',
      cost: 700,
      description: 'Beyond the event horizon',
      unlockRequirement: 'level_15',
      assetPath: 'assets/images/avatars/scientists/Hawking Avatar.png',
    ),
    StoreItem(
      id: 'avatar_newton',
      category: StoreCategory.avatar,
      name: 'Newton',
      cost: 700,
      description: 'An apple fell, a mind ignited',
      unlockRequirement: 'level_10',
      assetPath: 'assets/images/avatars/scientists/Newton Avatar.png',
    ),
    StoreItem(
      id: 'avatar_tesla',
      category: StoreCategory.avatar,
      name: 'Tesla',
      cost: 700,
      description: 'Electric dreams, electric mind',
      unlockRequirement: 'level_12',
      assetPath: 'assets/images/avatars/scientists/Tesla Avatar.png',
    ),
    // Streak Characters
    StoreItem(
      id: 'avatar_habit_hero',
      category: StoreCategory.avatar,
      name: 'Habit Hero',
      cost: 500,
      description: 'Requires 7-day streak',
      unlockRequirement: 'streak_7',
      assetPath: 'assets/images/avatars/streak characters/Habit Hero.png',
    ),
    StoreItem(
      id: 'avatar_the_consistent_one',
      category: StoreCategory.avatar,
      name: 'The Consistent One',
      cost: 700,
      description: 'Requires 14-day streak',
      unlockRequirement: 'streak_14',
      assetPath: 'assets/images/avatars/streak characters/The Consistent One.png',
    ),
    StoreItem(
      id: 'avatar_iron_will',
      category: StoreCategory.avatar,
      name: 'Iron Will',
      cost: 900,
      description: 'Requires 30-day streak',
      unlockRequirement: 'streak_30',
      assetPath: 'assets/images/avatars/streak characters/Iron Will.png',
    ),
    StoreItem(
      id: 'avatar_the_unstoppable',
      category: StoreCategory.avatar,
      name: 'The Unstoppable',
      cost: 1000,
      description: 'Requires 60-day streak',
      unlockRequirement: 'streak_60',
      assetPath: 'assets/images/avatars/streak characters/The Unstopable.png',
    ),
    StoreItem(
      id: 'avatar_eternal_scholar',
      category: StoreCategory.avatar,
      name: 'Eternal Scholar',
      cost: 1200,
      description: 'Requires 100-day streak',
      unlockRequirement: 'streak_100',
      assetPath: 'assets/images/avatars/streak characters/Eternal Scholar.png',
    ),
  ];

  // ─── ARENA STORE ITEMS ─────────────────────────────────────────────────────

  static const arenaThemes = [
    StoreItem(
      id: 'arena_theme_gladiator',
      category: StoreCategory.theme,
      name: 'Gladiator Arena Theme',
      cost: 800,
      currencyType: CurrencyType.arenaPoints,
      description: 'Exclusive arena battle theme',
      assetPath: 'assets/images/store_assets/arena_store/theme/Gladiator Arena Theme.png',
    ),
    StoreItem(
      id: 'arena_theme_blood_moon',
      category: StoreCategory.theme,
      name: 'Blood Moon Theme',
      cost: 1000,
      currencyType: CurrencyType.arenaPoints,
      description: 'Intense blood moon battle setting',
      assetPath: 'assets/images/store_assets/arena_store/theme/Blood Moon Theme.png',
    ),
    StoreItem(
      id: 'arena_theme_battle_of_minds',
      category: StoreCategory.theme,
      name: 'Battle of Minds',
      cost: 900,
      currencyType: CurrencyType.arenaPoints,
      description: 'Clash of intellects on the arena floor',
      assetPath:
          'assets/images/store_assets/arena_store/theme/Battle of Minds.png',
    ),
    StoreItem(
      id: 'arena_theme_lightning_theorem',
      category: StoreCategory.theme,
      name: 'Lightning Theorem',
      cost: 850,
      currencyType: CurrencyType.arenaPoints,
      description: 'Strike fast with charged logic',
      assetPath:
          'assets/images/store_assets/arena_store/theme/Lightning Theorem.png',
    ),
    StoreItem(
      id: 'arena_theme_war_of_scholars',
      category: StoreCategory.theme,
      name: 'War of Scholars',
      cost: 950,
      currencyType: CurrencyType.arenaPoints,
      description: 'Epic scholarly rivalry backdrop',
      assetPath:
          'assets/images/store_assets/arena_store/theme/War of Scholars.png',
    ),
  ];

  static const arenaFrames = [
    StoreItem(
      id: 'arena_frame_bronze',
      category: StoreCategory.frame,
      name: 'Bronze Arena Frame',
      cost: 200,
      currencyType: CurrencyType.arenaPoints,
      description: 'Show your arena participation',
      assetPath: 'assets/images/store_assets/arena_store/frames/Bronze Arena Frame.png',
    ),
    StoreItem(
      id: 'arena_frame_silver',
      category: StoreCategory.frame,
      name: 'Silver Arena Frame',
      cost: 400,
      currencyType: CurrencyType.arenaPoints,
      description: 'Silver tier arena frame',
      assetPath: 'assets/images/store_assets/arena_store/frames/Silver Arena Frame.png',
    ),
    StoreItem(
      id: 'arena_frame_gold',
      category: StoreCategory.frame,
      name: 'Gold Arena Frame',
      cost: 700,
      currencyType: CurrencyType.arenaPoints,
      description: 'Gold tier arena frame',
      assetPath: 'assets/images/store_assets/arena_store/frames/Gold Arena Frame.png',
    ),
    StoreItem(
      id: 'arena_frame_gladiator',
      category: StoreCategory.frame,
      name: 'Gladiator Frame',
      cost: 1000,
      currencyType: CurrencyType.arenaPoints,
      description: 'Ultimate arena champion frame',
      assetPath:
          'assets/images/store_assets/arena_store/frames/Gladiator Frame - Legendary.png',
    ),
  ];

  static const arenaTitles = [
    StoreItem(
      id: 'arena_title_warrior',
      category: StoreCategory.title,
      name: 'Arena Warrior',
      cost: 250,
      currencyType: CurrencyType.arenaPoints,
      description: 'Brave arena fighter',
      assetPath:
          'assets/images/store_assets/arena_store/title_badge/Arena Warrior Title Badge.png',
    ),
    StoreItem(
      id: 'arena_title_mind_gladiator',
      category: StoreCategory.title,
      name: 'Mind Gladiator',
      cost: 500,
      currencyType: CurrencyType.arenaPoints,
      description: 'Master of the mind battles',
      assetPath:
          'assets/images/store_assets/arena_store/title_badge/Mind Gladiator Title Badge.png',
    ),
    StoreItem(
      id: 'arena_title_brain_champion',
      category: StoreCategory.title,
      name: 'Brain Champion',
      cost: 800,
      currencyType: CurrencyType.arenaPoints,
      description: 'Champion of the arena',
      assetPath:
          'assets/images/store_assets/arena_store/title_badge/Brain Champion Title Badge.png',
    ),
    StoreItem(
      id: 'arena_title_undefeated',
      category: StoreCategory.title,
      name: 'The Undefeated',
      cost: 1500,
      currencyType: CurrencyType.arenaPoints,
      unlockRequirement: 'arena_wins_50',
      description: 'Requires 50 arena wins',
      assetPath:
      'assets/images/store_assets/arena_store/title_badge/The Undefeated.png',
    ),
  ];

  static const arenaVictoryFlairs = [
    StoreItem(
      id: 'flair_training_boost',
      category: StoreCategory.victoryFlair,
      name: 'Training Boost Flair',
      cost: 200,
      currencyType: CurrencyType.arenaPoints,
      description: 'Procedural purple energy burst',
    ),
    StoreItem(
      id: 'flair_fire_storm',
      category: StoreCategory.victoryFlair,
      name: 'Fire Storm Flair',
      cost: 400,
      currencyType: CurrencyType.arenaPoints,
      description: 'Explosive procedural flame animation',
    ),
    StoreItem(
      id: 'flair_lightning_strike',
      category: StoreCategory.victoryFlair,
      name: 'Lightning Strike Flair',
      cost: 400,
      currencyType: CurrencyType.arenaPoints,
      description: 'Branching procedural electric strikes',
    ),
    StoreItem(
      id: 'flair_confetti_cannon',
      category: StoreCategory.victoryFlair,
      name: 'Confetti Cannon Flair',
      cost: 350,
      currencyType: CurrencyType.arenaPoints,
      description: 'High-performance 3D party confetti burst',
    ),
    StoreItem(
      id: 'flair_galaxy_burst',
      category: StoreCategory.victoryFlair,
      name: 'Galaxy Burst Flair',
      cost: 600,
      currencyType: CurrencyType.arenaPoints,
      description: 'Swirling procedural cosmic galaxy burst',
    ),
  ];

  // ─── ARENA AVATARS (AP) ────────────────────────────────────────────────────

  static const arenaAvatars = [
    StoreItem(
      id: 'avatar_gladiator_scholar',
      category: StoreCategory.avatar,
      name: 'Gladiator Scholar',
      cost: 600,
      currencyType: CurrencyType.arenaPoints,
      description: 'Warrior of the mind arena',
      assetPath: 'assets/images/avatars/arena/Gladiator Scholar.png',
    ),
    StoreItem(
      id: 'avatar_arena_legend',
      category: StoreCategory.avatar,
      name: 'Arena Legend',
      cost: 800,
      currencyType: CurrencyType.arenaPoints,
      description: 'Legendary status unlocked',
      assetPath: 'assets/images/avatars/arena/Arena Legend.png',
    ),
    StoreItem(
      id: 'avatar_war_commander',
      category: StoreCategory.avatar,
      name: 'War Commander',
      cost: 1000,
      currencyType: CurrencyType.arenaPoints,
      unlockRequirement: 'arena_wins_50',
      description: 'Requires 50 arena wins',
      assetPath: 'assets/images/avatars/arena/War Commander.png',
    ),
  ];

  // ─── LOOKUP ────────────────────────────────────────────────────────────────

  static StoreItem? byId(String id) {
    for (final item in all) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// Arena-folder avatars — Arena Store only, paid with AP.
  static const arenaAvatarIds = {
    'avatar_gladiator_scholar',
    'avatar_arena_legend',
    'avatar_war_commander',
  };

  static bool isArenaAvatar(String itemId) => arenaAvatarIds.contains(itemId);

  /// True for any item that belongs exclusively to the Arena Store.
  static bool isArenaExclusive(String itemId) {
    for (final item in arenaStoreItems) {
      if (item.id == itemId) return true;
    }
    return false;
  }

  static bool isMainStoreItem(String itemId) {
    for (final item in mainStoreItems) {
      if (item.id == itemId) return true;
    }
    return false;
  }
}
