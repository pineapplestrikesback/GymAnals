---
status: testing
phase: 05-exercise-library-rework
source: 05-01-SUMMARY.md, 05-02-SUMMARY.md, 05-03-SUMMARY.md, 05-04-SUMMARY.md, 05-05-SUMMARY.md, 05-06-SUMMARY.md, 05-07-SUMMARY.md, 05-08-SUMMARY.md, 05-09-SUMMARY.md, 05-10-SUMMARY.md
started: 2026-01-28T20:00:00Z
updated: 2026-01-28T20:00:00Z
---

## Current Test
<!-- OVERWRITE each test - shows where we are -->

number: 3
name: Search by Name and Search Terms
expected: |
  Typing a search term (e.g., "bench") finds exercises matching by display name OR search terms. For example, searching "chest fly" should find cable/dumbbell fly exercises even if the display name doesn't contain "chest fly" exactly.
awaiting: user response

## Tests

### 1. App Launches and Seeds Data
expected: On a fresh install (delete app first), the app launches without errors. The exercise library tab shows a populated list of exercises (237 presets should be available).
result: issue
reported: "PresetSeedService: Failed to load presets_all.json from bundle. No exercises show up. Gym (1), Equipment (22), Movements (30) seed fine."
severity: blocker

### 2. Browse Exercise Library
expected: Exercises display in the library with rows showing exercise name, equipment name (e.g., "Barbell"), a bullet separator, and the primary muscle group. A category badge (e.g., "Push", "Pull") appears on each row.
result: skipped
reason: Blocked by Test 1 — no exercises loaded (presets_all.json failed)

### 3. Search by Name and Search Terms
expected: Typing a search term (e.g., "bench") finds exercises matching by display name OR search terms. For example, searching "chest fly" should find cable/dumbbell fly exercises even if the display name doesn't contain "chest fly" exactly.
result: [pending]

### 4. Filter by Muscle Group
expected: Tapping a muscle group filter tab shows only exercises targeting that muscle group. Switching between tabs updates the list accordingly.
result: [pending]

### 5. Exercise Detail View - Basic Info
expected: Tapping an exercise opens a detail view showing the exercise name, equipment, movement category, and a list of targeted muscles with their weight percentages (e.g., "Chest 1.0", "Front Delt 0.5"). Up to 5 muscles should be shown.
result: [pending]

### 6. Exercise Detail View - Dimensions and Metadata
expected: In the detail view for a preset exercise, you can see dimension info (angle, grip, stance if applicable), notes, sources, and popularity. The favorite toggle is in the toolbar (star icon).
result: [pending]

### 7. Built-in Exercises Are Read-Only
expected: For a built-in (preset) exercise, muscle weights are displayed but there is no "Edit Muscle Weights" button. The exercise should be clearly non-editable for muscle targeting.
result: [pending]

### 8. Create Custom Exercise
expected: Tapping the create/add button starts the exercise creation wizard. You pick a movement, then equipment, then see a suggested name (equipment + movement, e.g., "Barbell Bench Press"). You can accept or edit the name.
result: [pending]

### 9. Custom Exercise Muscle Weights
expected: During custom exercise creation (or editing a custom exercise), the muscle weight editor is available. It pre-fills from the movement's default muscle weights. "Reset to Default" restores the movement's defaults (not empty).
result: [pending]

### 10. Exercise Picker in Workout
expected: When adding an exercise to an active workout, the exercise picker sheet shows exercises with search that matches display name, search terms, and movement name. Selecting an exercise adds it to the workout.
result: [pending]

### 11. Clean Build
expected: The app builds without errors or warnings related to Variant/VariantMuscle. Run `xcodebuild build` and confirm BUILD SUCCEEDED.
result: [pending]

## Summary

total: 11
passed: 0
issues: 1
pending: 9
skipped: 1

## Gaps

- truth: "237 exercise presets seeded from presets_all.json on first launch"
  status: failed
  reason: "User reported: PresetSeedService: Failed to load presets_all.json from bundle. No exercises show up. Gym (1), Equipment (22), Movements (30) seed fine."
  severity: blocker
  test: 1
  root_cause: ""
  artifacts: []
  missing: []
  debug_session: ""
