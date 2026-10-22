# MindSpark — Daily Brain Challenge

Flutter brain-training game based on `prd.md`. Offline-first daily puzzles, Brain Score, IQ ranks, coins, and progression.

## Run

```bash
flutter pub get
flutter run
```

## Development phases (from PRD)

| Phase | Status | Scope |
|-------|--------|--------|
| 1 — Foundation | Done | Theme, Hive, routing, splash, onboarding |
| 2 — Core services | Done | Player/session models, save/load, streak check |
| 3 — Home & hub | Done | Dashboard, puzzle hub, bottom nav |
| 4–8 — Puzzles | Done | All 5 daily puzzles playable |
| 9 — Brain Score | Done | Weighted score, IQ rank, daily result screen |
| 10 — Store | Done | Themes, frames, power-ups, titles — buy/equip |
| 11 — Challenges | Done | Daily, weekly, lifetime + claim rewards |
| 12 — Stats | Done | Brain score chart, bests, today breakdown |
| 13 — Share card | Done | Share image + 25 coins/day reward |
| 10+ | Planned | Store, challenges, stats, share, notifications |

## Assets

Images live under `assets/images/` with paths mapped in `lib/core/constants/app_assets.dart`.

## Project structure

```
lib/
  core/          theme, router, constants
  data/          models, Hive storage, Riverpod providers
  features/      screens per app area
  shared/        reusable widgets
```
