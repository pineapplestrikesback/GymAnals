---
phase: 06-bug-fixes
plan: 02
subsystem: exercise-library
tags: [swiftui, muscle-weights, custom-exercise, edit-form, ux-fix]

# Dependency graph
requires:
  - phase: 05-exercise-library-rework
    provides: Exercise model, MuscleWeightEditorView, MuscleWeightViewModel, ExerciseDetailView
affects:
  - phase: 07-analytics
    impact: Custom exercise editing may affect analytics data flow

# Tech tracking
tech-stack:
  patterns:
    - startInEditMode parameter for immediate interactivity
    - Form-based edit view with NavigationLink pickers
    - Private subview @Query pattern for equipment/movement selection
    - State initialization from model in custom init

# File tracking
key-files:
  created:
    - GymAnals/Features/ExerciseLibrary/Views/CustomExerciseEditView.swift
  modified:
    - GymAnals/Features/ExerciseLibrary/Views/MuscleWeightEditorView.swift
    - GymAnals/Features/ExerciseLibrary/Views/ExerciseDetailView.swift
    - GymAnals/Features/ExerciseLibrary/Views/ExerciseCreationWizard.swift

# Decisions
decisions:
  - id: 06-02-01
    description: "startInEditMode defaults to false for backward compatibility; callers opt-in"
  - id: 06-02-02
    description: "Equipment/Movement pickers as private inline subviews (not separate files) for encapsulation"
  - id: 06-02-03
    description: "Dimensions editing excluded from CustomExerciseEditView (set at creation only)"

# Metrics
metrics:
  duration: 6 min
  completed: 2026-01-28
---

# Phase 06 Plan 02: Muscle Weight Slider Discoverability and Custom Exercise Edit Summary

Fixed muscle weight slider discoverability via startInEditMode parameter and created CustomExerciseEditView Form for editing custom exercise properties.

## One-liner

startInEditMode parameter for immediate slider interactivity plus Form-based CustomExerciseEditView for name/equipment/movement/timer/notes editing

## Tasks Completed

| Task | Name                                            | Commit  | Key Files                                                                            |
| ---- | ----------------------------------------------- | ------- | ------------------------------------------------------------------------------------ |
| 1    | Make muscle weight sliders immediately editable | 4b40c02 | MuscleWeightEditorView.swift, ExerciseDetailView.swift, ExerciseCreationWizard.swift |
| 2    | Create custom exercise edit view                | 0e27e0f | CustomExerciseEditView.swift, ExerciseDetailView.swift                               |

## What Was Built

### Task 1: Immediate Muscle Weight Editing

- Added `startInEditMode: Bool = false` parameter to `MuscleWeightEditorView`
- Added `.onAppear` handler that sets `viewModel.isEditing = true` when `startInEditMode` is true
- Updated `ExerciseDetailView` to pass `startInEditMode: true` when opening muscle editor sheet
- Updated `ExerciseCreationWizard` step 4 to pass `startInEditMode: true`
- ViewModel default (`isEditing = false`) preserved for backward compatibility

### Task 2: Custom Exercise Edit Form

- Created `CustomExerciseEditView.swift` (224 lines) with Form-based editing:
  - Name section: TextField for displayName
  - Classification section: NavigationLink pickers for Equipment and Movement
  - Timer Settings section: Stepper for rest duration (30-300s, step 15), Toggle for auto-start
  - Notes section: TextEditor with 80pt minimum height
- Private `EquipmentPickerList` and `MovementPickerList` subviews with `@Query` for sorted entity lists
- Each picker supports clearing selection ("None" option) and shows checkmark for current selection
- Added `showingEditSheet` state and Edit button to ExerciseDetailView toolbar (custom exercises only)
- Sheet presentation wraps CustomExerciseEditView in NavigationStack
- Save logic updates all properties on the Exercise model and calls `modelContext.save()`

## Decisions Made

1. **startInEditMode defaults false**: Preserves backward compatibility -- any caller not passing the parameter gets read-only mode. ExerciseDetailView and ExerciseCreationWizard explicitly opt-in to immediate editing.

2. **Inline private subviews for pickers**: EquipmentPickerList and MovementPickerList are file-private within CustomExerciseEditView.swift rather than separate files. This keeps the edit form self-contained and avoids polluting the Views directory with tiny single-use views.

3. **No dimensions editing in v1**: Dimensions (angle, grip, stance, laterality) are set at exercise creation and not editable afterward. This simplifies the edit form and prevents users from accidentally changing dimension values that affect exercise identity.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] .accentColor replaced with .tint**
- **Found during:** Task 2
- **Issue:** `.foregroundStyle(.accentColor)` is invalid in SwiftUI -- `ShapeStyle` has no `.accentColor` member
- **Fix:** Linter auto-corrected to `.foregroundStyle(.tint)` which is the correct SwiftUI API
- **Files modified:** CustomExerciseEditView.swift
- **Commit:** 0e27e0f

**2. [Rule 2 - Missing Critical] ExerciseCreationWizard also passes startInEditMode**
- **Found during:** Task 1
- **Issue:** Plan mentioned checking if ExerciseCreationWizard uses MuscleWeightEditorView. It does (step 4).
- **Fix:** Passed `startInEditMode: true` in the wizard as well, so new exercises also get immediately-interactive sliders
- **Files modified:** ExerciseCreationWizard.swift
- **Commit:** 4b40c02

## Verification Results

- Build compiles without errors (iPhone 17 Pro simulator)
- MuscleWeightEditorView accepts `startInEditMode` parameter (line 18)
- CustomExerciseEditView.swift exists with Form layout (224 lines)
- ExerciseDetailView has Edit button gated by `!exercise.isBuiltIn` (line 189)
- Equipment and Movement pickers use NavigationLink + @Query pattern
- `sheet(isPresented: $showingEditSheet)` presents CustomExerciseEditView (line 209)
- `startInEditMode: true` passed from ExerciseDetailView (line 206) and ExerciseCreationWizard (line 53)

## Success Criteria Status

- [x] SC5: Muscle weight sliders are immediately interactive when opened from exercise detail view
- [x] SC6: Custom exercises have full edit form (name, equipment, movement, timer settings, notes)
- [x] Built-in exercises remain read-only with no edit option
