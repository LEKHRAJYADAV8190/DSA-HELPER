<p align="center">
  <strong>Lekhraj</strong><br/>
  <em>Master DSA. Never Forget Again.</em>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="MIT License"></a>
  <a href="#"><img src="https://img.shields.io/badge/Flutter-3.2%2B-02569B?logo=flutter&logoColor=white" alt="Flutter"></a>
  <a href="#"><img src="https://img.shields.io/badge/Platform-Android-green" alt="Android"></a>
  <a href="#"><img src="https://img.shields.io/badge/Storage-Hive-purple" alt="Hive"></a>
  <a href="#"><img src="https://img.shields.io/badge/Internet-Not%20Required-success" alt="Offline"></a>
</p>

<p align="center">
  An offline-first Flutter app for <strong>Striver A2Z DSA Sheet</strong> preparation — daily planning, sequential revision, structured notes, mistake tracking, and PDF export. No account. No cloud. Everything stays on your device.
</p>

<p align="center">
  <strong>474 problems · Sequential revision · Notes & PDF · 100% offline</strong>
</p>

---

## Screenshots

| Home & daily tasks | DSA Sheet | Revision |
| :--: | :--: | :--: |
| ![Home screen — daily tasks, streak, and progress](docs/assets/screenshots/home.jpeg) | ![DSA Sheet — topics, filters, solved status](docs/assets/screenshots/dsa_sheet.jpeg) | ![Revision — sequential revision queue](docs/assets/screenshots/revision.jpeg) |

| Notes | Patterns | Dry Run |
| :--: | :--: | :--: |
| ![Notes — problem notes and Yaad Rakhna](docs/assets/screenshots/notes.jpeg) | ![Patterns — pattern-wise progress](docs/assets/screenshots/patterns.jpeg) | ![Dry Run — finger-draw whiteboard](docs/assets/screenshots/dry_run.jpeg) |

---

## LEKHRAJ ?

Most DSA sheets are static checklists — you tick a problem and move on. **Placement OS** (app name: **Lekhraj**) is built for what happens *after* you solve:

| Typical sheet | Placement OS |
| --- | --- |
| Checkbox only | **Structured notes** per problem (approach, edge cases, complexity) |
| Forget why you failed | **Mistakes I Made** section in every problem's notes |
| No revision plan | **Smart sequential revision** over solved problems in sheet order |
| Scattered reminders | **Daily task planner** — new questions, revision, star review |
| Notes lost in notebooks | **One-tap PDF export** of all notes + recorded issues |
| Needs internet | **Hive local database** — works fully offline |

If you have solved 50+ problems but cannot explain your approach a week later, this app is for you.

---

## Features

- 📚 **474 Striver A2Z DSA Problems** — full sheet bundled from `assets/data/striver_a2z.json`, topic hierarchy preserved
- 🧠 **Smart Sequential Revision System** — revises *solved* problems in original sheet order (not random); rotating queue with daily batches
- 📅 **Daily Task Planner** — Home screen tasks: new questions, revision, star revision, and custom user to-dos
- 📝 **Add personal notes for every DSA problem** — markdown editor with a structured template per problem
- 🐞 **Record mistakes/issues faced while solving each question** — dedicated **Mistakes I Made** section in problem notes; plus **Yaad Rakhna** short notes for cross-cutting reminders
- 💡 **Save approaches, edge cases, and important observations** — template sections: Pattern, Core Idea, Algorithm, Pseudo Code, Time/Space Complexity, Important Edge Cases, Interview Tricks, Revision Summary
- 📄 **Export all notes and recorded issues into a single PDF** — compact problem list + **Mistakes & Yaad Rakhna** section at the end
- ⭐ **Star important questions for quick revision** — star revision daily batch from starred problems only
- 🎯 **Pattern-wise learning** — browse patterns, view stats, filter sheet/revision by pattern
- 🔍 **Search problems instantly** — search by name, topic, notes, pattern, or difficulty
- 📊 **Track solved and unsolved progress** — streak, solved count, topic progress, pattern stats, revision queue
- 💾 **Offline-first using Hive local database** — five local boxes; JSON backup/restore included
- 🔔 **Daily reminder notifications** — ongoing task notification + scheduled morning/evening revision reminders
- 🎨 **Modern Material 3 UI** — premium dark theme across all screens
- ⚡ **Fast local storage with no internet required** — seed once from JSON; all reads/writes on device

---

## Key Features

| Feature | What you get |
| --- | --- |
| **PDF export of all notes** | Share a single PDF with every problem note (summary line per question) + short **Yaad Rakhna** entries |
| **Question-wise notes** | Open any problem → structured markdown sections with auto-save |
| **Mistake tracking** | Per-problem **Mistakes I Made** field; global short notes for formats/tricks you keep forgetting |
| **Sequential revision** | Revision queue follows Striver order among solved problems — build long-term retention |
| **Daily planning** | Configurable daily limits (default: 3 new, 3 revision, 2 star) with checkbox tasks on Home |
| **Offline support** | Hive storage, no login, backup/restore via local JSON file |

**Also included:** finger-draw **Dry Run** whiteboard (pen + eraser), motivational quotes on Home, confidence tracking on revision, and revision history per problem.

---

## Quick start

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.2+
- Android SDK (minSdk 24)

### Run

```bash
git clone <your-repo-url>
cd placement_os
flutter pub get
flutter run
```

### Build APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Verify

```bash
flutter analyze
flutter test
```

---

## Tech stack

| | |
| --- | --- |
| **UI** | Flutter, Material 3 (dark) |
| **State** | Riverpod |
| **Routing** | go_router |
| **Storage** | Hive (local, offline) |
| **Export** | pdf, share_plus |
| **Notifications** | flutter_local_notifications |

---

## Project structure

```
lib/
├── core/           # Theme, router, constants, notifications
├── data/           # Hive + repositories
├── domain/         # Entities, revision & daily-task services, PDF
└── presentation/   # Screens, providers, widgets

assets/data/        # striver_a2z.json (474 problems)
docs/               # Architecture, features, roadmap
```

---

## Navigation

| Tab | Route | Purpose |
| --- | --- | --- |
| Home | `/` | Dashboard & today's tasks |
| DSA | `/dsa` | Full sheet with filters |
| Revision | `/revision` | Sequential revision flow |
| Dry Run | `/dry-run` | Drawing whiteboard |
| Notes | `/notes` | Problem notes + Yaad Rakhna |
| Settings | `/settings` | Stats, export, backup |

---

## Documentation

- [Architecture](docs/PROJECT_ARCHITECTURE.md)
- [Full feature reference](docs/FEATURES.md)
- [Roadmap](docs/ROADMAP.md)
- [Contributing](CONTRIBUTING.md)
- [Changelog](CHANGELOG.md)

---

## Android

| | |
| --- | --- |
| **App name** | Lekhraj |
| **Package** | `com.placementos.app` |
| **Version** | 2.0.0+1 |

---

## License

[MIT License](LICENSE) — free to use, modify, and distribute.

---

## Acknowledgments

Problem ordering and structure based on **[Striver's A2Z DSA Sheet](https://takeuforward.org/dsa/strivers-a2z-sheet-learn-dsa-a-to-z)** (takeUforward). This project is a personal revision tool and is not affiliated with takeUforward.

---

<p align="center">
  <sub>Built for students who solve problems but refuse to forget them.</sub>
</p>
