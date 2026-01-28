---
phase: 06-bug-fixes
plan: 01
subsystem: ui, data
tags: [encoding, utf8, mojibake, swiftui, gym-selector, disabled-state]

# Dependency graph
requires:
  - phase: 03-gyms
    provides: "Gym model, GymSelectorSheet, GymSelectorHeader, GymEditView"
  - phase: 05-exercise-library-rework
    provides: "presets_all.json with degree symbols in exercise notes"
provides:
  - "Clean degree symbol encoding in all 29 preset exercise entries"
  - "Gym selector disabled state during active workouts"
  - "Inline gym creation with auto-select from selector sheet"
affects: [06-bug-fixes remaining plans]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "isDisabled parameter with default value for backward-compatible disabled state"
    - "gymCountBeforeCreate snapshot for new-gym detection on sheet dismiss"
    - "Auto-select via createdDate max after inline creation"

key-files:
  created: []
  modified:
    - "GymAnals/Resources/presets_all.json"
    - "GymAnals/Features/Workout/Components/GymSelectorHeader.swift"
    - "GymAnals/Features/Workout/Views/WorkoutTabView.swift"
    - "GymAnals/Features/Workout/Views/GymSelectorSheet.swift"

key-decisions:
  - "Lock icon (lock.fill) replaces chevron when gym selector is disabled during active workout"
  - "New Gym button placed in its own section at top of GymSelectorSheet for discoverability"
  - "Auto-select uses createdDate max comparison rather than tracking the new gym ID directly"
  - "gymCountBeforeCreate snapshot pattern avoids false auto-select when no gym was actually created"

patterns-established:
  - "isDisabled with default value: backward-compatible disabled state parameter pattern"
  - "Count-before-create snapshot: detect new entity creation across sheet presentation"

# Metrics
duration: 5min
completed: 2026-01-28
---

# Phase 6 Plan 01: Character Encoding and Gym State Bugs Summary

**Fixed mojibake degree symbols in 29 exercise entries, locked gym selector during active workouts, and added inline gym creation with auto-select from selector sheet**

## Performance

- **Duration:** 5 min
- **Started:** 2026-01-28T21:42:32Z
- **Completed:** 2026-01-28T21:48:14Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments
- Replaced all mojibake degree symbols (Â° -> °) in presets_all.json with valid JSON preserved
- GymSelectorHeader shows lock icon and is non-interactive when a workout is active
- GymSelectorSheet now has "New Gym" button that opens GymEditView inline and auto-selects the newly created gym

## Task Commits

Each task was committed atomically:

1. **Task 1: Fix degree symbol encoding and gym selector disabled state** - `4b40c02` (fix) - pre-existing commit from earlier execution
2. **Task 2: Enable immediate gym selection after creation** - `33ee22a` (feat)

**Plan metadata:** pending (docs: complete plan)

## Files Created/Modified
- `GymAnals/Resources/presets_all.json` - Fixed 24 mojibake degree symbols to proper UTF-8 °
- `GymAnals/Features/Workout/Components/GymSelectorHeader.swift` - Added isDisabled parameter with lock icon and opacity reduction
- `GymAnals/Features/Workout/Views/WorkoutTabView.swift` - Passes hasActiveWorkout to GymSelectorHeader isDisabled
- `GymAnals/Features/Workout/Views/GymSelectorSheet.swift` - Added "New Gym" button with inline GymEditView and auto-select on dismiss

## Decisions Made
- Lock icon (lock.fill) replaces chevron.down when disabled, with 0.5 opacity -- provides clear visual feedback that gym switching is blocked
- "New Gym" button placed in its own Section at the top of the gym list for discoverability
- Auto-select detects new gym by comparing gym count before/after sheet dismiss and finding the gym with the most recent createdDate
- Existing "Manage Gyms" flow preserved unchanged alongside the new inline creation path

## Deviations from Plan

### Notes

Task 1 changes (degree symbol encoding fix, GymSelectorHeader disabled state, WorkoutTabView integration) were found already committed in `4b40c02` from a prior execution. These were verified correct and no re-commit was needed. Only Task 2 (GymSelectorSheet inline creation) required a new commit.

The plan estimated 24 mojibake degree symbols, but the file contains 29 total degree symbol occurrences. All mojibake instances were fixed; some entries may have already had correct encoding.

---

**Total deviations:** 0 auto-fixed
**Impact on plan:** Task 1 pre-committed; Task 2 executed as planned. No scope creep.

## Issues Encountered
- Initial build verification failed due to iPhone 16 simulator not available (OS has iPhone 17 Pro). Used iPhone 17 Pro destination instead.
- First build attempt showed pre-existing error in CustomExerciseEditView.swift (`.accentColor` type error), but this was a stale build cache issue resolved by clean build.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Encoding and gym state bugs fixed, ready for remaining 06-bug-fixes plans
- GymSelectorSheet now supports both quick inline creation and full management flow

---
*Phase: 06-bug-fixes*
*Completed: 2026-01-28*
