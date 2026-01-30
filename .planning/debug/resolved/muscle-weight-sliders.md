---
status: resolved
trigger: "Muscle weight sliders are visible but non-interactive when creating or editing exercises"
created: 2026-01-29T00:00:00Z
updated: 2026-01-29T00:01:00Z
---

## Current Focus

hypothesis: CONFIRMED - Two interrelated issues caused slider non-interactivity
test: Build verification passed
expecting: Sliders now interactive from first render, VM stable across re-renders
next_action: Archive session

## Symptoms

expected: Sliders should be immediately interactive when the view appears. Dragging should update weight values in real-time. Changes should persist when saving.
actual: Sliders are visible but dragging the slider handle does nothing. Values don't update.
errors: None reported - sliders simply don't respond to interaction
reproduction: Open exercise creation wizard or edit a custom exercise, navigate to muscle weight editor step, try dragging any slider
started: Possibly never worked correctly since implementation

## Eliminated

- hypothesis: Slider bindings incorrectly wired
  evidence: Binding chain from Slider -> @Binding -> computed Binding -> VM is correct. Muscle enum is Hashable, dictionary keys are stable.
  timestamp: 2026-01-29

- hypothesis: .disabled() or hit-testing modifier blocking interaction
  evidence: No .disabled() applied to slider containers or MuscleWeightEditorView. Only .disabled() in wizard is on Next button.
  timestamp: 2026-01-29

- hypothesis: Gesture conflict between List scroll and Slider drag
  evidence: Standard SwiftUI List+Slider configuration; Apple handles this in iOS 16+. Not the root cause.
  timestamp: 2026-01-29

## Evidence

- timestamp: 2026-01-29
  checked: MuscleWeightViewModel.init
  found: isEditing defaults to false. Only set to true via .onAppear in MuscleWeightEditorView when startInEditMode is true.
  implication: First render always shows read-only bars; relies on .onAppear timing.

- timestamp: 2026-01-29
  checked: ExerciseCreationWizard case 4
  found: MuscleWeightViewModel created inline every body evaluation - not held in @State.
  implication: Any wizard re-render creates a new VM with isEditing=false, and .onAppear may not re-fire.

- timestamp: 2026-01-29
  checked: ExerciseDetailView .sheet content
  found: MuscleWeightViewModel created inline in sheet closure - not held in @State.
  implication: If ExerciseDetailView re-renders (e.g. from observed exercise changes), sheet content re-evaluates creating new VM with isEditing=false.

- timestamp: 2026-01-29
  checked: MuscleSlider isEditing behavior
  found: When isEditing=false, shows 4px read-only progress bar instead of Slider. When isEditing=true, shows interactive Slider.
  implication: If VM resets isEditing to false, user sees non-interactive progress bars that look like sliders.

## Resolution

root_cause: Two interrelated issues - (1) MuscleWeightViewModel was created inline at call sites (not held in @State), so any parent re-render created a fresh VM with isEditing=false. (2) The startInEditMode mechanism relied on .onAppear to set isEditing=true, which has timing fragility and does not re-fire on subsequent renders. Together, these caused the isEditing state to reset to false, replacing interactive Sliders with read-only progress bars.

fix: (1) Added startInEditMode parameter to MuscleWeightViewModel.init so isEditing is set to true immediately on construction (no .onAppear timing dependency). (2) ExerciseCreationWizard and ExerciseDetailView now hold the MuscleWeightViewModel in @State, preventing re-creation on parent re-renders. (3) Removed the startInEditMode property and .onAppear from MuscleWeightEditorView since the VM now handles it.

verification: Build succeeded with all changes.

files_changed:
- /Users/opera_user/repo/GymAnals-bug-bundle-4/GymAnals/Features/ExerciseLibrary/ViewModels/MuscleWeightViewModel.swift
- /Users/opera_user/repo/GymAnals-bug-bundle-4/GymAnals/Features/ExerciseLibrary/Views/MuscleWeightEditorView.swift
- /Users/opera_user/repo/GymAnals-bug-bundle-4/GymAnals/Features/ExerciseLibrary/Views/ExerciseCreationWizard.swift
- /Users/opera_user/repo/GymAnals-bug-bundle-4/GymAnals/Features/ExerciseLibrary/Views/ExerciseDetailView.swift
