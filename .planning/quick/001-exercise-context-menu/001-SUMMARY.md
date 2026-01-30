---
phase: quick
plan: 001
subsystem: exercise-library
completed: 2026-01-29
duration: 4 min
tags: [exercise-context-menu, swiftui, context-menu, duplicate, edit, delete]

requires: []
provides:
  - "Context menu on exercise rows (long press)"
  - "Exercise duplication functionality"
  - "Quick edit for custom exercises"
  - "Quick delete with confirmation"
affects: []

tech-stack:
  added: []
  patterns:
    - "SwiftUI .contextMenu modifier for long press actions"
    - "Confirmation dialog with Binding wrapper for non-Bool state"
    - ".sheet(item:) for presenting edit view"
    - "ModelContext injection in duplicate method"

key-files:
  created: []
  modified:
    - path: "GymAnals/Models/Core/Exercise.swift"
      role: "Added duplicate(in:) method"
    - path: "GymAnals/Features/ExerciseLibrary/Views/ExerciseSearchResultsView.swift"
      role: "Added context menu with helper method"
    - path: "GymAnals/Features/Workout/Views/ExercisePickerSheet.swift"
      role: "Added context menu to picker rows"

decisions:
  - id: "quick-001-context-menu-gating"
    what: "Context menu options gated by isBuiltIn flag"
    why: "Custom exercises need full CRUD; built-in exercises should only be duplicatable"
    impact: "Edit and Delete only shown for custom exercises"

  - id: "quick-001-duplicate-suffix"
    what: "Duplicate appends ' (Copy)' to displayName"
    why: "Provides clear visual distinction from source exercise"
    impact: "Users immediately see which exercise is the duplicate"

  - id: "quick-001-duplicate-always-custom"
    what: "Duplicates always set isBuiltIn = false"
    why: "Even duplicating a built-in exercise creates a custom copy that can be edited"
    impact: "Users can customize built-in exercises via duplicate + edit"

  - id: "quick-001-delete-confirmation"
    what: "Delete shows confirmation dialog with workout history warning"
    why: "Deleting exercise cascades to workout sets (data loss)"
    impact: "Users warned before destructive action"
---

# Quick Task 001: Exercise Context Menu Summary

Add long press context menu to exercise rows for quick actions (edit, duplicate, delete).

## Tasks Completed

| Task | Name                                      | Commit  | Files                                                     |
|------|-------------------------------------------|---------|-----------------------------------------------------------|
| 1    | Add duplicate() method to Exercise model  | 56fa58c | Exercise.swift                                            |
| 2    | Add context menus to library and picker   | ffcb615 | ExerciseSearchResultsView.swift, ExercisePickerSheet.swift |

## What Was Built

### Task 1: Exercise.duplicate(in:) Method
Added method to Exercise model that creates a custom copy:
- Generates new UUID string id
- Appends " (Copy)" to displayName
- Sets isBuiltIn = false (custom copy regardless of source)
- Copies all exercise properties: dimensions, muscleWeights, notes, sources, searchTerms, timer settings
- Does NOT copy user state: isFavorite, lastUsedDate, gym, workoutSets, weightHistory
- Inserts into provided ModelContext and returns reference

### Task 2: Context Menus on Exercise Rows
Added `.contextMenu` modifier to exercise rows in both ExerciseSearchResultsView and ExercisePickerSheet:

**Custom exercises (isBuiltIn == false):**
- Edit → Opens CustomExerciseEditView in a sheet
- Duplicate → Creates custom copy with " (Copy)" suffix
- Divider
- Delete → Shows confirmation dialog, then deletes on confirm

**Built-in exercises (isBuiltIn == true):**
- Duplicate → Creates custom copy with " (Copy)" suffix

**Implementation details:**
- ExerciseSearchResultsView uses helper method `exerciseRowWithContextMenu()` to avoid duplication
- Both views use `.sheet(item:)` for edit presentation
- Both views use `.confirmationDialog` with Binding wrapper for delete confirmation
- Picker delete also removes exercise from `selectedExerciseIDs` if selected
- Confirmation dialog warns about workout history loss

## Build Status

✅ Clean build successful with zero errors
- Target: GymAnals
- Destination: iOS Simulator, iPhone 17
- Warnings: Pre-existing Swift 6 concurrency warnings (not introduced by this work)

## Verification

All success criteria met:
- [x] Clean build with no errors or warnings related to context menu changes
- [x] Context menu code properly gates Edit/Delete behind `!exercise.isBuiltIn`
- [x] Duplicate creates independent copy with " (Copy)" suffix and isBuiltIn = false
- [x] Delete confirmation dialog shows exercise name and warns about workout history loss
- [x] Both ExerciseSearchResultsView and ExercisePickerSheet have context menus

## Deviations from Plan

None - plan executed exactly as written.

## Next Steps

None - this was a standalone quick task.

## Commits

- 56fa58c: feat(exercise-menu): add duplicate() method to Exercise model
- ffcb615: feat(exercise-menu): add context menus to exercise library and picker
