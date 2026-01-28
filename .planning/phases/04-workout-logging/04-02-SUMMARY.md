---
phase: 04-workout-logging
plan: 02
subsystem: viewmodel
tags: [swiftdata, observable, workout, state-management]

# Dependency graph
requires:
  - phase: 04-01
    provides: Workout/WorkoutSet models, timer constants
  - phase: 03-gyms
    provides: Gym model and relationships
provides:
  - ActiveWorkoutViewModel with workout lifecycle management
  - Exercise add/remove/reorder functionality
  - Set add/delete with auto-numbering
  - Gym-specific previous workout value lookup
  - Crash recovery via loadActiveWorkout()
affects: [04-03-active-workout-ui, 04-04-set-logging]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "@Observable @MainActor ViewModel pattern"
    - "SwiftData predicate-based queries"
    - "Gym-specific workout history lookup"

key-files:
  created:
    - GymAnals/Features/Workout/ViewModels/ActiveWorkoutViewModel.swift
  modified: []

key-decisions:
  - "Exercise order tracked as [UUID] array for display sequence"
  - "Pre-fill new sets from previous workout values at same gym"
  - "Crash recovery via isActive == true query on init"

patterns-established:
  - "Previous workout lookup: filter by gym, sort by endDate, find first with matching exercise"
  - "Set renumbering on delete: decrement setNumber for all sets after deleted"

# Metrics
duration: 7min
completed: 2026-01-28
---

# Phase 04 Plan 02: Active Workout ViewModel Summary

**ActiveWorkoutViewModel with workout lifecycle (start/finish/discard), exercise ordering, set management, and gym-specific previous workout value lookup for pre-fill and hints**

## Performance

- **Duration:** 7 min
- **Started:** 2026-01-28T09:17:29Z
- **Completed:** 2026-01-28T09:24:30Z
- **Tasks:** 3
- **Files created:** 1

## Accomplishments
- Workout lifecycle: start, finish, discard with proper state cleanup
- Crash recovery: loads any active workout on init
- Exercise management: add, remove, reorder with display order tracking
- Set management: add with auto-numbering, delete with renumbering
- Gym-specific previous workout lookup for pre-filling values

## Task Commits

Each task was committed atomically:

1. **Task 1: Create ActiveWorkoutViewModel core structure** - `324d4c0` (feat)
2. **Task 2+3: Add exercise/set management and previous workout lookup** - `0a5071b` (feat)

**Plan metadata:** pending

## Files Created/Modified
- `GymAnals/Features/Workout/ViewModels/ActiveWorkoutViewModel.swift` - Core workout state management ViewModel with 293 lines

## Decisions Made
- Exercise order tracked as UUID array for user-controlled display sequence
- Expanded exercises tracked as Set<UUID> for O(1) lookup
- Pre-fill sets from previous workout at same gym (gym-specific history)
- Fetch limit of 50 workouts for previousSets query (performance bound)

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- ActiveWorkoutViewModel ready for UI integration in 04-03
- All must_haves verified:
  - ViewModel loads existing active workout on init (crash recovery)
  - Starting workout creates and inserts Workout into context
  - Previous workout values are gym-specific
  - Exercise order tracks display sequence
- 293 lines exceeds min_lines: 150 requirement

---
*Phase: 04-workout-logging*
*Completed: 2026-01-28*
