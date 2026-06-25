# 🏆 World Cup Watch

> **"Which match should I watch?"** — A Flutter app that ranks every 2026 FIFA World Cup match by how exciting it's likely to be, using a custom five-factor Hype Score algorithm.

Built as a portfolio project for the 2026 FIFA World Cup. Android only.

---

## The Problem It Solves

With 104 matches across 39 days, casual fans don't know which games are worth setting an alarm for. World Cup Watch calculates a **Hype Score** for every match and surfaces the most compelling fixtures first — so you never accidentally skip Argentina vs Brazil to watch Panama vs New Zealand.

---

## Features

- **Hype Score ranking** — every match scored 0–10 and sorted by watchability
- **Hype reason tags** — up to 3 human-readable explanations per match (e.g. *"2022 WC Rematch"*, *"Both Top 5 Favorites"*, *"Must-Win Game"*)
- **Live match filters** — Today / Upcoming / Finished / All Matches
- **Match details screen** — score, scorers, stadium info, group standings
- **Tournament bracket** — pannable, pinch-to-zoom canvas showing the full knockout tree
- **Stale-while-revalidate caching** — app shows cached data instantly on cold start, refreshes in background
- **Graceful degradation** — TBD knockout slots show "Winner Match 74"-style labels until teams qualify

---

## Video Demo

<video width="480" height="720" controls>
    <source src="https://github.com/user-attachments/assets/0096cc85-6d71-4c33-a026-adfd70a407c7" type="video/mp4">
</video>

---

## Hype Score Algorithm

The core of the app. A weighted sum of five independent factors, each scored 0–10:

| Factor | Weight | What it measures |
|---|---|---|
| **Stage Bonus** | 25% | Knockout rounds score higher; Final = 10.0 |
| **Group Stakes** | 30% | How desperate each team is for points (matchday + current points) |
| **Team Quality** | 20% | Average FIFA ranking of both teams |
| **Rivalry** | 15% | Historical intensity between the two nations |
| **Goal Threat** | 10% | Average goals scored per game in the tournament so far |

**Static data sources:**
- `fifa_rankings.dart` — NBC Sports power rankings (June 11, 2026), all 48 teams, ranks 1–48
- `rivalries.dart` — hand-curated rivalry scores (0–10) for every possible group-stage pairing + major cross-group knockout rivalries
- `hype_reasons.dart` — hardcoded narrative tags for iconic matchups (e.g. BRA vs MAR → *"2022 WC Quarterfinal Rematch"*)

These are intentionally static constants rather than fetched data — rivalry history doesn't change mid-tournament.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Android target) |
| State management | `flutter_bloc` — Cubit pattern |
| HTTP client | `dio` with retry logic (3 attempts, fails fast on no-internet) |
| Dependency injection | `get_it` + `injectable` (code-generated) |
| Image caching | `cached_network_image` |
| On-disk cache | `path_provider` + raw JSON files |
| Date formatting | `intl` |
| API | `worldcup26.ir` (JWT auth, long-lived token) |

---

## Architecture

MVVM — each layer has one job:

```
API (worldcup26.ir)
    ↓
MatchesRepositoryImpl       ← Dio calls, retry logic, disk cache read/write
    ↓
MatchesRepository (abstract) ← contract; keeps Cubit testable
    ↓
MatchesCubit                ← business logic, filter state, hype score assembly
    ↓
MatchCard (view model)      ← pre-computed fields the UI reads directly
    ↓
Widgets                     ← zero logic; render only
```

Navigation uses `Navigator.push` with arguments. No named routes. No Router.

`MatchDetailsCubit` is the only second Cubit — it's created fresh per navigation push (via `BlocProvider` in the route builder) and is responsible only for fetching the stadium for that specific match. Groups and teams are passed in from `MatchesCubit`'s cached fields — no re-fetch.

---

