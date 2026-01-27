---
phase: 02-exercise-library
plan: 02
subsystem: database
tags: [swiftdata, json, seeding, exercises, muscle-weights]

# Dependency graph
requires:
  - phase: 01-foundation
    provides: SwiftData models (Movement, Variant, Equipment, Exercise, VariantMuscle)
provides:
  - exercises.json with 94 pre-populated exercises and muscle weights
  - ExerciseSeedService for first-launch database population
  - SeedData decodable structs for JSON parsing
affects: [02-03-browse-filter, 02-04-custom-exercises]

# Tech tracking
tech-stack:
  added: []
  patterns: [first-launch-seeding, movement-variant-hierarchy]

key-files:
  created:
    - GymAnals/Resources/exercises.json
    - GymAnals/Services/Seed/ExerciseSeedService.swift
    - GymAnals/Services/Seed/SeedData.swift
  modified:
    - GymAnals/App/GymAnalsApp.swift

key-decisions:
  - "Check Movement count == 0 for first-launch detection"
  - "Set primaryMuscleGroupRaw from highest weighted muscle in variant"
  - "Create Exercise for each equipment+variant combination"

patterns-established:
  - "Seed service pattern: static seedIfNeeded(context:) called from App init"
  - "JSON structure: equipment array + movements with nested variants"

# Metrics
duration: 8min
completed: 2026-01-27
---

# Phase 2 Plan 2: Seed Data Infrastructure Summary

**First-launch seeding with 94 exercises (38 movements, 5 equipment types) transformed from curated source JSON with muscle weight mappings**

## Performance

- **Duration:** 8 min
- **Started:** 2026-01-27T12:38:00Z
- **Completed:** 2026-01-27T12:46:00Z
- **Tasks:** 3
- **Files modified:** 4

## Accomplishments

- Transformed 70 source exercises into 38 movements with variants
- Mapped all muscle names to iOS Muscle enum rawValues
- Created 94 exercise combinations (variant x equipment)
- Implemented first-launch-only seeding with Movement count check
- Integrated seed service into app startup lifecycle

## Task Commits

Each task was committed atomically:

1. **Task 1: Create SeedData decodable structs** - `ae3c619` (feat)
2. **Task 2: Transform source JSON to iOS format** - `b5761bd` (feat)
3. **Task 3: Create ExerciseSeedService and integrate into app** - `884de40` (feat)

## Files Created/Modified

- `GymAnals/Services/Seed/SeedData.swift` - Decodable structs for JSON parsing (SeedData, SeedMovement, SeedVariant, SeedMuscleWeight, SeedEquipment)
- `GymAnals/Resources/exercises.json` - 1876 lines of transformed exercise data with muscle weights
- `GymAnals/Services/Seed/ExerciseSeedService.swift` - First-launch seeding service with seedIfNeeded()
- `GymAnals/App/GymAnalsApp.swift` - Added seed call in init()

## Decisions Made

- **First-launch detection:** Check Movement fetchCount == 0 rather than UserDefaults flag - simpler and more reliable
- **Primary muscle group:** Derive from highest weighted muscle in variant's muscleWeights array
- **Equipment inference:** Parsed from exercise names (Dumbbell, Cable, Machine keywords) with Barbell+Dumbbell as default for common exercises
- **Exercise type inference:** Pull Up/Chin Up/Push Up/Dip = bodyweightReps, everything else = weightReps

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- **Resources directory didn't exist:** Created directory before writing exercises.json
- **Skipped Hip Adduction exercise:** Only had unmapped muscles (Adductors, Hip Flexors) - expected behavior per plan

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Database seeds 94 exercises on first launch with proper muscle weights
- Ready for exercise browsing UI implementation (02-03)
- primaryMuscleGroupRaw populated for filtering by muscle group
- Equipment, Movement, Variant, Exercise hierarchy established

---
*Phase: 02-exercise-library*
*Completed: 2026-01-27*
