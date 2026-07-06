# 1. Product Requirements Document (PRD)

## Placement OS — Your Second Brain for Placement Preparation

**Document Owner:** Product  
**Last Updated:** July 2026  
**Target Platform:** Android (Google Play), Flutter cross-platform ready  

---

## 1. Executive Summary

Placement OS is a premium productivity application for software engineering students preparing for campus placements. Unlike generic todo apps or static spreadsheet trackers, Placement OS **automates** the entire preparation lifecycle: DSA roadmaps, spaced-repetition revision, system design, CS subjects, research, mock interviews, and progress analytics.

The product positioning targets a **₹999/month premium feel** — comparable to Notion, Linear, TickTick, and GitHub Mobile in polish, motion, and information architecture.

---

## 2. Problem Statement

### Current Pain Points

| Pain Point | Impact |
|------------|--------|
| Fragmented tools (LeetCode + Notion + Sheets + Anki) | Context switching, lost progress |
| No automatic revision scheduling | Forgotten problems resurface in interviews |
| Manual streak/goal tracking | Motivation drops mid-prep |
| Striver sheet as static PDF/Notion | No confidence tracking, no mistake notebook |
| No unified view of weak topics | Inefficient study allocation |
| Placement countdown anxiety | No structured daily plan |

### Opportunity

Build the **single source of truth** for placement preparation with intelligent automation — revision engine, AI daily plans, and premium UX that students willingly pay for.

---

## 3. Goals & Success Metrics

### Business Goals

- Launch on Google Play within 6 months (post-approval)
- 10K MAU within first placement season
- 4.5+ Play Store rating
- 15% free-to-premium conversion (future monetization)

### User Goals

- Solve 500+ DSA problems with structured revision
- Never miss a revision due date
- Track placement readiness holistically
- Reduce daily planning time from 30 min → 2 min (AI plan)

### Key Metrics (North Star: **Revision Completion Rate**)

| Metric | Target (90 days) |
|--------|------------------|
| D7 retention | ≥ 45% |
| Daily active revision completion | ≥ 70% |
| Problems marked solved (verified) | ≥ 5/user/week |
| Streak maintenance (7+ days) | ≥ 35% of actives |
| Session length (focused) | 45–90 min avg |
| Crash-free sessions | ≥ 99.5% |

---

## 4. Target Users

See [03-user-personas.md](./03-user-personas.md) for full profiles.

**Primary:** 3rd/4th year B.Tech CS student, 6–12 months to placement  
**Secondary:** Working professional switching to SDE roles  
**Tertiary:** 2nd year student building early foundation  

---

## 5. Feature Requirements

### 5.1 Authentication (P0)

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| AUTH-01 | Google Sign-In | One-tap login, profile photo sync |
| AUTH-02 | Anonymous login | Firebase anonymous auth, upgrade path to Google |
| AUTH-03 | Guest mode | Local-only Hive, no cloud sync, export warning |
| AUTH-04 | Session persistence | Auto-login on app reopen |

### 5.2 Home Dashboard (P0)

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| DASH-01 | Greeting + time-aware copy | "Good Morning/Afternoon/Evening" |
| DASH-02 | Streak, Level, XP, Coins | Real-time from Firestore/Hive |
| DASH-03 | Days until placement | User-configured target date countdown |
| DASH-04 | Daily quote | Rotating motivational quotes |
| DASH-05 | Today's goals | Checklist with progress ring |
| DASH-06 | Quick continue | Last active problem/roadmap |
| DASH-07 | Today's revision count | Badge + tap to revision queue |
| DASH-08 | Pending tasks | From daily planner |
| DASH-09 | Study hours today | Timer aggregation |
| DASH-10 | Progress ring | Daily goal % animated |
| DASH-11 | Weekly heatmap | GitHub-style 7-day strip |
| DASH-12 | Recent activity | Last 10 actions timeline |

