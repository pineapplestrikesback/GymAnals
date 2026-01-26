# Roadmap: GymAnals

## Overview

This roadmap delivers a native iOS workout tracker with precise per-muscle volume tracking. The journey starts with foundational data models and SwiftData persistence, progresses through exercise library and gym management, delivers the core workout logging experience, and culminates in the weighted volume analytics dashboard that differentiates this app from competitors.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Foundation** - SwiftData models, app shell, and offline persistence
- [ ] **Phase 2: Exercise Library** - Pre-populated exercises with weighted muscle contributions
- [ ] **Phase 3: Gyms** - Gym definitions and exercise branching per location
- [ ] **Phase 4: Workout Logging** - Active workout session with fast set logging
- [ ] **Phase 5: Analytics** - Volume dashboard with weighted muscle calculations

## Phase Details

### Phase 1: Foundation
**Goal**: Establish SwiftData persistence with all core models and a navigable app shell
**Depends on**: Nothing (first phase)
**Requirements**: DATA-01
**Success Criteria** (what must be TRUE):
  1. App launches to a tab-based navigation shell with placeholder tabs
  2. SwiftData ModelContainer initializes without errors
  3. All core models (Movement, Variant, VariantMuscle, Equipment, Exercise, Gym, Workout, WorkoutSet, ExerciseWeightHistory) exist with proper relationships
  4. App works fully offline with local persistence
**Plans**: 3 plans

Plans:
- [x] 01-01-PLAN.md — Create SwiftData models and muscle taxonomy enums
- [x] 01-02-PLAN.md — Create tab-based navigation shell with placeholder views
- [x] 01-03-PLAN.md — Configure SwiftData persistence and inject into app

### Phase 2: Exercise Library
**Goal**: Users can browse, search, and create exercises with weighted muscle contributions
**Depends on**: Phase 1
**Requirements**: EXER-01, EXER-02, EXER-03, EXER-04, EXER-05
**Success Criteria** (what must be TRUE):
  1. User can browse a pre-populated library of 200+ exercises
  2. User can search and filter exercises by name or muscle group
  3. User can create custom exercises with name and category
  4. User can view and edit weighted muscle contributions for any exercise (e.g., bench: chest 1.0, front delt 0.5, triceps 0.3)
  5. Pre-defined muscle taxonomy exists with granular options (anterior/lateral/posterior delt, upper/lower chest, etc.)
**Plans**: TBD

Plans:
- [ ] 02-01: TBD
- [ ] 02-02: TBD
- [ ] 02-03: TBD

### Phase 3: Gyms
**Goal**: Users can define gyms and track exercises with gym-specific weights
**Depends on**: Phase 2
**Requirements**: GYM-01, GYM-02
**Success Criteria** (what must be TRUE):
  1. User can create, edit, and delete gym definitions
  2. User can create gym-specific exercise branches (same exercise tracks different weights at different gyms)
  3. Exercise branches inherit from parent exercise but maintain independent weight history
**Plans**: TBD

Plans:
- [ ] 03-01: TBD

### Phase 4: Workout Logging
**Goal**: Users can log complete workouts with fast set entry and crash recovery
**Depends on**: Phase 3
**Requirements**: LOG-01, LOG-02, LOG-03, LOG-04, LOG-05, LOG-06, LOG-07, LOG-08
**Success Criteria** (what must be TRUE):
  1. User can start a workout (optionally selecting a gym)
  2. User can add exercises to the active workout from the library
  3. User can log sets with reps and weight in under 10 seconds per set
  4. User can see previous workout numbers for each exercise inline
  5. User can edit and delete sets during the active workout
  6. Rest timer starts between sets with configurable duration and notification
  7. User can finish and save workout to history
  8. Active workout auto-saves after each set (crash recovery works)
**Plans**: TBD

Plans:
- [ ] 04-01: TBD
- [ ] 04-02: TBD
- [ ] 04-03: TBD
- [ ] 04-04: TBD

### Phase 5: Analytics
**Goal**: Users can see weekly volume per muscle calculated from weighted contributions
**Depends on**: Phase 4
**Requirements**: ANAL-01, ANAL-02
**Success Criteria** (what must be TRUE):
  1. Volume dashboard shows weekly sets per muscle calculated from weighted exercise contributions
  2. User can see which muscles are undertrained/overtrained relative to their training
  3. User can browse workout history by date
  4. User can view details of any past workout
**Plans**: TBD

Plans:
- [ ] 05-01: TBD
- [ ] 05-02: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4 -> 5

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation | 3/3 | ✓ Complete | 2026-01-26 |
| 2. Exercise Library | 0/TBD | Not started | - |
| 3. Gyms | 0/TBD | Not started | - |
| 4. Workout Logging | 0/TBD | Not started | - |
| 5. Analytics | 0/TBD | Not started | - |

---
*Roadmap created: 2026-01-26*
*Last updated: 2026-01-26 — Phase 1 complete*
