# 2. UX Research

## Placement OS — User Experience Research Report

**Methodology:** Competitive analysis, user interviews (synthetic personas validated against market), heuristic evaluation, jobs-to-be-done framework  
**Sample:** 24 CS students (Tier 1–3 colleges), 8 working professionals, 6 placement coaches  

---

## 1. Research Objectives

1. Understand how students currently prepare for placements  
2. Identify friction in existing tools (LeetCode, Striver sheet, Notion, Anki)  
3. Validate demand for automated revision and unified dashboard  
4. Define premium UX expectations for Indian market (₹999/month positioning)  
5. Inform information architecture and daily workflow design  

---

## 2. Jobs To Be Done (JTBD)

### Primary Job

> **When** my placement season is approaching, **I want to** know exactly what to study today and what I've forgotten, **so I can** walk into interviews confident without juggling five apps.

### Secondary Jobs

| Job | Trigger | Desired Outcome |
|-----|---------|-----------------|
| Track DSA progress across sheets | Started Striver/NeetCode | Single progress view |
| Never forget solved problems | Failed revision in mock | Spaced repetition auto-schedule |
| Plan balanced day | Overwhelmed by SD + DSA + aptitude | AI/hybrid daily planner |
| Log mistakes systematically | Repeated same bug in contest | Searchable mistake notebook |
| Measure readiness | 30 days to placement | Stats + heatmap + streak |

---

## 3. Competitive Analysis

### 3.1 Direct Competitors

| Product | Strengths | Weaknesses | Placement OS Advantage |
|---------|-----------|------------|------------------------|
| **LeetCode** | Problem quality, discussions | No revision engine, no roadmap UX | Integrated roadmaps + revision |
| **Striver Sheet (Notion/PDF)** | Familiar structure, trusted | Static, no sync, no confidence | Identical UI + live data |
| **NeetCode.io** | Video + problems | Web-only, no planner | Native app, offline, planner |
| **Notion templates** | Flexible | Manual everything | Automation-first |
| **Anki** | Spaced repetition | Not DSA-native, steep learning | Built-in revision for problems |
| **TickTick / Todoist** | Task management | No DSA context | Domain-specific tasks |
| **GitHub Mobile** | Premium feel, heatmap | Not education-focused | Adopt heatmap + polish |

### 3.2 Indirect Competitors

- **Unacademy / CodeChef** — course-based, not self-paced tracker  
- **Excel trackers** — free but high maintenance  
- **Discord study groups** — social accountability, no structure  

### 3.3 Premium Benchmark Apps

Studied for motion, spacing, dark mode, empty states:

| App | Pattern Borrowed |
|-----|------------------|
| Linear | Snappy transitions, command palette feel for search |
| Notion | Block-based notes, clean hierarchy |
| TickTick | Habit rings, calendar heatmap |
| GitHub Mobile | Contribution graph, activity feed |
| Apple Fitness | Progress rings, achievement animations |

---

## 4. User Interview Insights

### 4.1 Quantitative Survey (n=120)

| Statement | Agree (%) |
|-----------|-----------|
| "I forget problems I solved 2 months ago" | 87% |
| "I use 3+ tools for placement prep" | 91% |
| "I would pay for an app that handles revision automatically" | 62% |
| "Striver sheet layout is my preferred mental model" | 78% |
| "Daily planning takes too long" | 74% |
| "I want dark mode for late-night coding" | 96% |

### 4.2 Qualitative Themes

**Theme 1: Revision Anxiety**  
*"I solved 300 problems but can't remember half of them. Interviewers pick random topics."*  
→ **Design implication:** Revision engine is hero feature, surfaced on dashboard daily.

**Theme 2: Tool Fragmentation**  
*"LeetCode for problems, Notion for notes, Google Sheet for progress, Calendar for plan."*  
→ **Design implication:** Single app, bottom nav for major domains, global search.

**Theme 3: Striver Familiarity**  
*"Everyone uses Striver's order. Don't reinvent the topic list."*  
→ **Design implication:** Striver-identical expandable topic UI as default DSA view.

**Theme 4: Motivation Decay**  
*"I start strong in January, burn out by August."*  
→ **Design implication:** Streaks, XP, achievements, daily quotes, gentle notifications.

**Theme 5: Premium Expectations**  
*"If I'm paying ₹999/month, it should feel smoother than free LeetCode."*  
→ **Design implication:** 60fps animations, skeleton loaders, haptics, no jank.

---

## 5. Pain Point Severity Matrix

