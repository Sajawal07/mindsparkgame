MindSpark
Daily Brain Challenge
Game Design Document | Version 1.0
Field Details
Platform Android (Flutter — Dart)
Genre Casual / Brain Training / Puzzle
Target Audience Ages 13+, global
Primary Language English
DISCLAIMER: IQ scores shown in this app

1. Game Overview
   1.1 Concept
   MindSpark is a free-to-play daily brain training mobile game. Every day, players complete 5
   unique mini-puzzle challenges covering math, memory, pattern recognition, word skills, and
   focus. After completing all 5 puzzles, players receive a Brain Score out of 1000 and a legendary
   IQ rank — from 'Just Warming Up' all the way to 'Beyond Einstein'.
   1.2 Core Game Loop
   Open App --> Complete 5 Daily Puzzles --> Earn Brain Score + IQ Rank --> Earn Coins
   --> Spend Coins in Store --> Share Result --> Repeat Tomorrow
   1.3 Unique Selling Points
   • 5 puzzle types in one app — variety keeps it fresh daily
   • IQ rank system with famous mind comparisons (Einstein, Da Vinci, Newton)
   • Shareable result card — organic viral growth mechanic
   • Offline first — no internet required to play
   • Coin economy — earn and spend within the game
   • 30 player levels — months of content and progression
   • 24 challenges — daily, weekly, and lifetime achievements
   MindSpark — Game Design Document v1.0
2. Level System
   2.1 Overview
   MindSpark has 30 player levels. Levels represent the player's overall mastery of brain
   challenges. Each level unlocks new content, harder difficulty tiers, new puzzle themes, and
   exclusive cosmetics in the store.
   2.2 How Players Level Up
   Players earn XP (Experience Points) by completing daily puzzles. XP is awarded based on:
   • Completing a puzzle: +50 XP
   • Accuracy bonus (above 80% correct): +20 XP
   • Speed bonus (finish in top 50% of time): +15 XP
   • Perfect score on a puzzle: +30 XP
   • Full daily session (all 5 puzzles done): +50 XP bonus
   • 7-day streak active: +25 XP per puzzle
   2.3 Level Progression Table
   Level XP Required Difficulty Tier What Unlocks
   1 - 5 0 to 2,000 XP Beginner Core 5 puzzles, default theme
   6 - 10 2,001 to 6,000 XP Easy Word Snap hard mode, new puzzle
   themes
   11 - 15 6,001 to 14,000 XP Medium Pattern IQ hard mode, streak shields in
   store
   16 - 20 14,001 to 28,000 XP Hard Focus Find expert mode, avatar frames
   in store
   21 - 25 28,001 to 50,000 XP Expert Math Blitz expert mode, exclusive title
   badges
   26 - 30 50,001 to 80,000 XP Master Memory Flip master mode, legendary
   crown, final title
   2.4 Difficulty Scaling Per Level
   Math Blitz Scaling
   MindSpark — Game Design Document v1.0
   Level Range Operations Used Number Range Time Limit
   1 - 5 Addition and Subtraction 1 to 20 30 seconds
   6 - 10 Add, Subtract, Multiply 1 to 50 25 seconds
   11 - 15 All 4 operations 1 to 100 20 seconds
   16 - 20 Multi-step equations 1 to 200 18 seconds
   21 - 25 Algebra basics (find X) 1 to 500 15 seconds
   26 - 30 Mixed complex equations 1 to 1000 12 seconds
   Memory Flip Scaling
   Level Range Grid Size Number of Cards Preview Time
   1 - 5 3 x 2 6 cards (3 pairs) 3 seconds
   6 - 10 4 x 3 12 cards (6 pairs) 2.5 seconds
   11 - 15 4 x 4 16 cards (8 pairs) 2 seconds
   16 - 20 5 x 4 20 cards (10 pairs) 1.5 seconds
   21 - 25 5 x 5 25 cards (12 pairs + 1
   wild)
   1 second
   26 - 30 6 x 5 30 cards (15 pairs) 0.5 seconds
   Pattern IQ Scaling
   Level Range Pattern Type Answer Options Complexity
   1 - 5 Shape sequences 3 choices 1 rule (color or shape)
   6 - 10 Number sequences 4 choices 1 rule (size or rotation)
   11 - 15 Mixed shape and
   number
   4 choices 2 rules combined
   16 - 20 Abstract symbols 5 choices 3 rules combined
   21 - 25 Matrix patterns (2x2) 5 choices Multi-dimensional rules
   26 - 30 Matrix patterns (3x3) 6 choices Complex multi-rule matrices
   Word Snap Scaling
   Level Range Word Length Category Time Limit
   1 - 5 3 to 4 letters Common animals, colors 20 seconds
   6 - 10 4 to 5 letters Food, places, objects 18 seconds
   MindSpark — Game Design Document v1.0
   Level Range Word Length Category Time Limit
   11 - 15 5 to 6 letters Science, nature 15 seconds
   16 - 20 6 to 7 letters Advanced vocabulary 12 seconds
   21 - 25 7 to 8 letters Complex words 10 seconds
   26 - 30 8 to 10 letters Expert vocabulary 8 seconds
   Focus Find Scaling
   Level Range Grid Size Odd Ones to
   Find
   Visual Similarity
   1 - 5 3 x 3 (9 items) 1 odd one out Clearly different
   6 - 10 4 x 4 (16 items) 1 odd one out Similar color
   11 - 15 4 x 5 (20 items) 2 odd ones out Very similar
   16 - 20 5 x 5 (25 items) 2 odd ones out Extremely similar
   21 - 25 5 x 6 (30 items) 3 odd ones out Nearly identical
   26 - 30 6 x 6 (36 items) 3 odd ones out Pixel-level differences
   MindSpark — Game Design Document v1.0
