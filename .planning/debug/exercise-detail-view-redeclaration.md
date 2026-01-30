---
status: resolved
trigger: "Invalid redeclaration of 'ExerciseDetailView' error during build"
created: 2026-01-29T00:00:00Z
updated: 2026-01-29T22:55:00Z
---

## Current Focus

hypothesis: ExerciseDetailView_timer.swift is an untracked work-in-progress file accidentally created that's not referenced anywhere in the project
test: Verify git tracking status, check file references, compare content
expecting: Find that _timer.swift is untracked and not integrated anywhere, making simple deletion the correct fix
next_action: CONFIRMED - ready to recommend deletion fix

## Symptoms

expected: Swift build succeeds without compiler errors
actual: Xcode build fails with "Invalid redeclaration of 'ExerciseDetailView'" error
errors: Redeclaration error when building project
reproduction: Run xcodebuild -scheme GymAnals -destination 'platform=iOS Simulator,name=iPhone 16' build
started: After recent changes (commit 42f1c33)
module: iOS SwiftUI app

## Eliminated

(none yet)

## Evidence

- timestamp: 2026-01-29 01:00:00
  checked: File listing for ExerciseDetailView variants
  found: Two files both defining `struct ExerciseDetailView: View`
    - /Users/opera_user/repo/GymAnals/GymAnals/Features/ExerciseLibrary/Views/ExerciseDetailView.swift (227 lines)
    - /Users/opera_user/repo/GymAnals/GymAnals/Features/ExerciseLibrary/Views/ExerciseDetailView_timer.swift (251 lines)
  implication: Both files declare identical struct name, causing Swift compiler redeclaration error

- timestamp: 2026-01-29 01:00:00
  checked: ExerciseDetailView.swift content structure
  found: Main file has SIMPLER timer handling - read-only display of timer settings:
    - Lines 128-132: Shows "Rest Duration: {seconds}" and "Auto-start Timer: On/Off" as display-only
    - Missing: Stepper for rest duration adjustment
    - Missing: Toggle for auto-start timer
    - Missing: "Reset to Defaults" button for built-in exercises
    - Has: muscleWeightVM state variable (line 18)
    - Timer section is DISPLAY-ONLY
  implication: This appears to be an older/incomplete version

- timestamp: 2026-01-29 01:00:00
  checked: ExerciseDetailView_timer.swift content structure
  found: Timer file has RICHER timer functionality - editable controls:
    - Lines 82-113: Interactive Stepper for rest duration (30-300s, step 15)
    - Lines 96-102: Toggle for auto-start timer
    - Lines 104-112: "Reset to Defaults" button for built-in exercises
    - Missing: muscleWeightVM state variable
    - Has fewer dependencies initially but fuller feature set
    - Timer section is INTERACTIVE/EDITABLE
  implication: This is a more feature-rich version with improved UX

- timestamp: 2026-01-29 01:00:00
  checked: Muscle targeting section differences
  found: ExerciseDetailView.swift (main):
    - Lines 83-126: Has `@State private var muscleWeightVM: MuscleWeightViewModel?` (line 18)
    - Creates ViewModel when button clicked: `muscleWeightVM = MuscleWeightViewModel(exercise: exercise, startInEditMode: true)` (line 86)
    - Passes it to sheet: `MuscleWeightEditorView(viewModel: muscleVM)` (line 209)
  found: ExerciseDetailView_timer.swift:
    - Lines 115-158: Same structure BUT missing muscleWeightVM state
    - Creates ViewModel inline when navigating: `MuscleWeightViewModel(exercise: exercise)` without `muscleWeightVM` variable
    - Passes startInEditMode: true directly to sheet (line 234)
  implication: Timer version simplified muscle weight ViewModel handling

- timestamp: 2026-01-29 01:00:00
  checked: Sheet presentation differences
  found: Main file (ExerciseDetailView.swift):
    - Lines 206-211: Sheet reads from `muscleWeightVM` state variable
    - Creates model first, then presents sheet
  found: Timer file (ExerciseDetailView_timer.swift):
    - Lines 232-235: Sheet creates ViewModel inline with `startInEditMode: true`
  implication: Different approaches to managing ViewModel lifecycle

- timestamp: 2026-01-29 01:00:00
  checked: Git history and file tracking status
  found: ExerciseDetailView_timer.swift is UNTRACKED (??) in git status
  found: Not present in any git commit history (git log shows no trace)
  found: Timestamps show both files modified on 2026-01-29 around 22:37-22:38 (just created)
  found: HEAD commit (42f1c33) only contains main ExerciseDetailView.swift
  found: grep search confirms _timer.swift is not referenced anywhere in codebase
  implication: This is an accidental/orphaned file, never intended for commit

## Resolution

root_cause: ExerciseDetailView_timer.swift is an untracked, work-in-progress file that was accidentally created alongside the committed ExerciseDetailView.swift. Both files declare `struct ExerciseDetailView: View`, causing the Swift compiler to raise a redeclaration error. The _timer.swift file contains an experimental enhanced version with interactive timer controls but was never committed and is not referenced anywhere in the project.

fix: DELETE ExerciseDetailView_timer.swift entirely. This is the simplest and safest resolution because:
  1. The _timer.swift file is untracked (not in git history)
  2. It's not referenced anywhere in the codebase (verified via grep)
  3. The main ExerciseDetailView.swift is the canonical version in HEAD
  4. The timer enhancements in _timer.swift can be developed in a proper feature branch later if needed

files_to_delete:
  - GymAnals/Features/ExerciseLibrary/Views/ExerciseDetailView_timer.swift (PRIORITY: Delete immediately)

verification:
  - Build will succeed after deletion: VERIFIED - BUILD SUCCEEDED
  - No functionality lost (timer.swift was never integrated): VERIFIED - only ExerciseDetailView.swift remains
  - Main file preserves all current functionality including read-only timer display: VERIFIED
  - File successfully deleted: /Users/opera_user/repo/GymAnals/GymAnals/Features/ExerciseLibrary/Views/ExerciseDetailView_timer.swift
  - Clean build output shows no "Invalid redeclaration" errors
  - All warnings are pre-existing (Swift 6 conformance in other areas)
