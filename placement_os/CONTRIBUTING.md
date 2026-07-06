# Contributing to Lekhraj

Thank you for your interest in contributing. Lekhraj is an offline Flutter app for structured DSA revision; thoughtful contributions help make it more reliable for students and easier to evaluate for recruiters reviewing the codebase.

## Before you start

1. Read [docs/PROJECT_ARCHITECTURE.md](docs/PROJECT_ARCHITECTURE.md) to understand layers and data flow.
2. Read [docs/FEATURES.md](docs/FEATURES.md) so changes align with existing behavior.
3. Check [docs/ROADMAP.md](docs/ROADMAP.md) for known gaps and planned work.

## Development setup

```bash
cd placement_os
flutter pub get
flutter analyze
flutter test
flutter run
```

### Requirements

- Flutter SDK ≥ 3.2.0
- Android toolchain for device/emulator testing
- JDK compatible with the project's Gradle version

## How to contribute

### Reporting bugs

Open an issue with:

- **Device / OS** (e.g. Android 14, Samsung)
- **App version** from `pubspec.yaml`
- **Steps to reproduce**
- **Expected vs actual behavior**
- **Screenshots or logs** if available

### Suggesting features

Open a discussion or issue describing:

- The problem you're solving
- Why it fits Lekhraj's offline, sheet-order revision model
- Whether it affects daily tasks, revision queue, or notes

Please avoid proposing features that require cloud accounts unless you also plan to implement opt-in sync.

### Pull requests

1. **Fork** the repository and create a branch from `main`:
   - `feat/short-description`
   - `fix/short-description`
   - `docs/short-description`
2. **Keep PRs focused**—one concern per PR when possible.
3. **Match existing style:**
   - Riverpod for state
   - Repository pattern for Hive access
   - Domain services for business logic (revision, daily tasks)
4. **Run checks before submitting:**
   ```bash
   flutter analyze
   flutter test
   ```
5. **Update docs** if you change user-visible behavior (`docs/FEATURES.md`, `CHANGELOG.md`).
6. **Do not** commit secrets, keystores, or `android/local.properties`.

## Code guidelines

### Architecture

```
presentation/  → UI, Riverpod providers
domain/        → entities, services (revision, daily tasks, PDF)
data/          → Hive, repositories, asset seeding
core/          → theme, router, constants, notifications
```

- **Do not** access Hive directly from widgets—use repositories or services via providers.
- **Do not** break Striver A2Z sheet order for revision/new-question batching without discussion.
- Prefer extending `ProblemEntity` / settings migration over ad-hoc storage.

### State refresh

The app uses a manual `refresh(ref)` pattern on `refreshProvider`. After mutating Hive data, ensure providers rebuild consistently.

### Tests

- Add tests for revision logic, daily task sync, and repository behavior when touching those areas.
- Widget tests are welcome for critical flows (home tasks, problem detail notes).

### Commits

Use clear, imperative messages:

```
feat(home): persist daily task checkbox state across refresh
fix(revision): restore missing auto-tasks when only star batch exists
docs: add architecture diagram for daily task sync
```

## What we are especially looking for

- Real unit/integration tests for `SmartRevisionService` and `DailyTaskService`
- CI workflow (analyze + test on PR)
- Accessibility improvements (semantics, contrast)
- Removing unused dependencies (e.g. `fl_chart` if still unused)
- Production release signing documentation (without committing keys)

## Code of conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md). Be respectful and constructive.

## Questions

Open a GitHub issue with the `question` label if setup or architecture is unclear.