3. Brain Score & IQ Rank System
   3.1 Brain Score Calculation
   After all 5 daily puzzles are completed, the game calculates a Brain Score out of 1000:
   Component Weight Max Points How It Is Earned
   Accuracy 40% 400 pts Percentage of correct answers across all
   5 puzzles
   Speed 30% 300 pts How fast compared to the ideal
   completion time
   Consistency 20% 200 pts Active streak + completing all 5 puzzles
   today
   Difficulty Bonus 10% 100 pts Bonus for playing at higher level difficulty
   tiers
   3.2 IQ Rank Tiers
   Brain Score IQ Estimate Rank Name Famous Mind Comparison
   950 - 1000 145+ Beyond Einstein Even Einstein would take notes from you!
   850 - 949 135 - 144 Einstein Level You think like the greatest mind in history!
   750 - 849 125 - 134 Da Vinci Level A true Renaissance mind — art and science
   in one!
   650 - 749 115 - 124 Newton Level Gravity cannot hold your brain down!
   550 - 649 105 - 114 Scholar Level Sharp, focused, and always growing!
   400 - 549 90 - 104 Average Thinker A solid mind — keep training daily!
   Below 400 Below 90 Just Warming Up Your brain is just getting started — do not
   give up!
   LEGAL NOTE: All IQ estimates and famous mind comparisons are for entertainment only.
   This is NOT a clinically validated IQ assessment. This disclaimer MUST appear on the
   result screen, onboarding screen, and Play Store listing.
   3.3 Shareable Result Card
   MindSpark — Game Design Document v1.0
   After completing the daily session, players can share a result card to social media. The card
   includes:
   • MindSpark app logo and name
   • Player's Brain Score (large, bold)
   • IQ Rank badge with famous mind comparison text
   • Today's date
   • A motivational tagline
   • Play Store download link for organic growth
   The card is generated using the screenshot + share_plus Flutter packages. Sharing earns the
   player 25 coins (once per day). This is the primary organic growth mechanic.
   MindSpark — Game Design Document v1.0
