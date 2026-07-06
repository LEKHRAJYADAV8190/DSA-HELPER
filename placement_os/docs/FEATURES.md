# Features

Complete feature reference for **Lekhraj v2.0.0+1**. Every item below exists in the codebase unless marked **Partial** or **Stub**.

---

## Core product

| Feature | Description | Primary location |
|---------|-------------|------------------|
| Striver A2Z sheet | 474 problems across topics, bundled JSON | `assets/data/striver_a2z.json` |
| Offline storage | All progress local via Hive | `lib/data/datasources/hive_service.dart` |
| Dark Material 3 UI | Fixed dark theme | `lib/core/theme/app_theme.dart` |
| No account required | No auth, no network dependency for core flows | — |

---

## Home dashboard

| Feature | Description | Location |
|---------|-------------|----------|
| Streak counter | Consecutive active days | `SettingsRepository.recordActivity()` |
| Solved progress | `solved / total` + percentage ring | `statsProvider`, `home_screen.dart` |
| Today's tasks | Four sections on one screen | `home_screen.dart` |
| Motivational quote | Random from 20 quotes | `assets/quotes/quotes.json` |
| Revision queue summary | Completed vs remaining in sequential queue | `revisionQueueStateProvider` |
| Quick navigation | Chips to Sheet, Revision, Patterns, Notes | `home_screen.dart` |

---

## Daily tasks (Home)

### New questions

| Feature | Description | Location |
|---------|-------------|----------|
| Daily batch | Next N unsolved problems in sheet order (default N=3) | `DailyNewQuestionsService` |
| Checkbox complete | Marks solved + increments daily count | `DailyTaskService.toggleNewQuestion()` |
| Checkbox undo | Untick reverses solved state and count | Same |
| Strikethrough UI | Completed items stay visible with line-through | `_ProblemTaskRow` in `home_screen.dart` |
| Persisted task rows | Hive `TaskEntity` with `TaskType.newQuestion` | `daily_task_service.dart` |

### Revision

| Feature | Description | Location |
|---------|-------------|----------|
| Daily batch | Next N from sequential solved queue (default N=3) | `SmartRevisionService` |
| Checkbox toggle | Complete / undo revision for batch item | `DailyTaskService.toggleRevision()` |
| Strikethrough UI | Same as new questions | `home_screen.dart` |

### Star revision

| Feature | Description | Location |
|---------|-------------|----------|
| Daily batch | N starred problems in rotation (default N=2) | `StarRevisionService` |
| Checkbox toggle | Complete / undo star revision | `DailyTaskService.toggleStarRevision()` |
| Strikethrough UI | Same pattern | `home_screen.dart` |

### User tasks

| Feature | Description | Location |
|---------|-------------|----------|
| Add task | Free-text daily task | `TaskRepository.addUserTask()` |
| Edit / delete | Dialog edit, delete button | `home_screen.dart` |
| Checkbox | Toggle with optimistic UI | `_UserTaskRow` |
| Strikethrough | Completed tasks visually marked | `_UserTaskRow` |

### Daily sync

| Feature | Description | Location |
|---------|-------------|----------|
| Midnight rollover | New day resets counters, rebuilds auto tasks | `DailyTaskService.syncForToday()` |
| Partial restore | Recreates missing task types if data lost | `_ensureTodayAutoTasks()` |

**Configurable limits (Settings):** `dailyNewQuestions`, `revisionsPerDay`, `dailyStarRevision` (each 1–10).

---

## DSA Sheet

| Feature | Description | Location |
|---------|-------------|----------|
| Topic accordion | Expandable topics with progress | `dsa_sheet_screen.dart` |
| Status icons | Solved, starred, notes, revision due | `problem_status.dart` |
| Filters | All, Starred, Solved, Unsolved, Has Notes, Rev. Due | `ProblemFilter` enum |
| Pattern filter | Dropdown of patterns | `dsa_sheet_screen.dart` |
| Difficulty filter | Easy / Medium / Hard | `dsa_sheet_screen.dart` |
| Inline toggles | Solve and star from list | `dsa_sheet_screen.dart` |
| Problem detail navigation | Tap row → `/problem/:id` | `dsa_sheet_screen.dart` |

---

## Revision screen

| Feature | Description | Location |
|---------|-------------|----------|
| Sequential queue | Shows current batch from solved-order queue | `revision_screen.dart` |
| Animated cards | Card UI for active revision | `revision_screen.dart` |
| Completion state | Message when daily batch done | `revision_screen.dart` |
| Queue preview | Next 20 problems in queue | `revision_screen.dart` |
| Tomorrow preview | Next day's batch after completion | `revision_screen.dart` |
| Pattern filter chip | Filter revision queue by pattern | `revision_screen.dart` |

---

## Problem detail