### 5.3 Roadmaps (P0)

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| ROAD-01 | Multi-roadmap support | Striver A2Z, NeetCode 150, Blind 75, Love Babbar, SD, OS, DBMS, CN, OOP, SQL, Java, Aptitude, Behavioral, HR, Mock, Resume, Projects |
| ROAD-02 | Topic hierarchy | Expandable topics → subtopics → problems |
| ROAD-03 | Problem metadata | Name, difficulty, link, video, status, notes, confidence, mistakes, time, attempts, last solved, next revision |
| ROAD-04 | Progress per roadmap | Percentage, estimated time remaining |
| ROAD-05 | Striver-identical UI | Expandable accordion topics, familiar layout |

**Roadmap catalog (launch):**

1. Striver A2Z DSA Sheet  
2. NeetCode 150  
3. Blind 75  
4. Love Babbar Sheet  
5. System Design Roadmap  
6. Operating Systems  
7. DBMS  
8. Computer Networks  
9. OOP  
10. SQL  
11. Java  
12. Aptitude  
13. Behavioral Interview  
14. HR Questions  
15. Mock Interviews  
16. Resume Checklist  
17. Projects  

### 5.4 Problem Entity (P0)

Every problem supports:

- Solved checkbox  
- Revision checkbox  
- Favourite / Bookmark  
- Notes (rich text)  
- Code snippet (syntax highlighted)  
- Tags  
- Confidence rating (1–5 stars)  
- Time taken  
- Attempts count  
- Language used  

### 5.5 Confidence Scale (P0)

| Stars | Label | Definition |
|-------|-------|------------|
| 5 | Master | Can solve without help |
| 4 | Strong | Need little hint |
| 3 | Moderate | Need logic guidance |
| 2 | Weak | Need full explanation |
| 1 | Forgot | Forgot completely |

### 5.6 Revision Engine (P0 — Core Differentiator)

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| REV-01 | Auto-create revisions on solve | Intervals: 1, 3, 7, 15, 30, 60, 90, 180, 365 days |
| REV-02 | Revision queue | Today, Overdue, Upcoming, Completed |
| REV-03 | Search, filter, sort | By topic, difficulty, confidence, date |
| REV-04 | Revision heatmap | Calendar visualization |
| REV-05 | Revision analytics | Accuracy, completion rate |
| REV-06 | Revision mode flow | Problem → notes → mistakes → confidence → timer → post-assessment |

**Post-revision assessment:**

| Answer | Confidence adjustment |
|--------|----------------------|
| Solved Easily | +1 (max 5) |
| Medium | No change |
| Hard | -1 |
| Forgot | -2 (min 1), reschedule sooner |

See [16-revision-algorithm.md](./16-revision-algorithm.md).

### 5.7 Smart AI (P1)

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| AI-01 | Weak/strong topic analysis | Weekly computed report |
| AI-02 | Frequently forgotten problems | Top 10 list |
| AI-03 | Tomorrow's plan suggestion | DSA + revision + SD allocation |
| AI-04 | Revision accuracy insights | Trend graph |

See [17-ai-recommendation-engine.md](./17-ai-recommendation-engine.md).

### 5.8 Daily Planner (P0)

- Morning routine checklist  
- Today's DSA, Revision, System Design, Research  
- Gym, English, Reading (optional wellness blocks)  
- Progress ring for daily completion  

### 5.9 System Design Module (P1)

- Roadmap with topics and progress  
- Resources, videos, notes  
- Architecture drawing (canvas)  
- Diagram upload to Storage  
- Timer, bookmarks  

### 5.10 Research Module (P1)

- Projects, paper reading, experiments  
- Implementation notes, datasets, ideas  
- Attachments, progress tracking  

### 5.11 CS Subjects (P1)

- OS, DBMS, CN, OOP, Java, SQL  
- Each: roadmap, revision, notes, questions  

### 5.12 Mock Interview (P1)