4. The 5 Daily Puzzles — Detailed Design
   4.1 Puzzle 1 — Math Blitz
   Property Detail
   Objective Solve math equations as fast and accurately as possible
   Questions per session 10 questions
   Input method Multiple choice — 4 answer options per question
   Scoring 10 pts per correct answer + speed bonus up to 5 pts per question
   Max possible score 150 pts
   Time limit Varies by player level (see Section 2.4)
   Wrong answer 0 pts for that question, move to next immediately
   4.2 Puzzle 2 — Memory Flip
   Property Detail
   Objective Flip cards and find all matching pairs in fewest moves
   Scoring Base 200 pts minus 5 pts for every extra move beyond the minimum
   required
   Max possible score 200 pts
   Time limit No timer — but speed contributes to Brain Score speed component
   Preview phase Cards are briefly shown face-up at the start (duration varies by level)
   Fail condition None — player finishes when all pairs are matched
   4.3 Puzzle 3 — Pattern IQ
   Property Detail
   Objective Identify the next item in a visual pattern sequence
   Questions per session 8 questions
   Input method Multiple choice — tap the correct answer from options
   Scoring 25 pts per correct answer, 0 pts for wrong answer
   Max possible score 200 pts
   Time limit 15 seconds per question (all levels)
   MindSpark — Game Design Document v1.0
   Property Detail
   Wrong answer 0 pts for that question, next question appears
   4.4 Puzzle 4 — Word Snap
   Property Detail
   Objective Unscramble shuffled letters to spell the correct word
   Words per session 6 words
   Input method Tap letters in the correct order to spell the word
   Scoring 30 pts per correct word plus speed bonus up to 10 pts per word
   Max possible score 240 pts (with all speed bonuses)
   Time limit Per-word countdown timer (see Section 2.4 for times by level)
   Fail condition Timer runs out = 0 pts for that word, next word appears
   Hint system Player gets 1 free hint per day (reveals the first letter of the word)
   4.5 Puzzle 5 — Focus Find
   Property Detail
   Objective Tap the odd-one-out item(s) hidden in a grid of visually similar icons
   Scoring 100 pts per correct find, minus 20 pts per wrong tap
   Max possible score 300 pts (at higher levels with multiple odd ones to find)
   Time limit 45 seconds (all levels)
   Fail condition Time runs out = partial score based on how many were found
   4.6 Daily Score Summary
   Puzzle Max Score Primary Skill Tested
   Math Blitz 150 pts Numerical reasoning and calculation speed
   Memory Flip 200 pts Short-term memory and spatial recall
   Pattern IQ 200 pts Logical reasoning and pattern recognition
   Word Snap 240 pts Language ability and verbal processing
   Focus Find 300 pts Attention to detail and visual focus
   TOTAL 1,000 pts Full brain workout across 5 skill areas
   MindSpark — Game Design Document v1.0
   MindSpark — Game Design Document v1.0
5. Challenges & Achievement System
   5.1 Daily Challenges (Reset every 24 hours — 6 available)
   Challenge Name Requirement Coin Reward
   Speed Demon Complete Math Blitz in under 15
   seconds
   50 coins
   Perfect Memory Complete Memory Flip with zero wrong
   flips
   75 coins
   Pattern Master Get 8 out of 8 correct on Pattern IQ 60 coins
   Word Wizard Unscramble all 6 words correctly in
   Word Snap
   60 coins
   Eagle Eye Find all odd ones in Focus Find with
   zero wrong taps
   80 coins
   Full Session Complete all 5 puzzles today 100 coins
   5.2 Weekly Challenges (Reset every Monday — 6 available)
   Challenge Name Requirement Reward
   7-Day Warrior Maintain a 7-day streak this week 500 coins + badge
   Brain Athlete Score 800 or above for 5 days this
   week
   400 coins
   Math Champion Score 140 or above on Math Blitz 5
   times
   300 coins
   Memory King/Queen Complete Memory Flip perfectly 3
   times
   350 coins
   Vocabulary Builder Get all 6 words correct in Word Snap 3
   times
   300 coins
   The Focused Complete Focus Find with no wrong
   taps 5 times
   400 coins
   5.3 Lifetime Achievements (One-time — 12 total)
   Achievement Requirement Reward
   First Spark Complete your first daily session 100 coins
   Week Warrior Reach a 7-day streak 200 coins + badge
   MindSpark — Game Design Document v1.0
   Achievement Requirement Reward
   Month Mind Reach a 30-day streak 1,000 coins +
   badge
   Einstein Moment Score Beyond Einstein rank at least
   once
   500 coins + title
   Level 10 Reach player level 10 300 coins + new
   theme unlocked
   Level 20 Reach player level 20 600 coins + new
   theme unlocked
   Level 30 — Max Level Reach player level 30 2,000 coins +
   legendary title
   Perfect Week Score 900 or above for 7 consecutive
   days
   800 coins + badge
   Puzzle Completionist Complete 500 total puzzles 1,000 coins
   Memory Legend Complete 100 perfect Memory Flip
   games
   750 coins + badge
   Speed Legend Finish Math Blitz 10 of 10 correct in
   under 10 seconds
   500 coins + title
   Pattern Genius Score perfect on Pattern IQ 50 times 600 coins + badge
   MindSpark — Game Design Document v1.0
