# Lekhraj

**Master DSA. Never Forget Again.**

[![Flutter](https://img.shields.io/badge/Flutter-3.2%2B-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.2%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android-green)](android/)
[![Offline](https://img.shields.io/badge/Storage-Hive%20(local)-purple)](lib/data/datasources/hive_service.dart)

Lekhraj is an **offline-first Android app** for structured DSA preparation using the [Striver A2Z DSA Sheet](https://takeuforward.org/dsa/strivers-a2z-sheet-learn-dsa-a-to-z) (474 problems). It combines daily task planning, sequential revision, structured notes, pattern-based study, PDF export, and a finger-draw dry-run board—without requiring an account or internet connection after install.

> **Note:** The Dart package name is `placement_os`; the user-facing product name is **Lekhraj**.

---

## Why this project exists

Interview prep often fails not because of missing resources, but because of **poor retention and inconsistent revision**. Lekhraj treats DSA prep as a **daily operating system**: new problems, revision batches, starred review, and personal notes—all tied to a fixed sheet order and stored locally on device.

---

## Highlights

| Area | What Lekhraj does |
|------|-------------------|
| **Sheet** | Full Striver A2Z hierarchy (474 questions, topics, patterns) from bundled JSON |
| **Daily tasks** | Configurable new questions, revision, star revision, and custom user tasks |
| **Revision engine** | Sequential queue over *solved* problems in sheet order (not random) |
| **Notes** | Markdown template per problem + standalone “Yaad Rakhna” short notes |
| **Patterns** | Browse, filter, and revise by algorithm pattern |
| **Export** | Compact PDF notes + JSON backup/restore |
| **Dry Run** | In-app whiteboard for array traces and logic sketches |
| **Privacy** | All data stays on device (Hive). No cloud sync in current codebase |

---

## Screenshots

_Add these before publishing to GitHub (see [docs/SCREENSHOTS.md](docs/SCREENSHOTS.md))._

| Home & daily tasks | DSA Sheet | Revision flow |
|:---:|:---:|:---:|
| _pending_ | _pending_ | _pending_ |

| Problem notes | Patterns | Dry Run board |
|:---:|:---:|:---:|
| _pending_ | _pending_ | _pending_ |

---

## Quick start

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) **3.2+**
- Android SDK (minSdk **24**)
- JDK 17+ recommended for Gradle builds

### Run locally

```bash
git clone <your-repo-url>
cd placement_os
flutter pub get
flutter run
```

### Build APK

```bash
# Debug (larger, includes debug symbols)
flutter build apk --debug

# Release
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Analyze & test

```bash
flutter analyze
flutter test
```

---

## Navigation

| Tab | Route | Purpose |
|-----|-------|---------|
| Home | `/` | Dashboard, today's tasks, streak, quick links |
| DSA | `/dsa` | Full sheet with filters |
| Revision | `/revision` | Sequential revision queue |
| Dry Run | `/dry-run` | Finger drawing whiteboard |
| Notes | `/notes` | Problem notes + short notes |
| Settings | `/settings` | Stats, export, backup, daily limits |

Additional routes: `/problem/:id`, `/search`, `/patterns`, `/patterns/:name`

---

## Tech stack

| Layer | Technology |
|-------|------------|
| UI | Flutter, Material 3 (dark theme) |
| State | [Riverpod](https://riverpod.dev) |
| Routing | [go_router](https://pub.dev/packages/go_router) |
| Storage | [Hive](https://docs.hivedb.dev) (5 local boxes) |
| Notifications | flutter_local_notifications, timezone |
| Export | pdf, share_plus, file_picker |

See [docs/PROJECT_ARCHITECTURE.md](docs/PROJECT_ARCHITECTURE.md) for layer diagrams and data flow.

---

## Project structure

```
placement_os/
├── lib/
│   ├── main.dart                 # Startup: Hive, seed, daily sync, notifications
│   ├── app.dart                  # MaterialApp.router
│   ├── core/                     # Theme, router, constants, notifications
│   ├── data/                     # Hive + repositories
│   ├── domain/                   # Entities, business services
│   └── presentation/             # Screens, providers, widgets
├── assets/
│   ├── data/striver_a2z.json     # 474-question sheet + patterns
│   └── quotes/quotes.json        # Home screen quotes
├── test/                         # Unit tests
├── tool/enrich_patterns.py       # Dev script: pattern enrichment for JSON
├── docs/                         # Architecture, features, roadmap
├── android/                      # Android host (com.placementos.app)
└── pubspec.yaml
```

Recommended repository layout for GitHub:

```
lekhraj/                          # GitHub repo root (rename from placement_os if desired)
├── README.md
├── LICENSE
├── CHANGELOG.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── docs/
├── assets/branding/              # logo, banner, screenshots (recommended)
├── placement_os/                 # OR keep Flutter root at repo root (current)
└── .github/                      # ISSUE_TEMPLATE, workflows (recommended)
    ├── workflows/ci.yml
    └── ISSUE_TEMPLATE/
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [docs/FEATURES.md](docs/FEATURES.md) | Complete feature reference (code-backed) |
| [docs/PROJECT_ARCHITECTURE.md](docs/PROJECT_ARCHITECTURE.md) | Layers, services, data model, startup flow |
| [docs/ROADMAP.md](docs/ROADMAP.md) | Planned improvements and known gaps |
| [docs/SCREENSHOTS.md](docs/SCREENSHOTS.md) | Screenshot checklist for README |
| [CHANGELOG.md](CHANGELOG.md) | Version history |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to contribute |

---

## Data & privacy

- Progress, notes, tasks, and settings are stored in **Hive** on device.
- Backup/export produces a local JSON file via the system share sheet.
- PDF export generates a temporary file and shares it—nothing is uploaded by the app itself.
- **There is no Firebase/cloud sync implemented in the current codebase** (despite older README text).

---

## Android

| Field | Value |
|-------|-------|
| Application ID | `com.placementos.app` |
| Display name | Lekhraj |
| minSdk | 24 |

---

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before opening a PR.

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Acknowledgments

- Problem sheet structure and ordering based on **Striver's A2Z DSA Sheet** ([takeUforward](https://takeuforward.org)).
- Built as a personal placement-prep tool; open-sourced for learning and portfolio use.

---

## GitHub presentation checklist

Use these when publishing the repository:

### Suggested repository description

> Offline Flutter DSA revision app for Striver A2Z (474 problems)—daily tasks, sequential revision, structured notes, patterns, PDF export, and dry-run whiteboard.

### Suggested topics / tags

`flutter` `dart` `dsa` `data-structures` `algorithms` `interview-preparation` `revision-app` `offline-first` `hive` `riverpod` `android` `competitive-programming` `striver-a2z` `placement-preparation` `material-design`

### Logo concept

- **Mark:** Minimal purple (`#9D4EDD`) brain or memory loop merged with `{ }` brackets.
- **Wordmark:** “Lekhraj” in clean geometric sans; tagline optional below.
- **Style:** Flat, dark-background friendly, readable at 32×32 (app icon) and 128×128 (README).

### Banner image concept

- Dark gradient background (`#0D0B14` → `#211C33`).
- Center: phone mockup showing Home + today's tasks.
- Left/right: floating chips—“474 Problems”, “Sequential Revision”, “Offline Hive”.
- Subtle grid or graph paper texture behind “Dry Run” reference.

### Screenshots to capture

See [docs/SCREENSHOTS.md](docs/SCREENSHOTS.md) for the full list with framing notes.
