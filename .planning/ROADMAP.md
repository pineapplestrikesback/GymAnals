# Roadmap: GymAnals

## Overview

This roadmap delivers a native iOS workout tracker with precise per-muscle volume tracking. The journey starts with foundational data models and SwiftData persistence, progresses through exercise library and gym management, delivers the core workout logging experience, and culminates in the weighted volume analytics dashboard that differentiates this app from competitors.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Foundation** - SwiftData models, app shell, and offline persistence
- [x] **Phase 2: Exercise Library** - Pre-populated exercises with weighted muscle contributions
- [x] **Phase 3: Gyms** - Gym definitions and exercise branching per location
- [x] **Phase 4: Workout Logging** - Active workout session with fast set logging
- [x] **Phase 5: Exercise Library Rework** - Dimensions-based model with 237 exercise presets
- [ ] **Phase 6: Bug Fixes** - Critical bug fixes and UX improvements across gym, exercise, and workout flows
- [ ] **Phase 7: Analytics** - Volume dashboard with weighted muscle calculations

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
**Plans**: 5 plans

Plans:
- [x] 02-01-PLAN.md — Add ExerciseType enum and update models for SwiftData predicate filtering
- [x] 02-02-PLAN.md — Create JSON seed data and first-launch exercise seeding
- [x] 02-03-PLAN.md — Exercise library browse UI with search, filter, and muscle group tabs
- [x] 02-04-PLAN.md — Exercise detail view and muscle weight editor
- [x] 02-05-PLAN.md — Custom exercise creation wizard

### Phase 3: Gyms
**Goal**: Users can define gyms and track exercises with gym-specific weights
**Depends on**: Phase 2
**Requirements**: GYM-01, GYM-02
**Success Criteria** (what must be TRUE):
  1. User can create, edit, and delete gym definitions
  2. User can create gym-specific exercise branches (same exercise tracks different weights at different gyms)
  3. Exercise branches inherit from parent exercise but maintain independent weight history
**Plans**: 4 plans

Plans:
- [x] 03-01-PLAN.md — Add GymColor enum, update Gym model, create GymSeedService
- [x] 03-02-PLAN.md — Gym selector UI in workout tab with persistent selection
- [x] 03-03-PLAN.md — Gym management CRUD with deletion options
- [x] 03-04-PLAN.md — Wire gym management flow and add gym branches to exercise detail

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
**Plans**: 6 plans

Plans:
- [x] 04-01-PLAN.md — Timer infrastructure with Date-based persistence and notifications
- [x] 04-02-PLAN.md — ActiveWorkoutViewModel with workout lifecycle and previous value lookup
- [x] 04-03-PLAN.md — Set entry components (stepper, timer badge, set row with hints)
- [x] 04-04-PLAN.md — Exercise section and picker (collapsible sections, FAB, search)
- [x] 04-05-PLAN.md — ActiveWorkoutView with sticky header and finish flow
- [x] 04-06-PLAN.md — WorkoutTabView integration and crash recovery (checkpoint)

### Phase 5: Exercise Library Rework
**Goal**: Replace Variant-based model with dimensions-based approach, seed 237 presets
**Depends on**: Phase 4
**Requirements**: None (refactor)
**Success Criteria** (what must be TRUE):
  1. Variant and VariantMuscle models removed
  2. Exercise has embedded Dimensions struct and muscleWeights dictionary
  3. Movement has category, defaultMuscleWeights, applicableDimensions
  4. Equipment has category and properties struct
  5. 237 exercise presets seeded from presets_all.json
  6. 30 movements seeded from movements.json
  7. 22 equipment types seeded from equipment.json
  8. Fresh install scenario (breaking schema change - no migration from old Variant model)
  9. Custom exercise creation wizard updated for new model
**Plans**: 10 plans

Plans:
- [x] 05-01-PLAN.md — Create supporting enums and embedded Codable structs (Wave 1)
- [x] 05-02-PLAN.md — Add 3 new muscles to Muscle enum (Wave 1)
- [x] 05-03-PLAN.md — Update Equipment model with category and properties (Wave 2)
- [x] 05-04-PLAN.md — Update Movement model with category and defaults (Wave 2)
- [x] 05-05-PLAN.md — Transform Exercise model to dimensions-based schema (Wave 3)
- [x] 05-06-PLAN.md — Remove Variant/VariantMuscle, update PersistenceController (Wave 4)
- [x] 05-07-PLAN.md — Create new seed services for movements, equipment, presets (Wave 5)
- [x] 05-08-PLAN.md — Copy JSON resources and update app seeding (Wave 5)
- [x] 05-09-PLAN.md — Update exercise creation wizard for new model (Wave 6)
- [x] 05-10-PLAN.md — Update exercise library views for new model (Wave 6)

### Phase 6: Bug Fixes
**Goal**: Resolve 20 critical bugs and UX issues discovered in Phases 1-5 to ensure production-ready quality
**Depends on**: Phase 5
**Requirements**: None (bug fixes)
**Success Criteria** (what must be TRUE):
  1. Gym switching updates immediately in workout view and is disabled during active workouts
  2. New gyms can be immediately selected after creation
  3. Character encoding issues (degree symbols) are fixed
  4. Exercise library search is available from all entry points
  5. Muscle weight sliders are functional and properly editable
  6. Custom exercises are fully editable (name, equipment, movement, etc.)
  7. Exercise selection in workout flow supports multi-select with checkboxes
  8. Set logging layout displays previous workout data (Hevy-style)
  9. Rest timer is visible and editable during workouts
  10. Gym indicator visible in workout logging header with color theming
**Plans**: 4 plans

Plans:
- [ ] 06-01-PLAN.md — Fix encoding, gym selector disabled state, and new gym auto-select
- [ ] 06-02-PLAN.md — Muscle weight slider UX and custom exercise edit view
- [ ] 06-03-PLAN.md — Hevy-style set layout with column headers and inline previous data
- [ ] 06-04-PLAN.md — Multi-select picker, always-visible timer, and gym indicator in header

### Phase 7: Analytics
**Goal**: Users can see weekly volume per muscle calculated from weighted contributions
**Depends on**: Phase 6
**Requirements**: ANAL-01, ANAL-02
**Success Criteria** (what must be TRUE):
  1. Volume dashboard shows weekly sets per muscle calculated from weighted exercise contributions
  2. User can see which muscles are undertrained/overtrained relative to their training
  3. User can browse workout history by date
  4. User can view details of any past workout
**Plans**: TBD

Plans:
- [ ] 07-01: TBD
- [ ] 07-02: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation | 3/3 | ✓ Complete | 2026-01-26 |
| 2. Exercise Library | 5/5 | ✓ Complete | 2026-01-27 |
| 3. Gyms | 4/4 | ✓ Complete | 2026-01-27 |
| 4. Workout Logging | 6/6 | ✓ Complete | 2026-01-28 |
| 5. Exercise Library Rework | 10/10 | ✓ Complete | 2026-01-28 |
| 6. Bug Fixes | 0/4 | Not started | - |
| 7. Analytics | 0/TBD | Not started | - |

---
*Roadmap created: 2026-01-26*
*Last updated: 2026-01-28 — Phase 6 planned with 4 plans in 2 waves*