6. Coin Economy
   6.1 How Players Earn Coins
   Source Coins Earned Frequency
   Complete all 5 daily puzzles +100 coins Every day
   Perfect score on any single
   puzzle
   +50 coins Per puzzle, every day
   7-day streak milestone +200 coins Every 7-day milestone
   30-day streak milestone +500 coins Every 30-day milestone
   Complete a daily challenge +50 to 100 coins Up to 6 per day
   Complete a weekly challenge +300 to 500 coins Up to 6 per week
   Level up reward +150 coins per level On each level up
   Sharing result card (daily limit: 1
   share)
   +25 coins Once per day
   Lifetime achievement unlocked +100 to 2,000 coins One-time each
   6.2 The MindSpark Store — How Players Spend Coins
   Category A — Themes and Visual Packs
   Item Cost Description
   Dark Galaxy Theme 500 coins Deep space background with star particle effects
   Neon City Theme 500 coins Cyberpunk neon aesthetic for all puzzle screens
   Nature Zen Theme 400 coins Calm green forest look with relaxing sound effects
   Retro Arcade Theme 600 coins 8-bit pixel art style for all UI elements
   Golden Luxury Theme 800 coins Premium gold and black elegant theme
   Ocean Deep Theme 500 coins Underwater blue aesthetic with wave animations
   Category B — Avatar Frames
   Item Cost Requirement
   Lightning Frame 200 coins Available from start
   Einstein Halo 350 coins Must have reached Einstein rank at least once
   MindSpark — Game Design Document v1.0
   Item Cost Requirement
   Fire Streak Frame 300 coins Only available after 14-day streak achieved
   Diamond Frame 600 coins Available from Level 15
   Legendary Crown 1,000 coins Only available at Level 25 and above
   Star Burst Frame 250 coins Available from start
   Category C — Power-Ups (Consumable Items)
   Item Cost Effect Max Stock
   Extra Hint 100 coins 1 additional hint for Word Snap
   (reveals first letter)
   5
   Time Freeze 150 coins Freeze timer for 5 seconds in
   any timed puzzle
   3
   Score Shield 120 coins Protects against 1 wrong answer
   penalty per use
   3
   Streak Shield 300 coins Saves your streak if you miss 1
   day
   2
   Double XP (1 day) 200 coins 2x XP from all puzzles for 24
   hours
   3
   Coin Booster (1 day) 250 coins 1.5x coins from all sources for 24
   hours
   3
   Category D — Title Badges
   Title Cost Purchase Requirement
   The Mathematician 400 coins Score 140+ on Math Blitz 20 times total
   Memory Master 400 coins Complete 50 perfect Memory Flip games
   Pattern Seeker 400 coins Score 200 of 200 on Pattern IQ 30 times total
   Word Wizard Title 400 coins Get all 6 words correct in Word Snap 30 times
   The Eagle 400 coins Complete Focus Find without error 25 times total
   Daily Champion 600 coins Complete daily challenges 50 times total
   Streak God 1,000 coins Reach a 100-day streak
   MindSpark — Game Design Document v1.0