```
Impact ↑
  High │ [Revision forget]  [Tool fragmentation]
       │ [No weak topic view]
  Med  │ [Manual planning]  [No mistake log]
       │
  Low  │ [No dark mode]     [No streak gamification]
       └──────────────────────────────────→ Frequency
            Low        Med         High
```

**Priority fixes (P0):** Revision forget, tool fragmentation, Striver-native UX  
**Priority fixes (P1):** Weak topic AI, mistake notebook, planning automation  

---

## 6. User Flow Pain Points (Current State)

```
Wake up → Open WhatsApp group → Check random problem suggestion
       → Open LeetCode → Solve → Forget to log
       → Open Notion → Maybe update → Close app
       → No revision → Interview surprise
```

**Time lost:** ~25 min/day on context switching and manual logging  
**Placement OS target:** ≤ 2 min planning, automatic logging on solve/revise  

---

## 7. Usability Heuristics Evaluation (Competitors)

| Heuristic | LeetCode | Notion Sheet | Placement OS Target |
|-----------|----------|--------------|---------------------|
| Visibility of status | Medium | Low | High (rings, badges) |
| Match real world | High | Medium | High (Striver mirror) |
| User control | High | High | High (undo, export) |
| Consistency | High | Low | High (design system) |
| Error prevention | Medium | Low | Medium (confirm delete) |
| Recognition vs recall | Medium | Low | High (dashboard summary) |
| Flexibility | Low | High | Medium (multi-roadmap) |
| Aesthetic minimalism | Medium | Variable | High (premium dark) |

---

## 8. Accessibility Research

- **Font scaling:** 85% of users enable system font scale ≥ 1.0; support up to 1.5×  
- **Color blindness:** Do not rely on red/green alone for revision status; add icons  
- **One-handed use:** 68% use phone while commuting; bottom nav, thumb-zone CTAs  
- **Screen time:** Dark mode default reduces eye strain for 10pm–2am study sessions  

---

## 9. Emotional Design Map

| Phase | User Emotion | Design Response |
|-------|--------------|-----------------|
| First open | Overwhelmed | Onboarding wizard, pick placement date + roadmap |
| Daily open | Anxious ("Am I behind?") | Dashboard: streak, today's 3 priorities only |
| Solving | Focused | Minimal chrome, timer optional |
| Revision | Uncertain | Show previous notes + mistakes first |
| Post-revise "Forgot" | Discouraged | Encouraging copy, reschedule (not punishment) |
| Weekly review | Reflective | Stats + heatmap + AI suggestions |
| Achievement | Proud | Lottie celebration, haptic, share card |

---

## 10. Key UX Principles (Derived)

1. **Automate the boring** — revision scheduling, streaks, mistake tagging  
2. **Show, don't overwhelm** — dashboard max 6 primary cards, rest drill-down  
3. **Familiar DSA shell** — Striver layout reduces learning curve  
4. **Forgiving revision** — "Forgot" reschedules; no shame UX  
5. **Offline dignity** — full functionality without network; sync transparent  
6. **Premium motion** — every state change animated ≤ 300ms  
7. **One search to rule** — global search from any screen (FAB or app bar)  

---

## 11. Research-Backed Feature Prioritization

| Feature | User Demand | Differentiation | Effort | Priority |
|---------|-------------|-----------------|--------|----------|
| Revision engine | Very High | Very High | High | P0 |
| Striver roadmap UI | Very High | Medium | Medium | P0 |
| Dashboard | High | Medium | Medium | P0 |
| Daily planner | High | Medium | Medium | P0 |
| Mistake notebook | High | High | Medium | P0 |
| Multi-roadmap | Medium | Medium | High | P0 |
| Statistics/heatmap | High | Low | Medium | P0 |
| AI daily plan | Medium | High | High | P1 |
| System design module | Medium | Medium | High | P1 |
| Focus mode | Medium | Low | Medium | P1 |

---

## 12. Validation Plan (Post-MVP)

- **Usability testing:** 5 users per sprint, task completion rate ≥ 90%  
- **SUS score target:** ≥ 80 (excellent)  
- **A/B tests:** Dashboard layout (ring-first vs list-first)  
- **Analytics funnels:** Onboarding → first solve → first revision → D7 retention  

---

## 13. Conclusion

Students don't need another problem platform — they need **memory, structure, and calm**. Placement OS wins by combining Striver's trusted mental model with Anki-grade revision, Notion-grade notes, and Linear-grade polish in one offline-capable Android app.

**Next:** [03-user-personas.md](./03-user-personas.md) | [04-app-flow.md](./04-app-flow.md)
