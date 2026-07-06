# Placement OS — Personal DSA Revision App

**Tagline:** Master DSA. Never Forget Again.

## Overview

Personal Android app for completing [Striver A2Z Sheet](https://takeuforward.org/dsa/strivers-a2z-sheet-learn-dsa-a-to-z) with automatic 7-day spaced revision. All data stored locally — no Firebase, no accounts.

## Features

- **474 official Striver A2Z questions** (data-driven from JSON)
- **7-day automatic revision** on solve and after each revision
- **Daily tasks** with persistent ongoing notification until all complete
- **Starred questions** with filter on Revision page
- **Markdown notes** per problem
- **Search** across questions, topics, notes
- **Export / Import / Reset** in Settings

## Tech Stack

Flutter · Hive · Riverpod · GoRouter · Material 3 · flutter_local_notifications · WorkManager

## Bottom Navigation

Home · DSA Sheet · Revision · DSA Notes · Settings

## Build

```bash
flutter pub get
flutter analyze
flutter build apk --release
```

## Data

Questions loaded from `assets/data/striver_a2z.json` (sourced from official TakeUForward sheet, Dec 2025).
