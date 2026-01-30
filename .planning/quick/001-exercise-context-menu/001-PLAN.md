---
phase: quick
plan: 001
type: execute
wave: 1
depends_on: []
files_modified:
  - GymAnals/Features/ExerciseLibrary/Views/ExerciseSearchResultsView.swift
  - GymAnals/Features/Workout/Views/ExercisePickerSheet.swift
  - GymAnals/Models/Core/Exercise.swift
autonomous: true

must_haves:
  truths:
    - "Long press on a custom exercise row shows Edit, Delete, and Duplicate options"
    - "Long press on a built-in exercise row shows only Duplicate option"
    - "Edit opens CustomExerciseEditView in a sheet"
    - "Delete shows confirmation dialog before deleting"
    - "Duplicate creates a new custom exercise with same properties but isBuiltIn = false"
  artifacts:
    - path: "GymAnals/Models/Core/Exercise.swift"
      provides: "duplicate() method on Exercise"
      contains: "func duplicate"
    - path: "GymAnals/Features/ExerciseLibrary/Views/ExerciseSearchResultsView.swift"
      provides: "Context menu on library exercise rows"
      contains: ".contextMenu"
    - path: "GymAnals/Features/Workout/Views/ExercisePickerSheet.swift"
      provides: "Context menu on picker exercise rows"
      contains: ".contextMenu"
  key_links:
    - from: "ExerciseSearchResultsView.swift"
      to: "Exercise.duplicate()"
      via: "context menu Duplicate action"
      pattern: "exercise\\.duplicate"
    - from: "ExercisePickerSheet.swift"
      to: "Exercise.duplicate()"
      via: "context menu Duplicate action"
      pattern: "exercise\\.duplicate"
---

<objective>
Add long press context menu to exercise rows in both the exercise library and the exercise picker sheet.

Purpose: Users need quick actions (edit, delete, duplicate) on exercises without navigating into detail views. Custom exercises get full CRUD; built-in exercises get duplicate only.
Output: Context menus on exercise rows in ExerciseSearchResultsView and ExercisePickerSheet.
</objective>

<execution_context>
@/Users/opera_user/.claude/get-shit-done/workflows/execute-plan.md
@/Users/opera_user/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@GymAnals/Models/Core/Exercise.swift
@GymAnals/Features/ExerciseLibrary/Views/ExerciseSearchResultsView.swift
@GymAnals/Features/ExerciseLibrary/Views/ExerciseRow.swift
@GymAnals/Features/ExerciseLibrary/Views/CustomExerciseEditView.swift
@GymAnals/Features/Workout/Views/ExercisePickerSheet.swift
</context>

<tasks>

<task type="auto">
  <name>Task 1: Add duplicate() method to Exercise model</name>
  <files>GymAnals/Models/Core/Exercise.swift</files>
  <action>
Add a `duplicate(in context: ModelContext)` method to Exercise that creates a new custom copy:

```swift
/// Create a duplicate custom exercise with same properties
func duplicate(in context: ModelContext) -> Exercise {
    let copy = Exercise(
        displayName: "\(displayName) (Copy)",
        movement: movement,
        equipment: equipment,
        dimensions: dimensions,
        muscleWeights: muscleWeights,
        popularity: popularity,
        exerciseType: exerciseType,
        isBuiltIn: false
    )
    copy.notes = notes
    copy.sources = sources
    copy.searchTerms = searchTerms
    copy.restDuration = restDuration
    copy.autoStartTimer = autoStartTimer
    context.insert(copy)
    return copy
}
```

Key details:
- Always generates a new UUID string id (default from init)
- Appends " (Copy)" to displayName for disambiguation
- Sets isBuiltIn = false (custom copy regardless of source)
- Copies ALL properties: dimensions, muscleWeights, notes, sources, searchTerms, timer settings
- Does NOT copy: isFavorite, lastUsedDate, gym, workoutSets, weightHistory (those are user-specific state)
- Inserts into the provided ModelContext
- Returns the new exercise (caller may need reference)
  </action>
  <verify>Build passes: `xcodebuild -scheme GymAnals -destination 'platform=iOS Simulator,name=iPhone 16' build`</verify>
  <done>Exercise.swift has a duplicate(in:) method that creates a new custom exercise preserving all exercise properties except user state</done>
</task>

<task type="auto">
  <name>Task 2: Add context menus to ExerciseSearchResultsView and ExercisePickerSheet</name>
  <files>
    GymAnals/Features/ExerciseLibrary/Views/ExerciseSearchResultsView.swift
    GymAnals/Features/Workout/Views/ExercisePickerSheet.swift
  </files>
  <action>
**ExerciseSearchResultsView.swift** -- Add context menu to both sections' NavigationLink rows, plus state for edit sheet and delete confirmation:

1. Add state properties to ExerciseSearchResultsView:
   - `@Environment(\.modelContext) private var modelContext`
   - `@State private var exerciseToEdit: Exercise?`
   - `@State private var exerciseToDelete: Exercise?`

2. Extract a helper method to avoid repeating context menu code:
```swift
@ViewBuilder
private func exerciseRowWithContextMenu(_ exercise: Exercise) -> some View {
    NavigationLink {
        ExerciseDetailView(exercise: exercise)
    } label: {
        ExerciseRow(exercise: exercise)
    }
    .contextMenu {
        if !exercise.isBuiltIn {
            Button {
                exerciseToEdit = exercise
            } label: {
                Label("Edit", systemImage: "pencil")
            }
        }

        Button {
            _ = exercise.duplicate(in: modelContext)
        } label: {
            Label("Duplicate", systemImage: "doc.on.doc")
        }

        if !exercise.isBuiltIn {
            Divider()
            Button(role: .destructive) {
                exerciseToDelete = exercise
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
```

