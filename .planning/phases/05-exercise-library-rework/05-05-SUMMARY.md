---
phase: "05"
plan: "05"
subsystem: data-model
tags: [swiftdata, exercise, dimensions, muscleWeights, refactor]
depends_on:
  requires: ["05-01", "05-02", "05-03", "05-04"]
  provides: ["Refactored Exercise model with dimensions, muscleWeights, direct movement relationship"]
  affects: ["05-06", "05-07", "05-08", "05-09", "05-10"]
tech_stack:
  added: []
  patterns: ["embedded Codable struct for dimensions", "dictionary-based muscle weights", "String id for preset identifiers", "computed isUnilateral from dimensions"]
files:
  created: []
  modified:
    - GymAnals/Models/Core/Exercise.swift
    - GymAnals/Models/Core/Movement.swift
    - GymAnals/Models/Core/Variant.swift
    - GymAnals/Features/ExerciseLibrary/ViewModels/ExerciseCreationViewModel.swift
    - GymAnals/Features/ExerciseLibrary/ViewModels/MuscleWeightViewModel.swift
    - GymAnals/Features/ExerciseLibrary/Views/ExerciseCreationWizard.swift
    - GymAnals/Features/ExerciseLibrary/Views/ExerciseDetailView.swift
    - GymAnals/Features/ExerciseLibrary/Views/ExerciseRow.swift
    - GymAnals/Features/ExerciseLibrary/Views/ExerciseSearchResultsView.swift
    - GymAnals/Features/ExerciseLibrary/Views/MuscleWeightEditorView.swift
    - GymAnals/Features/ExerciseLibrary/Views/WizardSteps/VariationStepView.swift
    - GymAnals/Features/Workout/ViewModels/ActiveWorkoutViewModel.swift
    - GymAnals/Features/Workout/Views/ActiveWorkoutView.swift
    - GymAnals/Features/Workout/Views/ExerciseSectionView.swift
    - GymAnals/Services/Seed/ExerciseSeedService.swift
decisions:
  - id: "05-05-01"
    description: "Exercise.id changed from UUID to String to support snake_case preset identifiers"
    rationale: "Presets use human-readable IDs like 'barbell_flat_bench_press'; custom exercises use UUID().uuidString"
  - id: "05-05-02"
    description: "displayName changed from computed (variant+equipment concat) to stored property"
    rationale: "Presets have curated display names; removes dependency on variant"
  - id: "05-05-03"
    description: "muscleWeights stored as [String: Double] dictionary instead of VariantMuscle relationship"
    rationale: "Simpler model, fewer entities, dictionary keys match Muscle.rawValue for type-safe access"
  - id: "05-05-04"
    description: "isUnilateral changed from stored Bool to computed from dimensions.laterality"
    rationale: "Single source of truth - laterality dimension already captures this information"
  - id: "05-05-05"
    description: "exerciseOrder/expandedExercises changed from [UUID]/Set<UUID> to [String]/Set<String>"
    rationale: "Exercise.id is now String; all ID tracking must match"
metrics:
  duration: "15 min"
  completed: "2026-01-28"
---

# Phase 5 Plan 5: Exercise Model Refactor Summary

**One-liner:** Exercise model rewritten with String id, embedded Dimensions struct, muscleWeights dictionary, and direct Movement relationship replacing Variant indirection.

## What Was Done

### Task 1: Rewrite Exercise model with new schema

Completely rewrote Exercise.swift to match the preset-based schema:

**New properties added:**
- `id: String` (was UUID) - supports snake_case for presets, UUID strings for custom
- `displayName: String` - stored property (was computed from variant+equipment)
- `searchTerms: [String]` - alternative names for search
- `dimensions: Dimensions` - embedded Codable struct (replaces Variant reference)
- `muscleWeights: [String: Double]` - dictionary (replaces VariantMuscle relationship)
- `popularityRaw: String` with computed `popularity` accessor
- `notes: String` and `sources: [String]` - metadata fields
- `isBuiltIn: Bool` - flag for preset vs custom exercises
- `movement: Movement?` - direct relationship (was via Variant)
- `gym: Gym?` - for gym-specific tracking

**Computed properties added:**
- `isUnilateral` - derived from `dimensions.laterality == "unilateral"`
- `primaryMuscleGroup` - derived from highest weighted muscle in dictionary
- `sortedMuscleWeights` - type-safe sorted array of (Muscle, weight) tuples

**Helper methods added:**
- `weight(for: Muscle) -> Double` - type-safe dictionary access
- `static custom(displayName:movement:equipment:dimensions:)` - factory inheriting Movement defaults

**Removed:**
- `variant: Variant?` relationship
- UUID-based `id`
- Stored `isUnilateral` Bool

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Fixed UUID to String type mismatch in ActiveWorkoutViewModel**
- **Found during:** Task 1 verification
- **Issue:** `exerciseOrder: [UUID]` and `expandedExercises: Set<UUID>` incompatible with new String id
- **Fix:** Changed to `[String]` and `Set<String>`, updated `toggleExerciseExpanded` parameter and `uniqueExerciseIDs` return type
- **Files modified:** ActiveWorkoutViewModel.swift

