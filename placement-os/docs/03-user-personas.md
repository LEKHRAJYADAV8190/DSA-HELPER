# 3. User Personas

## Placement OS — User Persona Library

---

## Persona 1: Arjun — The Focused Final-Year Student (Primary)

![Archetype: Primary — 60% of target users]

### Demographics

| Attribute | Value |
|-----------|-------|
| Age | 21 |
| Location | Pune, India |
| Education | B.Tech CSE, Tier 2 college |
| Placement timeline | 8 months |
| Device | Redmi Note 13, Android 14 |
| Budget sensitivity | High (student), willing to pay if value clear |

### Background

Arjun has completed ~120 LeetCode problems but tracks progress in a messy Google Sheet. He follows Striver's A2Z order religiously. Struggles with revision — often fails to recall DP problems from 3 months ago. Studies 4–6 hours daily, mostly nights.

### Goals

- Complete Striver A2Z before placement drives  
- Maintain 30-day streak  
- Never enter interview without revising weak topics  
- Track system design alongside DSA  

### Frustrations

- "I solved it once but forgot in mock interview"  
- "Too many apps — LeetCode, Notion, Telegram groups"  
- "I don't know if I'm on track for TCS vs Amazon level"  

### Behaviors

- Opens phone at 7 AM for daily plan  
- Solves 2–3 problems per session  
- Watches Striver videos after failing  
- Checks WhatsApp placement groups 10+ times/day (distraction)  

### Placement OS Usage

| Feature | Usage intensity |
|---------|-----------------|
| Dashboard | Daily, first screen |
| Striver roadmap | Daily |
| Revision queue | Daily (morning) |
| Daily planner | Daily |
| Statistics | Weekly |
| AI plan | When overwhelmed |

### Quote

> "Just tell me what to revise today and what to solve next. I'll do the work."

### Design Implications

- Onboarding: pick Striver A2Z + placement date  
- Dashboard: revision count prominent  
- One-tap "Start Revision" CTA  
- Streak + XP for motivation  

---

## Persona 2: Priya — The Balanced Multi-Tasker (Primary)

![Archetype: Primary — 25% of target users]

### Demographics

| Attribute | Value |
|-----------|-------|
| Age | 22 |
| Location | Bangalore |
| Education | B.Tech IT + minor in ML |
| Placement timeline | 5 months |
| Device | Samsung Galaxy S23 |
| Budget sensitivity | Medium |

### Background

Priya prepares for product-based companies. Balances DSA, system design, OS/DBMS theory, and a research project on recommendation systems. Uses Notion heavily but wants native mobile experience. Strong organizational skills, weak on consistent revision.

### Goals

- 200 NeetCode + SD fundamentals  
- Research project portfolio ready  
- Behavioral interview STAR stories documented  
- Weekly progress report for self-review  

### Frustrations

- "Notion is slow on mobile"  
- "No single view of DSA + SD + CS subjects"  
- "Research notes scattered across Drive and Notion"  

### Behaviors

- Plans week on Sunday  
- Mock interview with friends bi-weekly  
- Reads papers on weekends  
- Uses pomodoro informally  

### Placement OS Usage

| Feature | Usage intensity |
|---------|-----------------|
| Multi-roadmap | High |
| System design module | High |
| Research module | High |
| Mock interview tracker | Medium |
| Focus mode | Daily |
| Global search | High |

### Quote

> "I need one brain for everything — coding, design, theory, and my project."

### Design Implications

- Bottom nav covers all domains  
- Research + SD as first-class modules  
- Global search essential  
- Export/backup for portfolio  

---

## Persona 3: Rohit — The Early Starter (Secondary)

![Archetype: Secondary — 10% of target users]

### Demographics

| Attribute | Value |
|-----------|-------|
| Age | 19 |
| Location | Jaipur |
| Education | 2nd year CSE |
| Placement timeline | 24 months |
| Device | Realme Narzo |
| Budget sensitivity | Very high |

### Background

Started DSA early after watching Striver YouTube. Completed ~40 basics problems. No placement pressure yet but wants habit formation. Uses free tools only; guest mode likely entry point.