3. Replace both ForEach bodies (in "Starred & Recent" and "All Exercises" sections) to use the helper:
```swift
ForEach(featured.prefix(10)) { exercise in
    exerciseRowWithContextMenu(exercise)
}
```

4. Add sheet and confirmationDialog modifiers to the outer List (or the else branch containing the List):
```swift
.sheet(item: $exerciseToEdit) { exercise in
    NavigationStack {
        CustomExerciseEditView(exercise: exercise)
    }
}
.confirmationDialog(
    "Delete Exercise",
    isPresented: Binding(
        get: { exerciseToDelete != nil },
        set: { if !$0 { exerciseToDelete = nil } }
    ),
    titleVisibility: .visible
) {
    Button("Delete", role: .destructive) {
        if let exercise = exerciseToDelete {
            modelContext.delete(exercise)
            exerciseToDelete = nil
        }
    }
    Button("Cancel", role: .cancel) {
        exerciseToDelete = nil
    }
} message: {
    Text("This will permanently delete \"\(exerciseToDelete?.displayName ?? "")\" and all its workout history.")
}
```

**ExercisePickerSheet.swift** -- Add context menu to picker rows:

1. Add state properties:
   - `@Environment(\.modelContext) private var modelContext`
   - `@State private var exerciseToEdit: Exercise?`
   - `@State private var exerciseToDelete: Exercise?`

2. Add `.contextMenu` modifier to the `Button` in the `List(filteredExercises)`. Apply contextMenu to the entire Button (after `.tint(.primary)`):
```swift
Button {
    toggleSelection(exercise)
} label: {
    HStack {
        ExerciseRow(exercise: exercise)
        Spacer()
        Image(systemName: selectedExerciseIDs.contains(exercise.id) ? "checkmark.circle.fill" : "circle")
            .font(.title3)
            .foregroundStyle(selectedExerciseIDs.contains(exercise.id) ? Color.accentColor : .secondary)
    }
}
.tint(.primary)
.contextMenu {
    if !exercise.isBuiltIn {
        Button {
            exerciseToEdit = exercise
        } label: {
            Label("Edit", systemImage: "pencil")
        }
    }

    Button {
        _ = exercise.duplicate(in: modelContext)
    } label: {
        Label("Duplicate", systemImage: "doc.on.doc")
    }

    if !exercise.isBuiltIn {
        Divider()
        Button(role: .destructive) {
            exerciseToDelete = exercise
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}
```

3. Add sheet and confirmationDialog modifiers to the VStack or NavigationStack in ExercisePickerSheet:
```swift
.sheet(item: $exerciseToEdit) { exercise in
    NavigationStack {
        CustomExerciseEditView(exercise: exercise)
    }
}
.confirmationDialog(
    "Delete Exercise",
    isPresented: Binding(
        get: { exerciseToDelete != nil },
        set: { if !$0 { exerciseToDelete = nil } }
    ),
    titleVisibility: .visible
) {
    Button("Delete", role: .destructive) {
        if let exercise = exerciseToDelete {
            selectedExerciseIDs.remove(exercise.id)
            modelContext.delete(exercise)
            exerciseToDelete = nil
        }
    }
    Button("Cancel", role: .cancel) {
        exerciseToDelete = nil
    }
} message: {
    Text("This will permanently delete \"\(exerciseToDelete?.displayName ?? "")\" and all its workout history.")
}
```

Note for picker: When deleting, also remove the exercise from `selectedExerciseIDs` if it was selected.

Key implementation details:
- `.contextMenu` is the correct SwiftUI modifier for long-press menus
- `Button(role: .destructive)` gives Delete a red tint automatically
- `Divider()` in context menu separates destructive actions
- `.sheet(item:)` uses Exercise directly since it's Identifiable
- confirmationDialog uses a Binding wrapper since Exercise? is not Bool
- Menu order: Edit (custom only) -> Duplicate (always) -> divider -> Delete (custom only)
  </action>
  <verify>Build passes: `xcodebuild -scheme GymAnals -destination 'platform=iOS Simulator,name=iPhone 16' build`</verify>
  <done>
    - Long press on custom exercise shows Edit, Duplicate, Delete (with red tint and separator)
    - Long press on built-in exercise shows only Duplicate
    - Edit opens CustomExerciseEditView in a sheet
    - Delete shows confirmation dialog with exercise name, then deletes on confirm
    - Duplicate creates a custom copy with " (Copy)" suffix inserted into model context
    - Picker delete also removes exercise from selectedExerciseIDs
  </done>
</task>

</tasks>

<verification>
1. `xcodebuild -scheme GymAnals -destination 'platform=iOS Simulator,name=iPhone 16' build` succeeds
2. Exercise.swift contains `func duplicate(in context: ModelContext)` method
3. ExerciseSearchResultsView.swift contains `.contextMenu` modifier on exercise rows
4. ExercisePickerSheet.swift contains `.contextMenu` modifier on exercise rows
5. Both files contain `.sheet(item: $exerciseToEdit)` and `.confirmationDialog` for delete
6. Context menu shows Edit/Delete only when `!exercise.isBuiltIn`
7. Duplicate is always available in context menu
</verification>

<success_criteria>
- Clean build with no errors or warnings related to context menu changes
- Context menu code properly gates Edit/Delete behind `!exercise.isBuiltIn`
- Duplicate creates independent copy with " (Copy)" suffix and isBuiltIn = false
- Delete confirmation dialog shows exercise name and warns about workout history loss
- Both ExerciseSearchResultsView and ExercisePickerSheet have context menus
</success_criteria>

<output>
After completion, create `.planning/quick/001-exercise-context-menu/001-SUMMARY.md`
</output>