**2. [Rule 3 - Blocking] Fixed UUID to String type mismatch in ActiveWorkoutView**
- **Found during:** Task 1 verification
- **Issue:** `ExerciseSectionForID.exerciseID: UUID` incompatible with new String id
- **Fix:** Changed to `String`
- **Files modified:** ActiveWorkoutView.swift

**3. [Rule 3 - Blocking] Fixed variant references in Variant.swift**
- **Found during:** Task 1 verification
- **Issue:** `@Relationship(inverse: \Exercise.variant)` no longer valid since Exercise.variant removed
- **Fix:** Commented out the exercises relationship with explanatory note
- **Files modified:** Variant.swift

**4. [Rule 3 - Blocking] Uncommented Movement.exercises relationship**
- **Found during:** Task 1 verification
- **Issue:** Movement.exercises was commented awaiting Exercise.movement to exist (plan 05-04 note)
- **Fix:** Uncommented `@Relationship(deleteRule: .cascade, inverse: \Exercise.movement)`
- **Files modified:** Movement.swift

**5. [Rule 3 - Blocking] Updated all view/ViewModel variant references**
- **Found during:** Task 1 verification
- **Issue:** Multiple views referenced `exercise.variant?.xxx` which no longer exists
- **Fix:** Updated to use direct Exercise properties (`exercise.primaryMuscleGroup`, `exercise.movement`, `exercise.muscleWeights`, `exercise.isBuiltIn`)
- **Files modified:** ExerciseSearchResultsView.swift, ExerciseDetailView.swift, ExerciseRow.swift, ExerciseSectionView.swift

**6. [Rule 3 - Blocking] Updated MuscleWeightViewModel from Variant-based to Exercise-based**
- **Found during:** Task 1 verification
- **Issue:** ViewModel took `Variant?` parameter and iterated VariantMuscle array
- **Fix:** Changed to `Exercise?` parameter, reads/writes `exercise.muscleWeights` dictionary directly
- **Files modified:** MuscleWeightViewModel.swift, MuscleWeightEditorView.swift

**7. [Rule 3 - Blocking] Updated ExerciseCreationViewModel and wizard**
- **Found during:** Task 1 verification
- **Issue:** Used `Exercise(variant:equipment:)` initializer and `createdVariant` property
- **Fix:** Uses `Exercise.custom()` factory, removed variant creation, renamed variationName to exerciseName
- **Files modified:** ExerciseCreationViewModel.swift, ExerciseCreationWizard.swift, VariationStepView.swift

**8. [Rule 3 - Blocking] Updated ExerciseSeedService**
- **Found during:** Task 1 verification
- **Issue:** Created Variant and VariantMuscle objects, used `Exercise(variant:equipment:)` initializer
- **Fix:** Creates Exercise directly with muscleWeights dictionary and movement relationship
- **Files modified:** ExerciseSeedService.swift

## Decisions Made

| ID | Decision | Rationale |
|----|----------|-----------|
| 05-05-01 | String id for Exercise | Supports snake_case preset IDs while UUID strings work for custom |
| 05-05-02 | Stored displayName | Presets have curated names; no longer computed from variant+equipment |
| 05-05-03 | Dictionary muscleWeights | Simpler than VariantMuscle junction table; keys match Muscle.rawValue |
| 05-05-04 | Computed isUnilateral | Single source of truth from dimensions.laterality |
| 05-05-05 | String-typed exercise tracking | exerciseOrder/expandedExercises match new String id |

## Verification

- [x] `xcodebuild build` exits with code 0 (BUILD SUCCEEDED)
- [x] Exercise.swift contains `var id: String`
- [x] Exercise.swift contains `var dimensions: Dimensions`
- [x] Exercise.swift contains `var muscleWeights: [String: Double]`
- [x] Exercise.swift contains `var movement: Movement?`
- [x] Exercise.swift does NOT contain `var variant: Variant?`
- [x] Exercise.swift contains `var isUnilateral: Bool` as computed property
- [x] Exercise.swift contains `func weight(for muscle: Muscle)`

## Commits

| Hash | Message |
|------|---------|
| d7dec7d | feat(05-05): rewrite Exercise model with dimensions and muscleWeights |

## Next Phase Readiness

**Ready for 05-06 (Movement Seed Service):**
- Exercise model now has `movement` relationship for seed service to populate
- Movement model has `exercises` relationship active (was commented)

**Ready for 05-07 (Equipment Seed Service):**
- Exercise model has `equipment` relationship (unchanged)

**Ready for 05-08 (Exercise Preset Seeding):**
- Exercise model matches presets_all.json structure
- String id supports snake_case preset identifiers
- muscleWeights dictionary matches JSON format
- Dimensions embedded struct maps to JSON dimensions

**Note:** Variant and VariantMuscle models still exist in codebase and PersistenceController. They should be removed in final integration (05-10) once migration strategy is confirmed.
