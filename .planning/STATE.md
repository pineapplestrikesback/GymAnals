# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-01-26)

**Core value:** Precise per-muscle volume tracking with user-defined muscles and weighted set contributions
**Current focus:** Phase 3 - Gyms (IN PROGRESS)

## Current Position

Phase: 3 of 5 (Gyms)
Plan: 3 of 4 in current phase
Status: In progress
Last activity: 2026-01-27 - Completed 03-03-PLAN.md (Gym Management UI)

Progress: [██████████░] ~55% (10/~18 total plans estimate)

## Performance Metrics

**Velocity:**
- Total plans completed: 10
- Average duration: 8.7 min
- Total execution time: 87 min

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 01-foundation | 3 | 13 min | 4.3 min |
| 02-exercise-library | 5 | 61 min | 12.2 min |
| 03-gyms | 2 | 13 min | 6.5 min |

**Recent Trend:**
- Last 5 plans: 02-03 (14 min), 02-04 (9 min), 02-05 (27 min), 03-01 (6 min), 03-03 (7 min)
- Trend: Gym plans running fast (model and UI patterns established)

*Updated after each plan completion*

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- [Init]: SwiftData chosen over GRDB for Apple ecosystem alignment
- [Init]: User-defined muscles with weighted contributions (core differentiator)
- [Init]: Gym-specific exercise branches to solve multi-gym variance
- [01-01]: Fully qualified enum defaults for SwiftData macro compatibility
- [01-01]: 31-muscle taxonomy balanced for accuracy and usability
- [01-01]: Cascade delete on parent relationships only
- [01-02]: Feature-based folder structure for scalability
- [01-02]: Tab enum centralizes tab configuration (title, icon)
- [01-02]: NavigationStack per tab for independent navigation stacks
- [01-03]: Database in Application Support (not Documents) per Apple guidelines
- [01-03]: Singleton PersistenceController with @MainActor for thread safety
- [01-03]: In-memory preview container pattern for SwiftUI previews
- [02-01]: RawValue storage pattern for SwiftData enum predicate filtering
- [02-01]: Computed properties maintain type-safe enum API over rawValue storage
- [02-01]: Optional enum with fallback pattern (primaryMuscleGroup derives from muscle weights if nil)
- [02-02]: First-launch detection via Movement fetchCount == 0
- [02-02]: Primary muscle group derived from highest weighted muscle in variant
- [02-02]: Seed service pattern: static seedIfNeeded(context:) called from App init
- [02-03]: Task-based debounce pattern for @Observable (no Combine publishers)
- [02-03]: Subview @Query pattern for dynamic filtering
- [02-03]: In-memory search filter (SwiftData predicate expression limits)
- [02-04]: In-memory sorting for favorites (SortDescriptor<Bool> requires NSObject)
- [02-04]: @Observable ViewModel with change tracking for SwiftData edits
- [02-04]: sensoryFeedback(.impact) triggered by state change for slider haptics
- [02-05]: List/ForEach pattern for SwiftUI Binding initializer disambiguation
- [02-05]: Wizard ViewModel holds all step state, steps are pure views
- [02-05]: FlowLayout custom Layout for suggestion chips
- [03-01]: GymColor rawValue storage pattern for SwiftData predicate compatibility
- [03-01]: Default gym marked with isDefault=true to prevent deletion
- [03-01]: GymSeedService called before ExerciseSeedService in app init
- [03-03]: GymColorPicker uses .palette picker style for compact color display
- [03-03]: Deletion options via confirmationDialog with three choices
- [03-03]: Subview extraction pattern for ForEach SwiftData iteration

### Pending Todos

None yet.

### Blockers/Concerns

- Plan 03-02 has uncommitted Task 2 files (GymSelectorHeader, GymSelectorSheet, WorkoutTabView) that should be committed

## Session Continuity

Last session: 2026-01-27
Stopped at: Completed 03-03-PLAN.md (Gym Management UI)
Resume file: None
