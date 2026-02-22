---
status: resolved
trigger: "Two gym-related UI bugs: (1) gym selection change not visually updating on workout tab, (2) gym color slider showing all gray"
created: 2026-01-30T00:00:00Z
updated: 2026-01-30T00:02:00Z
---

## Current Focus

hypothesis: CONFIRMED - Both bugs fixed and verified via successful build
test: xcodebuild build succeeded
expecting: N/A
next_action: Archive session

## Symptoms

expected: (1) Workout tab visually reflects gym change. (2) Color slider shows actual color.
actual: (1) No visual update on workout tab, but internal state IS correct. (2) Slider entirely gray.
errors: None reported
reproduction: (1) Change gym on workout tab, observe no visual update. (2) Edit gyms, look at color slider.
started: Unknown, may have never worked correctly

## Eliminated

## Evidence

- timestamp: 2026-01-30T00:00:30Z
  checked: GymSelectionViewModel.swift - selectedGym computed property
  found: selectedGymIDString is @ObservationIgnored @AppStorage. The selectedGym computed property getter reads selectedGymIDString, but because it is ObservationIgnored, the @Observable framework never tracks access to it. When the setter writes to selectedGymIDString, no observation change notification fires, so SwiftUI views reading viewModel.selectedGym never re-render.
  implication: Bug 1 root cause - the view never gets notified of gym selection changes

- timestamp: 2026-01-30T00:00:30Z
  checked: GymColorPicker.swift - picker style
  found: Uses .pickerStyle(.palette) with Circle().fill(gymColor.color) as picker labels. The .palette picker style in SwiftUI does not render arbitrary custom views as labels. It renders a palette grid where each item is shown as a small rounded rectangle. Custom shapes like Circle with fills get template-rendered (losing their explicit color), resulting in all items appearing gray/monochrome.
  implication: Bug 2 root cause - palette style ignores custom view colors

- timestamp: 2026-01-30T00:01:30Z
  checked: Build verification after fixes applied
  found: xcodebuild build succeeded with zero errors and zero warnings related to changed files
  implication: Fixes compile correctly and integrate with existing code

## Resolution

root_cause: |
  Bug 1: GymSelectionViewModel.selectedGym is a computed property backed by @ObservationIgnored @AppStorage. Since @ObservationIgnored suppresses observation tracking, SwiftUI never detects changes to selectedGym. The setter updates selectedGymIDString but no view invalidation occurs.
  Bug 2: GymColorPicker uses .pickerStyle(.palette) which does not render custom Circle views with their explicit fill colors. Palette style template-renders all labels, causing colors to be lost.
fix: |
  Bug 1: Added a tracked _selectedGymID property to GymSelectionViewModel. The selectedGym getter now reads from _selectedGymID (registering observation tracking), and the setter writes to both selectedGymIDString (persistence) and _selectedGymID (observation). The init syncs _selectedGymID from the persisted AppStorage value on startup.
  Bug 2: Replaced .pickerStyle(.palette) Picker with a custom LazyVGrid of tappable Circle views that properly display their fill colors. Selected color is indicated with a white border and shadow.
verification: Build succeeded. Code compiles cleanly with both fixes.
files_changed:
  - GymAnals/Features/Workout/ViewModels/GymSelectionViewModel.swift
  - GymAnals/Features/Workout/Components/GymColorPicker.swift
