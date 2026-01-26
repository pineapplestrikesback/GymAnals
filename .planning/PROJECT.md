# GymAnals

## What This Is

A native iOS workout tracker built with SwiftUI that solves the muscle volume tracking problem. Unlike existing apps that use crude "primary/secondary" muscle classifications, this app lets users define their own muscle list with precise contribution ratios per exercise — enabling accurate weekly volume tracking to inform training decisions.

## Core Value

Precise per-muscle volume tracking with user-defined muscles and weighted set contributions. If the app tracks volume accurately, users can make informed decisions about what to train next.

## Requirements

### Validated

- ✓ SwiftUI app shell with iOS 26.2 target — existing
- ✓ Xcode project structure with test targets — existing

### Active

- [ ] User can define custom muscles (not fixed list like "shoulders")
- [ ] User can create exercises with weighted muscle contributions (e.g., bench: chest 1.0, front delt 0.5, triceps 0.3)
- [ ] User can define gyms they train at
- [ ] User can create gym-specific exercise branches (same exercise, different weight tracking per gym)
- [ ] User can log workouts with sets, reps, and weight
- [ ] User can see weekly volume by muscle (calculated from logged sets × contribution weights)
- [ ] User can see exercise progress over time (weight/reps history)
- [ ] User can view workout history (what did I do on Tuesday?)

### Out of Scope

- watchOS companion — v2, after iOS core is solid
- Workout templates/programs — v2, freestyle mode first
- Muscle balance analysis — v2, requires volume tracking foundation
- HealthKit integration — v2, nice-to-have
- Social features — not aligned with personal tool vision
- Cloud sync — local-first, sync later if needed

## Context

**User background:** The developer uses Hevy currently and is frustrated by:
1. Crude volume tracking (only primary=1.0 and secondary=0.5 options)
2. Overly broad muscle categories ("shoulders" instead of anterior/lateral/posterior delt)
3. No per-gym exercise tracking (same exercise at different gyms requires duplicate entries)

**Workflow:** Primarily freestyle training — start workout, check current volume by muscle, decide what needs work, log exercises. Templates are a future addition for users who want structure.

**Learning goals:** This is also a SwiftUI/iOS learning project with production aspirations.

## Constraints

- **Platform**: iOS 26.2+, SwiftUI only (no UIKit unless necessary)
- **Architecture**: MVVM with @Observable, feature-based folder structure
- **Persistence**: SwiftData (local-first, no cloud sync for v1)
- **Dependencies**: Minimal — prefer Apple frameworks over third-party

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| User-defined muscles | Maximum flexibility for users who know anatomy | — Pending |
| Weighted set contributions | More accurate than binary primary/secondary | — Pending |
| Gym branches | Solves multi-gym equipment variance problem | — Pending |
| iOS first, watchOS later | Get core right before adding complexity | — Pending |
| SwiftData for persistence | Modern Apple solution, good SwiftUI integration | — Pending |
| Freestyle mode first | Matches developer's workflow, templates can layer on | — Pending |

---
*Last updated: 2026-01-26 after initialization*