7. All App Screens
# Screen Name Route Primary Purpose
1 Splash Screen /splash App logo animation, loading, route check
2 Onboarding Screen /onboarding First launch only — 3 intro slides + disclaimer
3 Home Dashboard /home Main hub — score ring, streak, navigation
4 Puzzle Hub Screen /puzzles Today's 5 puzzles list and completion status
5 Math Blitz Screen /puzzle/math Math puzzle gameplay
6 Memory Flip
Screen
/puzzle/memory Card flip matching gameplay
7 Pattern IQ Screen /puzzle/pattern Pattern sequence gameplay
8 Word Snap Screen /puzzle/word Word unscramble gameplay
9 Focus Find Screen /puzzle/focus Odd one out grid gameplay
10 Puzzle Result
Screen
/result Score breakdown after each puzzle
11 Daily Result Screen /daily-result Full Brain Score + IQ rank after all 5 puzzles
12 Share Card Screen /share Preview and share result card to social media
13 Stats Screen /stats Historical scores, streaks, charts, personal bests
14 Challenges Screen /challenges Daily, weekly, and lifetime achievement tracking
15 Store Screen /store Coin shop with all 4 categories
16 Profile Screen /profile Player level, XP, equipped items, streaks
17 Settings Screen /settings Sounds, notifications, theme, disclaimer, about
18 Level Up Screen /levelup Animated level up celebration overlay
19 Achievement
Unlocked
/achievement Pop-up overlay when achievement earned
20 Streak Milestone /streak Streak milestone celebration overlay
7.1 Key Screen Details
Home Dashboard (Screen 3)
• Top bar: Player level badge, XP bar, coin count
• Center: Brain Score ring — grey if not played today, filled with today's score if done
• Streak counter with animated flame icon
MindSpark — Game Design Document v1.0
• Big 'Play Today' call-to-action button
• Bottom navigation bar: Home | Puzzles | Challenges | Store | Profile
Puzzle Hub Screen (Screen 4)
• List of 5 puzzles showing: icon, name, status (Available / Completed), and score earned
• Puzzles must be played in order — each unlocks after the previous is completed
• Daily reset countdown timer: 'Resets in: 14h 32m'
Daily Result Screen (Screen 11)
• Brain Score animated counter from 0 to final score
• IQ Rank revealed with animation and famous mind comparison
• Breakdown of each puzzle score
• Coins earned today + XP earned today
• Share Result button
• Disclaimer text (small): 'For entertainment only — not a real IQ measurement'
Store Screen (Screen 15)
• 4 tabs at top: Themes | Frames | Power-Ups | Titles
• Coin balance always shown at top right
• Each item shows: preview, name, price, and Buy / Equip / Equipped button
• Confirmation dialog before any purchase is deducted
MindSpark — Game Design Document v1.0
8. Streak System
   8.1 Rules
   • Streak increases by 1 each day the player completes all 5 puzzles
   • Missing a day resets streak to 0 (unless Streak Shield power-up is active)
   • Streak resets at midnight in the player's local time zone
   • The longest ever streak is always saved separately and never resets
   8.2 Streak Milestones
   Streak Coin Reward Bonus Unlock
   3 days 50 coins 'On a Roll!' notification badge
   7 days 200 coins Week Warrior achievement + 7-day frame available
   in store
   14 days 300 coins Fire Streak frame unlocked in store
   30 days 500 coins Month Mind achievement badge
   60 days 800 coins 60-Day Champion title available in store
   100 days 1,500 coins Streak God title available in store
   365 days 5,000 coins Annual Legend title + exclusive 365-day theme
   MindSpark — Game Design Document v1.0
9. Technical Architecture
   9.1 Tech Stack
   Layer Technology Purpose
   Framework Flutter (Dart) Cross-platform UI and all app logic
   State Management Riverpod Global state: coins, level, streak, daily session
   Local Storage Hive Save and load all game data offline
   Animations Lottie Splash, level up, confetti, streak fire
   animations
   UI Animations animate_do Screen transitions and widget entry
   animations
   Fonts Google Fonts Orbitron for display, Nunito for body text
   Notifications flutter_local_notifications Daily reminder push notifications
   Share Feature screenshot + share_plus Generate result card image and share
   Charts fl_chart Stats screen line chart and bar chart
   App Icon flutter_launcher_icons Auto-generate all icon sizes from one source
   Splash Screen flutter_native_splash Native splash screen for both platforms
   9.2 Core Data Models
   Model Key Fields
   PlayerModel level, xp, coins, streak, longestStreak, name, equippedTheme,
   equippedFrame, equippedTitle, ownedItems
   DailySessionModel date, puzzleResults (list), brainScore, iqRank, coinsEarned, xpEarned,
   isComplete
   PuzzleResultModel puzzleType, score, accuracy, timeTaken, xpEarned, isComplete
   ChallengeModel id, type (daily/weekly/lifetime), name, description, progress, target,
   rewardCoins, isComplete, isClaimed
   StoreItemModel id, category, name, cost, description, unlockRequirement, isOwned,
   isEquipped
   AchievementModel id, name, description, requirement, rewardCoins, badgeAssetPath,
   isUnlocked, unlockedDate
   9.3 Save System Rules
   MindSpark — Game Design Document v1.0
   All data is saved locally via Hive. The game MUST save after every:
   • Puzzle completed (save puzzle result and updated coins/XP)
   • Full daily session completed (save brain score and IQ rank)
   • Coin transaction — earn or spend
   • Store purchase (update owned items list)
   • Settings changed
   On every app launch, the save service must:
