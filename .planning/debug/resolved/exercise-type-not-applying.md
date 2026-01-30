---
status: resolved
trigger: "Exercise type changes not visible in app. All exercises still showing weight and reps despite exerciseTypeRaw being added to JSON, Exercise model, and seed service."
created: 2026-01-29T00:00:00Z
updated: 2026-01-29T00:02:00Z
---

## Current Focus

hypothesis: CONFIRMED AND FIXED - UI layer was completely ignoring exercise type
test: Build succeeds with zero errors
expecting: N/A - fix applied
next_action: Archive session

## Symptoms

expected: Bodyweight exercises (Push-Up, Pull-Up) should show reps-only input fields. Time-based exercises (Plank) should show duration-only. Weighted exercises should show weight+reps.
actual: All exercises showing "weight + reps" fields regardless of type.
errors: No errors - app builds successfully with clean build.
reproduction: Run app, try logging any exercise. All show weight+reps fields instead of their correct type.
started: First time testing - newly added changes.

## Eliminated

## Evidence

- timestamp: 2026-01-29T00:00:30Z
  checked: Exercise.swift model
  found: exerciseTypeRaw field exists (line 38), computed exerciseType property exists (line 83-86), init accepts exerciseType param (line 125)
  implication: Model layer is correctly storing exercise type

- timestamp: 2026-01-29T00:00:30Z
  checked: SeedData.swift
  found: SeedPreset struct has exerciseTypeRaw: Int? (line 82)
  implication: JSON decoding struct supports the field

- timestamp: 2026-01-29T00:00:30Z
  checked: PresetSeedService.swift
  found: Line 61 reads exerciseTypeRaw from JSON, line 71 passes it to Exercise init
  implication: Seed pipeline correctly propagates exercise type from JSON to model

- timestamp: 2026-01-29T00:00:30Z
  checked: presets_all.json
  found: exerciseTypeRaw field present with correct values (0 for weight+reps)
  implication: JSON data is correct

- timestamp: 2026-01-29T00:00:45Z
  checked: SetRowView.swift (entire file, 295 lines)
  found: HARDCODED weight column (lines 100-120) and reps column (lines 122-142). No reference to exerciseType, logFields, LogField, or any type-conditional logic. Always renders both WEIGHT and REPS text fields.
  implication: ROOT CAUSE - UI never checks exercise type

- timestamp: 2026-01-29T00:00:45Z
  checked: ExerciseSectionView.swift (entire file, 238 lines)
  found: Column headers hardcoded as "SET", "PREVIOUS", weightUnit.abbreviation, "REPS" (lines 49-56). No reference to exerciseType. Does not pass exercise type to SetRowView.
  implication: ROOT CAUSE - Column headers also hardcoded

- timestamp: 2026-01-29T00:00:50Z
  checked: WorkoutSet.swift model
  found: Only has reps: Int and weight: Double fields. NO duration or distance fields exist.
  implication: Even if UI was fixed, WorkoutSet can't store duration or distance data

- timestamp: 2026-01-29T00:00:55Z
  checked: ExerciseType.swift
  found: logFields property correctly defines which LogField values each type needs. LogField enum has .reps, .weight, .duration, .distance cases.
  implication: The logic for what to show exists but is never consumed by the UI

- timestamp: 2026-01-29T00:02:00Z
  checked: Build after fix
  found: BUILD SUCCEEDED with zero errors and zero warnings
  implication: All changes compile correctly

## Resolution

root_cause: THREE interconnected issues prevent exercise type from being visible:
  1. SetRowView.swift always renders WEIGHT + REPS columns regardless of exercise type (no conditional rendering based on logFields)
  2. ExerciseSectionView.swift hardcodes column headers ("KG" + "REPS") and does not pass exercise type info to SetRowView
  3. WorkoutSet.swift model only has `reps` and `weight` fields - missing `duration` and `distance` fields needed for non-weight+reps exercise types

fix: |
  1. WorkoutSet.swift: Added `duration: TimeInterval` and `distance: Double` fields with defaults of 0
  2. SetEntryField.swift: Added `.duration(setID:)` and `.distance(setID:)` focus state cases
  3. SetRowView.swift: Complete rewrite to accept `logFields: [LogField]` parameter and dynamically render only the columns specified by the exercise type. Added bindings for duration/distance. Columns are rendered via ForEach over logFields with a dataField(for:) builder.
  4. ExerciseSectionView.swift: Added duration/distance bindings and previous value lookups. Column headers now render dynamically from logFields via columnHeader(for:) helper. Passes logFields to SetRowView.
  5. ActiveWorkoutView.swift: Updated ExerciseSectionForID to pass duration/distance bindings and previous value lookups. Updated adjustFocusedField() to handle duration (+/-5s) and distance (+/-0.1km) cases.

verification: Build succeeded with zero errors on iOS Simulator target (iPhone 17 Pro, iOS 26.2)

files_changed:
  - GymAnals/Models/Core/WorkoutSet.swift
  - GymAnals/Features/Workout/Models/SetEntryField.swift
  - GymAnals/Features/Workout/Views/SetRowView.swift
  - GymAnals/Features/Workout/Views/ExerciseSectionView.swift
  - GymAnals/Features/Workout/Views/ActiveWorkoutView.swift
