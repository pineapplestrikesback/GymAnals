---
phase: 05-exercise-library-rework
plan: 06
subsystem: database
tags: [swiftdata, schema, cleanup, variant-removal]

# Dependency graph
requires:
  - phase: 05-exercise-library-rework
    provides: Exercise model with direct Movement relationship and muscleWeights dictionary (05-05)
provides:
  - Variant.swift and VariantMuscle.swift deleted from codebase
  - PersistenceController schema without deprecated models (7 models)
affects: [05-07-equipment-seed, 05-08-exercise-presets, 05-10-final-integration]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Schema pruning after model deprecation"

key-files:
  created: []
  modified:
    - "GymAnals/Services/Persistence/PersistenceController.swift"
  deleted:
    - "GymAnals/Models/Core/Variant.swift"
    - "GymAnals/Models/Core/VariantMuscle.swift"

key-decisions:
  - "No migration plan needed - fresh install assumption for Phase 5 rework"

patterns-established:
  - "Remove deprecated models from schema after relationship refactoring"

# Metrics
duration: 4min
completed: 2026-01-28
---

# Phase 5 Plan 06: Remove Variant/VariantMuscle Models Summary

**Deleted Variant.swift and VariantMuscle.swift, pruned PersistenceController schema from 9 to 7 models**

## Performance

- **Duration:** 4 min
- **Started:** 2026-01-28T18:46:48Z
- **Completed:** 2026-01-28T18:51:22Z
- **Tasks:** 2
- **Files modified:** 1 modified, 2 deleted

## Accomplishments
- Deleted Variant.swift (51 lines) and VariantMuscle.swift (25 lines) from Models/Core
- Removed Variant.self and VariantMuscle.self from both PersistenceController schema arrays (main and preview)
- PersistenceController now registers exactly 7 models: Movement, Equipment, Exercise, Gym, Workout, WorkoutSet, ExerciseWeightHistory
- Build verified successful with clean compilation

## Task Commits

Each task was committed atomically:

1. **Task 1: Delete Variant and VariantMuscle files** - `0ec79bb` (feat)
2. **Task 2: Update PersistenceController schema** - `d70791b` (feat)

## Files Created/Modified
- `GymAnals/Models/Core/Variant.swift` - DELETED (deprecated model, replaced by Exercise.dimensions + Exercise.muscleWeights)
- `GymAnals/Models/Core/VariantMuscle.swift` - DELETED (deprecated junction model, replaced by Exercise.muscleWeights dictionary)
- `GymAnals/Services/Persistence/PersistenceController.swift` - Removed Variant.self and VariantMuscle.self from both schema arrays

## Decisions Made
- No migration plan needed for existing data - Phase 5 is a restructuring assumed to be done before production release

## Deviations from Plan
None - plan executed exactly as written.

## Issues Encountered
- Build command initially used unavailable simulator name (iPhone 16); used iPhone 17 Pro instead. Build succeeded.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Codebase cleaned of deprecated Variant models
- PersistenceController schema is lean and accurate
- Remaining Variant references exist only in ExerciseSeedService.swift and SeedData.swift (addressed by downstream plans 05-07 through 05-10)
- Ready for Wave 5 seed service rewrites (05-07, 05-08)

---
*Phase: 05-exercise-library-rework*
*Completed: 2026-01-28*
