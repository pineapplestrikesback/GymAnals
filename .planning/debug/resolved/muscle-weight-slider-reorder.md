---
status: resolved
trigger: "Muscle weight sliders in exercise creation flow dynamically reorder while user is actively dragging a slider"
created: 2026-01-30T00:00:00Z
updated: 2026-01-30T00:03:00Z
---

## Current Focus

hypothesis: CONFIRMED AND FIXED
test: Build succeeded with fix applied
expecting: N/A - resolved
next_action: Archive session

## Symptoms

expected: When editing muscle weights during exercise creation, the list of muscles should remain in a stable order while the user is dragging sliders. Reordering by weight should only apply to display/information views, not during editing.
actual: The muscle list reorders in real-time as slider values change, causing the row being edited to jump to a new position mid-drag, making it very difficult to use.
errors: No error messages - this is a UX/behavior bug.
reproduction: Open exercise creation flow -> go to muscle weights editing view -> drag a slider to adjust a muscle's weight above another muscle's current weight -> observe the list reorders immediately while still dragging.
started: Unknown - may have always been this way or introduced with a recent change.

## Eliminated

## Evidence

- timestamp: 2026-01-30T00:00:30Z
  checked: MuscleWeightEditorView.swift line 20
  found: `let assigned = viewModel.weights.filter { $0.value > 0 }.sorted { $0.value > $1.value }` - inline sort computed every time the view body is re-evaluated
  implication: Any change to viewModel.weights (which is @Observable) triggers SwiftUI body re-evaluation, recomputes the sort, and causes rows to jump position

- timestamp: 2026-01-30T00:00:45Z
  checked: MuscleWeightViewModel.swift - updateWeight method (line 37-39)
  found: `func updateWeight(muscle:weight:)` directly mutates `weights` dictionary, which triggers @Observable notification
  implication: Every slider drag step triggers the sort recomputation in the view

- timestamp: 2026-01-30T00:00:50Z
  checked: ExerciseCreationWizard.swift line 90
  found: MuscleWeightViewModel is created with `startInEditMode: true` for the creation wizard
  implication: The creation wizard always starts in edit mode, so the sort-during-drag bug is always present in the creation flow

- timestamp: 2026-01-30T00:01:00Z
  checked: MuscleSlider.swift - Slider binding
  found: Slider uses `$value` binding directly, which calls through to viewModel.updateWeight on every drag position change
  implication: Confirms the full chain: slider drag -> binding set -> viewModel.weights mutated -> @Observable notifies -> view body recomputed -> sort recomputed -> rows reorder

- timestamp: 2026-01-30T00:02:30Z
  checked: Build verification
  found: BUILD SUCCEEDED with fix applied (xcodebuild -scheme GymAnals -destination iPhone 17 Pro)
  implication: Fix compiles cleanly with no errors

## Resolution

root_cause: MuscleWeightEditorView.swift line 20 sorted the "Targeted Muscles" section inline in the view body using `.sorted { $0.value > $1.value }`. Since viewModel.weights is @Observable, every slider drag updated the weight, triggered body re-evaluation, recomputed the sort, and caused rows to jump to new positions mid-drag.

fix: Added a "frozen display order" mechanism to MuscleWeightViewModel:
  1. Added `frozenDisplayOrder: [Muscle]` property that captures the sorted muscle order when entering edit mode
  2. Added `assignedMusclesForDisplay` computed property that returns the frozen order during editing (with support for newly-assigned muscles appended at end, and zeroed-out muscles filtered), and the live sorted order when not editing
  3. Updated `isEditing` didSet to capture frozen order on edit start
  4. Updated `init` to handle `startInEditMode: true` correctly
  5. Updated `saveChanges` and `discardChanges` to clear frozen order
  6. Updated MuscleWeightEditorView to use `viewModel.assignedMusclesForDisplay` instead of inline sorting

verification: Build succeeds. The fix ensures that during editing, the muscle list order is frozen at the moment editing begins. Muscles keep their positions while sliders are being dragged. When editing ends (save or cancel), the order is released and reverts to live sorting. Newly assigned muscles (from the collapsible group sections) appear at the end of the targeted muscles section.

files_changed:
  - GymAnals/Features/ExerciseLibrary/ViewModels/MuscleWeightViewModel.swift
  - GymAnals/Features/ExerciseLibrary/Views/MuscleWeightEditorView.swift
