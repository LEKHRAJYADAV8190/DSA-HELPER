# Roadmap

Planned improvements and known gaps for **Lekhraj**. Items are prioritized for reliability, portfolio quality, and user value—not feature bloat.

**Legend:** ✅ Done · 🚧 In progress · 📋 Planned · 💡 Idea

---

## v2.0.x — Stability & polish (near term)

| Priority | Item | Status | Notes |
|----------|------|--------|-------|
| P0 | Per-type daily task restore on app open | ✅ | Fixed partial restore when only star tasks existed |
| P0 | Home checkbox strikethrough + untick | ✅ | New / Revision / Star / User tasks |
| P1 | Real unit tests for revision engine | 📋 | Replace placeholder in `test/revision_engine_test.dart` |
| P1 | Real unit tests for `DailyTaskService` | 📋 | sync, toggle, ensure auto tasks |
| P1 | CI workflow (`flutter analyze` + `test`) | 📋 | GitHub Actions on PR |
| P2 | Remove unused `fl_chart` dependency | 📋 | Or implement stats charts in Settings |
| P2 | Wire or remove dark mode toggle | 📋 | Currently no-op in Settings |
| P2 | Production release signing docs | 📋 | Document keystore setup; do not commit keys |
| P2 | README screenshots in `docs/assets/` | 📋 | See [SCREENSHOTS.md](SCREENSHOTS.md) |

---

## v2.1 — Quality of life

| Item | Status | Description |
|------|--------|-------------|
| Dry Run persistence | 💡 | Optional save/load boards per problem |
| Dry Run export | 💡 | Share board as PNG |
| User task reorder | 💡 | UI for `reorderUserTasks()` |
| Undo/redo on Dry Run | 💡 | Multi-level undo stack |
| Problem external links | 💡 | Link to Striver / LC URL if added to JSON |
| Confidence on Home revision toggle | 💡 | Optional quick confidence picker |
| Evening pending notification | 💡 | Call `showEveningRevisionPending()` when tasks remain |

---

## v2.2 — Testing & accessibility

| Item | Status | Description |
|------|--------|-------------|
| Widget tests — Home tasks | 📋 | Checkbox, strikethrough, counts |
| Widget tests — Problem notes | 📋 | Auto-save behavior |
| Integration test — seed + open sheet | 📋 | End-to-end smoke |
| Semantics / screen reader | 📋 | Labels on task checkboxes |
| Tablet layout | 💡 | Wider Dry Run + split notes view |

---

## v3.0 — Platform & data (major)

| Item | Status | Description |
|------|--------|-------------|
| Optional cloud backup | 💡 | Opt-in encrypted backup (not in v2 codebase) |
| iOS build verification | 💡 | Test and document iOS host |
| Multiple roadmaps UI | 💡 | `RoadmapDataSource` already extensible |
| Spaced repetition mode | 💡 | Alternative to pure sequential queue |
| Widget / home screen widget | 💡 | Today's task count on launcher |

---

## Explicit non-goals (for now)

These are intentionally out of scope unless requirements change:

- Social features, leaderboards, or accounts
- In-app problem execution / code compiler
- Replacing Striver sheet order with random daily picks
- Heavy analytics or tracking SDKs
- Monetization / ads

---

## Known gaps (honest backlog)

Tracked from code review—see also [FEATURES.md](FEATURES.md):

1. **No cloud sync** — Hive-only; backup is manual JSON export.
2. **Minimal tests** — Not representative of revision/daily task complexity.
3. **Workmanager stub** — Background sync not implemented.
4. **`RevisionConfig.intervalDays`** — Dead constant; revision is queue-index based.
5. **Release signing** — Debug keystore in release Gradle config.

---

## How to propose roadmap items

Open a GitHub issue with:

- Problem statement
- Who benefits (daily user, contributor, recruiter reviewing code)
- Whether it fits offline-first design
- Rough implementation area (`domain/services/…`, `presentation/…`)

Maintainers will triage into this document.

---

## Version targets (tentative)

| Version | Focus | Target |
|---------|-------|--------|
| 2.0.x | Bug fixes, docs, task UI | Current |
| 2.1.x | Dry Run persistence, QoL | Q3 2026 |
| 2.2.x | Tests, CI, a11y | Q4 2026 |
| 3.0.x | Optional sync, multi-platform | 2027 |

Dates are indicative—not commitments.
