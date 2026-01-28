---
phase: "06"
plan: "04"
subsystem: workout-logging
tags: [multi-select, exercise-picker, rest-timer, gym-indicator, workout-header]
depends_on:
  requires: ["06-03"]
  provides: ["multi-select-exercise-picker", "always-visible-rest-timer", "gym-indicator-header"]
  affects: []
tech-stack:
  added: []
  patterns: ["multi-select-with-checkboxes", "always-visible-placeholder", "manual-timer-start"]
key-files:
  created: []
  modified:
    - GymAnals/Features/Workout/Views/ExercisePickerSheet.swift
    - GymAnals/Features/Workout/Components/WorkoutHeader.swift
    - GymAnals/Features/Workout/Views/ActiveWorkoutView.swift
decisions:
  - id: "06-04-01"
    title: "Multi-select with Set<String> for selectedExerciseIDs"
    context: "Need multi-select in picker sheet"
    choice: "Set<String> tracking selected IDs with checkmark circle toggle"
    rationale: "Efficient O(1) lookup for selection state; IDs match Exercise.id String type"
  - id: "06-04-02"
    title: "Always-visible timer with placeholder"
    context: "Timer section was conditionally hidden, causing layout shifts"
    choice: "'--:--' placeholder always shown, tappable to start manual 120s timer"
    rationale: "Prevents layout shifts; provides persistent tap target for manual rest"
  - id: "06-04-03"
    title: "Gym indicator as color dot + name row above stats"
    context: "Users need gym context during workout"
    choice: "Circle fill with gym.colorTag.color + name text in secondary style"
    rationale: "Compact, color-coded indicator matches gym color system from Phase 3"
metrics:
  duration: "9 min"
  completed: "2026-01-28"
---

# Phase 6 Plan 04: Multi-Select Exercise Picker, Timer, and Gym Indicator Summary

Multi-select exercise picker with muscle group filter tabs, always-visible rest timer placeholder, and gym color indicator in workout header.

## Tasks Completed

### Task 1: Multi-select exercise picker with muscle group filter tabs
**Commit:** `13a16b8`

Rewrote ExercisePickerSheet for multi-select behavior:
- Changed callback from `(Exercise) -> Void` to `([Exercise]) -> Void`
- Added `selectedExerciseIDs: Set<String>` for tracking selections
- Added `selectedMuscleGroup: MuscleGroup?` state with MuscleGroupFilterTabs above the List
- Each row now shows checkmark circle (filled when selected, outline when not)
- Toolbar "Add (N)" confirmation button calls batch callback, disabled when empty
- Cancel button preserved in `.cancellationAction` placement
- `filteredExercises` filters by muscle group and search text, limiting to 50 only when no filters active
- Updated ActiveWorkoutView to use multi-exercise callback with `withAnimation` for smooth batch add

### Task 2: Always-visible rest timer and gym indicator in workout header
**Commit:** `0c401c1`

Enhanced WorkoutHeader with gym indicator and persistent timer:
- Added `gym: Gym?` parameter with color dot (Circle fill) and name display row
- Timer section always visible: shows countdown when active, "--:--" placeholder when inactive
- Added `onStartManualTimer` callback for tapping timer area when no timer active
- ActiveWorkoutView passes `viewModel.activeWorkout?.gym` and starts 120s manual timer on tap
- VStack layout with conditional gym row above HStack stats row
- Updated previews with new parameters

## Deviations from Plan

None - plan executed exactly as written.

## Success Criteria Verification

1. **SC4**: Exercise picker has muscle group filter tabs matching the library view - MuscleGroupFilterTabs reused
2. **SC7**: Exercise picker supports multi-select with checkboxes and batch "Add (N)" confirmation - Set<String> + checkmark.circle.fill
3. **SC9**: Rest timer section always visible in header, tappable to start manual timer - "--:--" placeholder + onStartManualTimer
4. **SC10**: Gym name with color dot visible in workout header - Circle fill + gym.name

## Files Modified

| File | Changes |
|------|---------|
| ExercisePickerSheet.swift | Rewritten for multi-select with muscle group tabs |
| WorkoutHeader.swift | Added gym indicator row and always-visible timer |
| ActiveWorkoutView.swift | Updated picker callback and header parameters |

## Next Phase Readiness

Phase 6 (Bug Fixes) is now complete. All 4 plans executed. Ready for Phase 7 (Analytics).