1. Load player data from Hive
2. Check if today's session already exists (do not duplicate)
3. Validate streak — if yesterday was missed and no shield, reset streak to 0
4. Check for any pending challenge completions not yet processed
5. Route to correct screen: Home if session done, Puzzle Hub if not
   MindSpark — Game Design Document v1.0
10. Development Roadmap — Solo Developer
    Phase Tasks Estimated Time
    Phase 1 —
    Foundation
    Flutter project setup, folder structure, theme/color
    system, Hive initialization, routing, splash + onboarding
    screen
    Phase 2 —
    Core
    Services
    PlayerModel, DailySessionModel, all data models,
    save/load service, coin service, XP and level service,
    streak validation logic
   
    Phase 3 —
    Home and
    Hub
    Home dashboard screen, puzzle hub screen, bottom
    navigation bar, coin display, streak display, XP bar
    
    Phase 4 —
    Math Blitz
    Question generator for all levels, timer widget, 4-choice
    UI, scoring logic, result screen
   
    Phase 5 —
    Memory
    Flip
    Card grid widget, flip animation, pair matching logic,
    move counter, level-based grid sizing
    
    Phase 6 —
    Pattern IQ
    Sequence generator, visual pattern widgets, multiple
    choice answer input, 15-second timer
    
    Phase 7 —
    Word Snap
    Word list per level, letter shuffle algorithm, tap-to-spell
    input UI, hint system
    
    Phase 8 —
    Focus Find
    Grid generator, odd-one-out placement logic, tap
    detection, 45-second timer
    
    Phase 9 —
    Brain Score
    Brain Score formula implementation, IQ rank
    assignment, Daily Result Screen, animated score
    counter
    
    Phase 10
    — Store
    All 4 store categories, coin deduction with confirmation,
    equip system, owned item persistence
    
    Phase 11
    —
    Challenges
    Daily and weekly challenge tracking, lifetime
    achievement detection, claim system, badge grid
    
    Phase 12
    — Stats
    fl_chart line chart and bar chart, calendar heatmap
    widget, personal best tracking
    
    Phase 13
    — Share
    Card
    Result card design, screenshot package integration,
    share_plus to WhatsApp and Instagram
    
    Phase 14
    —
    Notifications
    Daily reminder notification setup, time picker in settings,
    permission handling
    
    Phase 15
    — Polish
    Lottie animations, sound effects, theme switching, final
    UI refinement, edge case handling
    
    MindSpark — Game Design Document v1.0
    Phase Tasks Estimated Time
    Phase 16
    — Testing
    Physical device testing, streak edge cases, save/load
    stress test, Play Store asset prep
    
    Phase 17
    — Launch
    Play Store listing creation, screenshots, description,
    privacy policy, submit for review
    
    Total Estimated Timeline: 10 to 12 weeks part-time solo developer, or 6 to 8 weeks full-time.
    Build Phase 1 through 9 first — this gives you a fully playable game before adding store,
    challenges, and stats.
    MindSpark — Game Design Document v1.0
11. Post-Launch Roadmap
    Feature Target Version Description
    AdMob Integration v1.1 Banner ads on home screen, rewarded ad for 2x coin
    bonus, interstitial after daily session
    IAP — Coin Packs v1.1 Buy 500, 1000, and 2000 coin packs with real money
    IAP — Remove
    Ads
    v1.1 One-time purchase to remove all ads permanently
    Global
    Leaderboard
    v1.2 Firebase weekly top 100 leaderboard by Brain Score
    Friends System v1.2 Add friends, compare scores, send daily challenges
    New Puzzle: Speed
    Sort
    v1.2 Sort items by number, color, or size as fast as possible
    New Puzzle:
    Reaction Test
    v1.3 Tap colored targets in sequence at high speed
    Seasonal Events v1.3 Special themed modes for Ramadan, Eid, and other
    events
    Dark and Light
    Mode
    v1.1 Automatic system dark/light mode support
    Tablet Layout v1.3 Optimized layout for tablet screen sizes