## Folder Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart       # base URL, endpoints, JWT token
│   │   ├── fifa_rankings.dart       # static team strength ranks (1–48)
│   │   ├── rivalries.dart           # static rivalry scores per matchup
│   │   └── hype_reasons.dart        # human-readable hype tags + match narratives
│   ├── di/
│   │   ├── di.dart                  # GetIt setup + @InjectableInit
│   │   └── di.config.dart           # GENERATED — do not edit by hand
│   ├── error/
│   │   └── error_message_helper.dart
│   ├── network/
│   │   ├── dio_client.dart          # singleton Dio with auth interceptor
│   │   └── result_api.dart          # SuccessApi<T> / ErrorApi<T> sealed classes
│   ├── theme/
│   │   ├── app_colors.dart          # full semantic color palette
│   │   └── app_fonts.dart           # named TextStyle constants
│   └── utils/
│       ├── hype_score_calculator.dart   # pure Dart, no Flutter deps, fully testable
│       ├── scorers_json_normalizer.dart # cleans malformed scorer JSON from API
│       └── validator.dart
│
└── features/
    ├── app_section/
    │   ├── app_section.dart         # root StatefulWidget, IndexedStack shell
    │   └── bottom_nav_bar.dart
    │
    ├── matches/
    │   ├── data/
    │   │   ├── models/
    │   │   │   ├── match_model.dart     # Match + homeTeamLabel/awayTeamLabel
    │   │   │   ├── group_model.dart     # Groups + GroupTeamStanding
    │   │   │   ├── team_model.dart
    │   │   │   └── stadium_model.dart
    │   │   └── repo/
    │   │       ├── matches_repo.dart         # abstract contract
    │   │       └── matches_repo_impl.dart    # disk cache + retry + Dio calls
    │   └── presentation/
    │       ├── cubit/
    │       │   ├── matches_cubit.dart        # main cubit; stale-while-revalidate
    │       │   ├── matches_state.dart        # MatchesLoaded / Loading / Error
    │       │   ├── match_card.dart           # view model (not a widget)
    │       │   ├── match_details_cubit.dart  # stadium fetch only
    │       │   └── match_details_state.dart
    │       ├── screens/
    │       │   ├── matches_screen.dart
    │       │   └── match_details_screen.dart
    │       └── widgets/
    │           ├── matches_screen_widgets/
    │           │   ├── hype_match_card.dart
    │           │   ├── match_date_selector.dart
    │           │   ├── top_app_bar.dart
    │           │   ├── updating_indicator.dart
    │           │   └── refresh_failed_banner.dart
    │           └── match_details_widgets/
    │               ├── score_hero.dart
    │               ├── team_column.dart
    │               ├── stadium_card.dart
    │               ├── group_standings.dart
    │               ├── state_badge.dart
    │               └── details_app_bar.dart
    │
    ├── settings/
    │   └── presentation/
    │       └── settings_screen.dart   # placeholder
    │
    └── tournment/
        └── presentation/
            ├── bracket_screen.dart        # InteractiveViewer canvas
            ├── bracket_match_card.dart    # compact card for bracket nodes
            └── bracket_painter.dart       # CustomPainter for connector lines
```

---

## Unusual / Non-obvious Decisions

**Stale-while-revalidate without a package**
The app checks for on-disk JSON cache on startup. Cache hit → emit loaded state immediately with `isRefreshing: true`, fire network refresh in the background with `unawaited()`. No loading spinner on second open. Background failure shows a dismissible banner without wiping the screen.

**HypeScoreCalculator is pure Dart**
Zero Flutter dependencies. No Dio, no Cubit, no BuildContext. Takes a `MatchHypeInput` value object, returns a `HypeResult`. This was intentional — it makes the algorithm trivially unit-testable and keeps business logic out of both the repository and the widget layer.

**`MatchCard` is a view model, not a widget**
`lib/features/matches/presentation/cubit/match_card.dart` is a plain Dart class that pre-computes everything the UI needs (`isToday`, `hypeScore`, `reasons`, `homeFlag`, etc.). Widgets read flat properties — no nested object access, no logic in `build()`.

**Bracket layout uses fixed slots, not card stacking**
The tournament bracket canvas uses a slot-based layout where total canvas height is fixed at `32 slots × 112px`. R32 cards each get one slot; R16 cards each get two slots (224px); QF cards get four slots; etc. This makes the bracket "open up" visually as rounds progress and ensures all five columns (R32 → Final) are reachable by panning, without any column being taller than the others.

**Rivalry and ranking data are hardcoded constants**
`fifa_rankings.dart` and `rivalries.dart` contain ~200 lines of static `const` maps. The alternative — fetching live FIFA rankings — would add API complexity, a new endpoint, and a new failure mode, for data that doesn't change during a tournament. Static constants are the right tradeoff here.

**Scorer JSON is malformed from the API**
The API returns scorer data using curly braces instead of square brackets (`{"Mbappe 45'"}` instead of `["Mbappe 45'"]`) and uses non-standard quote characters. `scorers_json_normalizer.dart` patches these before parsing.

**`isToday` uses a ±20 hour UTC window**
The API's `local_date` field reflects the venue's local timezone, not UTC. A robust IANA timezone lookup would require a package and per-stadium timezone data. The interim fix: a match is "today" if it's within 20 hours of now in UTC. This covers the widest possible timezone gap between venues across the US and Canada.

---

## Known Limitations

- `isToday` timezone detection is approximate (±20hr UTC window) — see note above
- Bracket cards are not tappable (no navigation to match details from bracket nodes)
- JWT token is hardcoded in `api_constants.dart` — in production this would live in secure storage
- Android only — no iOS build configuration

---

## Setup

```bash
flutter pub get
dart run build_runner build   # regenerates di.config.dart
flutter run
```