| Feature | Description | Location |
|---------|-------------|----------|
| Solved toggle | Mark problem solved/unsolved | `problem_detail_screen.dart` |
| Star toggle | Star/unstar | Same |
| Notes star | Star important notes | Same |
| Markdown notes editor | Multi-section template | `note_template.dart` |
| Auto-save | 600ms debounced save | `problem_detail_screen.dart` |
| Delete notes + undo | Single-slot undo buffer | `ProblemRepository` |
| Confidence slider | 1–5 scale on revision complete | `problem_detail_screen.dart` |
| Revision history | List of past revisions with confidence | `problem_detail_screen.dart` |
| Mark revision done | When problem is in today's revision batch | `problem_detail_screen.dart` |

### Note template sections

Pattern · Core Idea · Algorithm · Pseudo Code · Time Complexity · Space Complexity · Mistakes I Made · Important Edge Cases · Interview Tricks · Revision Summary · Confidence

---

## Search

| Feature | Description | Location |
|---------|-------------|----------|
| Text search | Name, topic, notes, patterns, difficulty | `ProblemRepository.queryProblems()` |
| Filter chips | Same filters as DSA sheet | `search_screen.dart` |
| Topic / pattern dropdowns | Narrow results | `search_screen.dart` |

---

## Patterns

| Feature | Description | Location |
|---------|-------------|----------|
| Pattern list | All patterns with stats | `patterns_screen.dart` |
| Stats per pattern | Total, solved, remaining, progress % | `PatternStats` |
| Pattern detail | Problems filtered by pattern | `PatternDetailScreen` |
| Quick pattern revision | Set active pattern filter + go to Revision | `patterns_screen.dart` |

Patterns originate from `patterns[]` on each problem in JSON (enriched via `tool/enrich_patterns.py`).

---

## Notes

### Problem notes tab

| Feature | Description | Location |
|---------|-------------|----------|
| List all noted problems | With markdown preview | `notes_screen.dart` |
| Sort | By topic, recently updated, starred | `NotesSort` enum |
| Search | Filter note list | `notes_screen.dart` |

### Yaad Rakhna (short notes) tab

| Feature | Description | Location |
|---------|-------------|----------|
| Add short note | Optional topic + free text | `ShortNotesRepository` |
| Edit / delete | Dialog + confirm delete | `notes_screen.dart` |
| Hive persistence | `short_notes` box | `hive_service.dart` |
| PDF inclusion | Exported under "Mistakes & Yaad Rakhna" | `pdf_export_service.dart` |

---

## Dry Run

| Feature | Description | Location |
|---------|-------------|----------|
| Whiteboard canvas | Full-area finger drawing | `dry_run_screen.dart` |
| Pen sizes | 2, 3, 5 px stroke width | `dry_run_screen.dart` |
| Eraser | Wide stroke using canvas color | Same |
| Undo | Remove last stroke | Same |
| Clear | Wipe entire board | Same |
| Session only | **Not persisted** to Hive | — |

---

## Settings & data

| Feature | Description | Location |
|---------|-------------|----------|
| Statistics panel | Solved, streak, revision stats, notes count | `settings_screen.dart` |
| Daily limits | Sliders/steppers for 3 task types | `settings_screen.dart` |
| Notification times | Morning + evening hour/minute | `settings_screen.dart` |
| Export PDF | Problem notes + short notes | `pdf_export_service.dart` |
| Backup JSON | Share full app data export | `ProblemRepository.exportData()` |
| Restore JSON | File picker import | `ProblemRepository.importData()` |
| Reset progress | Clears solved/notes/tasks/history | `settings_screen.dart` |

---

## Notifications

| Feature | Description | Location |
|---------|-------------|----------|
| Ongoing tasks | Persistent notification with pending tasks | `notification_service.dart` |
| Morning reminder | Daily scheduled notification | Same |
| Evening reminder | Daily scheduled notification | Same |
| Timezone | Asia/Kolkata | `notification_service.dart` |

---

## Partial / stub / not implemented

| Item | Status | Notes |
|------|--------|-------|
| Firebase / Firestore sync | **Not implemented** | Old README mentioned it; no code |
| Dark mode toggle | **Stub** | Switch exists; `onChanged` is no-op |
| `fl_chart` charts | **Unused** | Dependency only |
| Workmanager jobs | **Stub** | Initialized, no tasks registered |
| `showEveningRevisionPending()` | **Unused** | Defined, never called |
| `reorderUserTasks()` | **Unused** | No drag-and-drop UI |
| Dry Run persistence | **Not implemented** | By design (session canvas) |
| iOS / Web builds | **Not verified** | Android-focused development |
| Production signing | **Incomplete** | Release uses debug keystore |

---

## Developer tools

| Tool | Purpose |
|------|---------|
| `tool/enrich_patterns.py` | Batch-add pattern tags to `striver_a2z.json` |
| `flutter analyze` | Static analysis |
| `flutter test` | Unit tests (minimal today) |

---

## Data export schema (backup JSON)

Exported via Settings → Backup Data:

- `problems` — serialized problem state
- `tasks` — all task entities
- `settings` — user settings map
- `revisionHistory` — revision records
- `shortNotes` — Yaad Rakhna entries

Import replaces tasks, revision history, short notes; merges problems and settings.