### Goals

- Build 100-day streak habit  
- Learn fundamentals deeply (not rush)  
- Understand revision science early  

### Frustrations

- "Premium apps feel expensive for 2nd year"  
- "Overwhelmed by 500-problem lists"  

### Behaviors

- 1 problem/day consistency  
- Watches videos more than coding  
- Shares streak screenshots  

### Placement OS Usage

| Feature | Usage intensity |
|---------|-----------------|
| Guest mode | Entry |
| Achievements | High |
| Striver basics topics | High |
| Revision (light) | Medium |

### Quote

> "I want to build the habit now so placement year isn't panic mode."

### Design Implications

- Guest mode without friction  
- Gamification heavy (XP, badges)  
- Hide placement countdown until configured  
- Gentle onboarding, no pressure copy  

---

## Persona 4: Vikram — The Career Switcher (Secondary)

![Archetype: Secondary — 5% of target users]

### Demographics

| Attribute | Value |
|-----------|-------|
| Age | 27 |
| Location | Hyderabad |
| Background | 3 years QA automation → SDE transition |
| Placement timeline | Self-defined (6 months) |
| Device | OnePlus 12 |
| Budget sensitivity | Low (employed) |

### Background

Prepares after work 8–11 PM. Targets mid-tier product companies. Strong practical skills, weak on CS theory and advanced DSA. Needs Blind 75 + CS subject roadmaps more than Striver full sheet.

### Goals

- Blind 75 in 8 weeks  
- OS/DBMS crash revision  
- Mock interviews with structured feedback  

### Frustrations

- "College student apps feel childish"  
- "Need efficient night sessions, not 4-hour blocks"  

### Behaviors

- 90-min focused sessions  
- Skips videos, reads editorial  
- Tracks time per problem carefully  

### Placement OS Usage

| Feature | Usage intensity |
|---------|-----------------|
| Blind 75 roadmap | High |
| CS subjects | High |
| Focus mode / Pomodoro | High |
| Time tracking | High |
| Statistics | Weekly |

### Quote

> "Give me efficiency. I have 3 hours after work, not all day."

### Design Implications

- Professional tone (not overly gamified)  
- Focus mode prominent in profile  
- Time analytics valued  
- Compact dashboard for quick night check  

---

## Persona 5: Placement Cell Coordinator — Meera (Tertiary / Future B2B)

![Archetype: Tertiary — future institutional feature]

### Demographics

| Attribute | Value |
|-----------|-------|
| Role | TPO / Placement Coordinator |
| Institution | Tier 2 engineering college |

### Goals

- Monitor batch readiness (anonymized aggregates)  
- Recommend structured preparation paths  

### Placement OS Usage (Future)

- Batch analytics dashboard (web, out of v1 scope)  
- Export templates for students  

### Design Implications

- JSON export enables coordinator tooling later  
- No social/compare features in v1 (privacy)  

---

## Persona Comparison Matrix

| Need | Arjun | Priya | Rohit | Vikram |
|------|-------|-------|-------|--------|
| Striver A2Z | ★★★ | ★★ | ★★★ | ★ |
| Revision engine | ★★★ | ★★★ | ★★ | ★★★ |
| Multi-roadmap | ★★ | ★★★ | ★ | ★★★ |
| AI daily plan | ★★★ | ★★ | ★ | ★★ |
| Research module | ★ | ★★★ | ★ | ★ |
| Guest mode | ★ | ★ | ★★★ | ★ |
| Focus mode | ★★ | ★★★ | ★★ | ★★★ |
| Premium polish | ★★ | ★★★ | ★★ | ★★★ |

---

## Primary Persona for v1 MVP: **Arjun**

All P0 features optimized for Arjun's journey:
1. Google sign-in → pick placement date  
2. Striver A2Z default roadmap  
3. Dashboard with revision + streak  
4. Daily planner with 3 priorities  
5. Revision mode with confidence update  

**Next:** [04-app-flow.md](./04-app-flow.md)
