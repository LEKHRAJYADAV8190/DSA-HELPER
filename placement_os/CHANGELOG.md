# Changelog

All notable changes to **Lekhraj** (`placement_os`) are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0+1] - 2026-07-06

### Added

- **Lekhraj branding** — user-facing name and tagline across app, PDF, notifications, backup
- **Daily task system** — new questions, revision, star revision, and user tasks on Home
- **Sequential revision engine** — revises solved problems in Striver sheet order (not random)
- **Star revision** — daily batch from starred problems with rotating queue
- **Patterns** — pattern list, detail view, stats, and pattern-filtered revision
- **Structured notes** — markdown template per problem (Pattern, Core Idea, Algorithm, etc.)
- **Short notes ("Yaad Rakhna")** — standalone reminders tab; included in PDF export
- **Dry Run tab** — finger-draw whiteboard with pen sizes 2/3/5, eraser, undo, clear
- **PDF export** — compact problem notes + "Mistakes & Yaad Rakhna" section
- **JSON backup/restore** — export/import progress, tasks, settings, short notes
- **Search** — full-text search with topic, pattern, and filter chips
- **Notifications** — ongoing task reminder + scheduled morning/evening revision reminders
- **Motivational quotes** on Home from `assets/quotes/quotes.json`
- **Python tool** — `tool/enrich_patterns.py` for pattern enrichment in sheet JSON

### Changed

- Home task checkboxes — tick/untick with strikethrough; items stay visible (like user tasks)
- PDF layout — single flowing document instead of one page per problem
- `TodayTasksState` — accurate Riverpod equality for real-time UI updates
- Daily auto-task restore — per-type recovery when partial task data exists

### Fixed

- Home screen empty/broken daily task sections
- PDF em-dash rendering and wasted blank pages
- New/revision tasks not appearing when star revision tasks already existed
- Startup crash guards around Hive and notification initialization

### Known limitations (v2.0.0)

- Offline only — no cloud sync in codebase
- `fl_chart` dependency declared but unused
- Dark mode toggle in Settings is non-functional (app always uses dark theme)
- Minimal test coverage (`test/revision_engine_test.dart` is placeholder-level)
- Dry Run board is session-only (not persisted)
- Release builds currently use debug signing config in `android/app/build.gradle`

---

## [1.x] - Prior iterations

Earlier internal versions included basic DSA sheet tracking under the **Placement OS** name, Hive seeding from Striver A2Z JSON, and incremental additions leading to the v2.0 daily-task and revision overhaul. Detailed history was not maintained before v2.0.0.

---

## Upcoming

See [docs/ROADMAP.md](docs/ROADMAP.md) for planned work.