- Interview tracker  
- Question bank (coding, SD, behavioral)  
- STAR method templates  
- Feedback logging  

### 5.13 Mistake Notebook (P0)

Auto-capture mistake categories:

- Wrong algorithm, wrong complexity, forgot edge case  
- Wrong syntax, binary search mistake, DP mistake  
- Graph, HashMap, sliding window, greedy, tree mistakes  

Filterable, searchable, linked to problems.

### 5.14 Global Search (P0)

Search across: problems, topics, notes, mistakes, research, system design, bookmarks.

### 5.15 Statistics (P0)

- Daily / weekly / monthly / yearly views  
- Bar, line, pie charts, heatmaps  
- Streaks, study hours, problems solved, revision done  
- Research hours, SD hours, avg time, avg confidence  

### 5.16 Calendar (P0)

- GitHub-style heatmap (green/yellow/red)  
- Date tap → timeline of that day's activity  

### 5.17 Achievements (P1)

Badges: First Problem, 100/500/1000 Problems, 7/30/100 Day Streak, Perfect Week/Month, Legend.

### 5.18 Focus Mode (P1)

- Pomodoro 25/5, 50/10  
- Deep work timer  
- Ambient sounds  
- DND integration hint  

### 5.19 Notifications (P0)

See [18-notification-architecture.md](./18-notification-architecture.md).

### 5.20 Profile & Settings (P0)

**Profile:** Avatar, XP, coins, level, rank, roadmap progress, study hours, export/backup/restore  

**Settings:** Dark mode (default), notification times, revision timing, theme, font size, cloud backup, offline mode, JSON import/export  

---

## 6. Non-Functional Requirements

| Category | Requirement |
|----------|-------------|
| Performance | Cold start < 2s, 60fps animations |
| Offline | Full read/write via Hive, sync queue |
| Security | Firestore rules, no client-side secrets |
| Accessibility | Min 48dp touch targets, scalable fonts |
| Localization | English v1, Hindi v1.1 |
| Analytics | Firebase Analytics, crashlytics |
| Backup | Daily cloud backup, manual export |

---

## 7. Out of Scope (v1.0)

- iOS launch (architecture ready, not shipped)  
- Social features / leaderboards  
- Live mock interview pairing  
- In-app code execution / judge  
- Web dashboard  
- Paid subscriptions (UI placeholders only)  

---

## 8. Release Phases

| Phase | Scope | Timeline |
|-------|-------|----------|
| MVP | Auth, Dashboard, Striver roadmap, Revision engine, Planner, Profile | Weeks 1–8 |
| Beta | All roadmaps, Statistics, Calendar, Search, Mistake notebook | Weeks 9–14 |
| v1.0 | AI plans, SD, Research, Mock interview, Achievements, Focus mode | Weeks 15–22 |
| v1.1 | Premium tier, Hindi, widget, wear | Post-launch |

See [20-development-roadmap.md](./20-development-roadmap.md).

---

## 9. Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Firestore read costs at scale | Aggressive Hive caching, pagination |
| Roadmap data maintenance | Seed JSON in Storage, versioned updates |
| AI cost | On-device heuristics first, cloud AI optional |
| Feature creep | Strict P0/P1 gates per phase |
| Offline sync conflicts | Last-write-wins + conflict UI for notes |

---

## 10. Open Questions (For Approval)

1. Placement date: single global or per-user? → **Per-user**  
2. Premium monetization model: subscription vs one-time? → **Deferred to v1.1**  
3. AI backend: Gemini vs rule-based MVP? → **Rule-based MVP, Gemini P1**  
4. Guest mode data migration on sign-up? → **Prompt merge on upgrade**  

---

## 11. Approval Sign-off

| Role | Name | Date | Approved |
|------|------|------|----------|
| Product | | | ☐ |
| Engineering | | | ☐ |
| Design | | | ☐ |
| Stakeholder | | | ☐ |
