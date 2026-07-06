# Screenshot guide

Add screenshots to `docs/assets/screenshots/` (create folder) and reference them from [README.md](../README.md).

Recommended filenames and what to capture:

## Required (6)

| File | Screen | What to show |
|------|--------|--------------|
| `01-home-tasks.png` | Home | Streak, progress ring, all four task sections with at least one checked (strikethrough visible) |
| `02-dsa-sheet.png` | DSA Sheet | Expanded topic, mixed solved/unsolved rows, filter chips |
| `03-revision.png` | Revision | Active revision card or "batch complete" state + queue preview |
| `04-problem-notes.png` | Problem detail | Notes editor with template sections partially filled |
| `05-patterns.png` | Patterns | Pattern list with progress stats |
| `06-dry-run.png` | Dry Run | Whiteboard with sample array/trace drawing, toolbar visible |

## Recommended (4)

| File | Screen | What to show |
|------|--------|--------------|
| `07-notes-yaad-rakhna.png` | Notes → Yaad Rakhna tab | Short notes list + add form |
| `08-settings.png` | Settings | Stats, daily limits, export buttons |
| `09-search.png` | Search | Query + filtered results |
| `10-pdf-export.png` | System share sheet | PDF export preview (optional: PDF page screenshot) |

## Capture tips

- Use **Android emulator** or device at **1080×2400** (crop to ~9:19.5).
- Enable **dark theme** (app default); use consistent status bar.
- Use **realistic data**: some solved problems, notes filled, 1–2 tasks checked.
- Avoid personal phone numbers or notifications in status bar.
- Export PNG; target width **1080px** for README tables.

## README embed example

```markdown
![Home screen](docs/assets/screenshots/01-home-tasks.png)
```

## Banner (optional)

Create `docs/assets/banner.png` at **1280×640**:

- Dark gradient background (`#0D0B14` → `#211C33`)
- App name + tagline
- Phone mockup centered
- Feature pills: `474 Problems` · `Offline` · `Sequential Revision`

## Logo (optional)

Create `docs/assets/logo.png` at **512×512**:

- Purple memory/bracket icon on dark circle
- Used for README header and future GitHub social preview
