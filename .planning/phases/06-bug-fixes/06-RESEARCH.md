# Phase 6: Bug Fixes - Research

**Researched:** 2026-01-28
**Domain:** SwiftUI bug fixes, state management, UX improvements in iOS workout tracker
**Confidence:** HIGH

## Summary

Phase 6 addresses 20 critical bugs and UX issues across gym management, exercise library, muscle weight editing, and workout logging. After thorough code review of all 63 Swift files in the project, I identified the specific root causes for each success criterion and the SwiftUI patterns needed to fix them.

The bugs fall into four distinct clusters: (1) Gym state management issues where `GymSelectionViewModel` uses `@AppStorage` with computed fetch-on-access but lacks reactivity to model changes and has no workout-active guard; (2) Character encoding mojibake in `presets_all.json` where `Â°` appears 24 times instead of `°`; (3) Exercise library UX gaps where the picker lacks multi-select and custom exercises lack an edit flow; (4) Workout logging UI missing Hevy-style layout columns, persistent rest timer visibility, and gym indicator in the active workout header.

**Primary recommendation:** Fix bugs in dependency order -- data layer first (encoding, gym state), then exercise library UX, then workout logging UI. Each cluster is independent and maps cleanly to one plan file.

## Standard Stack

No new libraries needed. All fixes use existing SwiftUI, SwiftData, and Foundation APIs.

### Core (Already in Project)
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| SwiftUI | iOS 17+ | All UI views | Native Apple framework |
| SwiftData | iOS 17+ | Persistence layer | Chosen in Phase 1 |
| Foundation | iOS 17+ | JSON, encoding, dates | System framework |

### Supporting (No additions needed)
All 10 success criteria can be resolved with existing project dependencies. No new packages required.

## Architecture Patterns

### Pattern 1: Conditional UI Disabling Based on Active Workout State
**What:** Pass `hasActiveWorkout` boolean to gym selector to disable switching during workouts
**When to use:** Success criteria 1 (gym switching disabled during active workouts)
**Current problem:** `WorkoutTabView` has `hasActiveWorkout` state but does not pass it to `GymSelectorHeader` or `GymSelectorSheet`. The gym selector is always tappable.
**Fix pattern:**
```swift
// WorkoutTabView passes state down
GymSelectorHeader(gym: viewModel?.selectedGym, isDisabled: hasActiveWorkout) {
    showingGymSelector = true
}

// GymSelectorHeader respects disabled state
struct GymSelectorHeader: View {
    let gym: Gym?
    var isDisabled: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) { /* ... */ }
            .disabled(isDisabled)
    }
}
```

### Pattern 2: Immediate Gym Selection After Creation
**What:** After saving a new gym in `GymEditView`, immediately select it via the `GymSelectionViewModel`
**When to use:** Success criteria 2 (new gyms immediately selectable)
**Current problem:** `GymEditView.save()` creates the gym and dismisses, but `GymSelectorSheet` uses `@Query` which updates asynchronously. The new gym appears in the list but there is no mechanism to auto-select it post-creation. The user must manually re-open the selector.
**Fix pattern:** Pass a callback or use `@Environment` to update selection after creation. Alternatively, when returning from gym management sheet, refresh the gym list.

### Pattern 3: Multi-Select Exercise Picker with Checkboxes
**What:** Replace single-tap-dismiss picker with multi-select pattern using `Set<String>` selection state
**When to use:** Success criteria 7 (exercise selection supports multi-select)
**Current problem:** `ExercisePickerSheet` dismisses immediately on exercise tap (`onSelectExercise(exercise); dismiss()`). Users cannot add multiple exercises at once.
**Fix pattern:**
```swift
struct ExercisePickerSheet: View {
    @State private var selectedExerciseIDs: Set<String> = []

    var body: some View {
        NavigationStack {
            List(filteredExercises) { exercise in
                Button {
                    toggleSelection(exercise)
                } label: {
                    HStack {
                        ExerciseRow(exercise: exercise)
                        Spacer()
                        Image(systemName: selectedExerciseIDs.contains(exercise.id)
                            ? "checkmark.circle.fill" : "circle")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add (\(selectedExerciseIDs.count))") {
                        addSelectedExercises()
                        dismiss()
                    }
                    .disabled(selectedExerciseIDs.isEmpty)
                }
            }
        }
    }
}
```

### Pattern 4: Hevy-Style Set Layout with PREVIOUS Column
**What:** Restructure `SetRowView` to show columns: SET # | PREVIOUS | KG | REPS | checkmark
**When to use:** Success criteria 8 (Hevy-style set logging layout)
**Current problem:** Previous values appear as "last: X" hints below the input row. Hevy shows a dedicated "PREVIOUS" column inline with set data (e.g., "100 x 8") making comparison instant.
**Fix pattern:** Reorganize `SetRowView` HStack to include a read-only PREVIOUS column between set number and editable fields. Add column headers to `ExerciseSectionView`.

### Pattern 5: Custom Exercise Edit Flow
**What:** Add edit capability to `ExerciseDetailView` for custom (non-built-in) exercises
**When to use:** Success criteria 6 (custom exercises fully editable)
**Current problem:** `ExerciseDetailView` shows exercise info as read-only `LabeledContent`. There is no edit button or flow for modifying displayName, equipment, movement, or dimensions on custom exercises. Only muscle weights have an editor via `MuscleWeightEditorView`.
**Fix pattern:** Add an "Edit" toolbar button that presents either an edit sheet or navigates to an edit form pre-populated with current values. Reuse `ExerciseCreationViewModel` patterns.

### Anti-Patterns to Avoid
- **Sharing `@Observable` VM across sheet boundaries:** When passing VMs to sheets, ensure the VM outlives the sheet. Use `@State` in the parent, not a local variable.
- **Modifying `@AppStorage` from multiple views:** The `selectedGymIDString` in `GymSelectionViewModel` should be the single source of truth. Don't add another `@AppStorage` in child views.
- **Force-unwrapping SwiftData fetches:** All fixes must maintain the `try? modelContext.fetch()` pattern with nil handling.

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Multi-select list | Custom gesture handling | SwiftUI `Set<String>` selection + toggle pattern | Built-in pattern, accessible, works with VoiceOver |
| Character encoding fix | Runtime string replacement | Fix source JSON file directly | One-time fix at the source prevents ongoing overhead |
| Timer always visible in header | New timer component | Modify existing `WorkoutHeader` to show timer section always | Component already exists, just needs conditional removal of `if !timer.isExpired` guard |
| Search in picker | Build separate search | Reuse `ExercisePickerSheet` already has `.searchable` | Already implemented, just needs to be available from all entry points |

## Common Pitfalls

### Pitfall 1: Stale Gym Reference After Creation
**What goes wrong:** User creates a new gym in `GymEditView`, navigates back, but `GymSelectorSheet`'s `@Query` hasn't refreshed yet. The new gym appears but selecting it may cause issues if `GymSelectionViewModel`'s fetch-on-access returns stale data.
**Why it happens:** `GymSelectionViewModel.selectedGym` uses a computed property that fetches from `ModelContext` on every access. After sheet dismissal, the `ModelContext` may not have synced yet.
**How to avoid:** After creating a gym, explicitly save the context (`try? modelContext.save()`) which is already done. The real issue is that the gym management sheet is presented modally from within the selector sheet, creating a double-sheet dismiss scenario. Ensure the `onDisappear` or `onChange` of the management sheet re-queries.
**Warning signs:** New gym visible in list but tap does nothing, or selection reverts.

### Pitfall 2: Encoding Fix Breaking JSON Structure
**What goes wrong:** Find-and-replace on `presets_all.json` inadvertently corrupts JSON structure (breaking quotes, brackets).
**Why it happens:** The `Â°` pattern (hex `C3 82 C2 B0`) could theoretically appear in other contexts, though in this codebase it only appears in degree symbol usage.
**How to avoid:** Use targeted replacement: `Â°` -> `°` (24 occurrences confirmed). Validate JSON after replacement with `python3 -m json.tool` or `jq .`.
**Warning signs:** App crashes on launch during seed service JSON decoding.

### Pitfall 3: Multi-Select Picker Callback Ordering
**What goes wrong:** When adding multiple exercises at once, each `addExercise()` call triggers `addSet()` immediately. If the exercises array is large, UI may stutter.
**Why it happens:** `ActiveWorkoutView` calls `viewModel.addExercise(exercise)` followed by `viewModel.addSet(for: exercise)` for each exercise in a loop.
**How to avoid:** Batch the additions: collect all selected exercises, add them all, then auto-add one set for each. Use `withAnimation` around the batch.
**Warning signs:** Visual stutter when adding 5+ exercises at once.

### Pitfall 4: MuscleSlider Not Appearing Editable
**What goes wrong:** User navigates to `MuscleWeightEditorView` but sliders appear as read-only progress bars, not interactive sliders.
**Why it happens:** `MuscleWeightViewModel.isEditing` defaults to `false`. The UI shows progress bars in non-editing mode. User must tap "Edit" in toolbar to activate sliders.
**How to avoid:** For the exercise creation wizard flow (step 4), `isEditing` should default to `true` since the user explicitly navigated to set weights. For the detail view edit flow, starting in read mode is correct but the "Edit" button must be prominent.
**Warning signs:** Users report they "can't edit muscle weights" -- they can, but need to tap Edit first.

### Pitfall 5: WorkoutHeader Timer Section Disappears
**What goes wrong:** Timer section only appears in `WorkoutHeader` when `headerTimer != nil && !timer.isExpired`. Between sets (no active timer), the header layout shifts.
**Why it happens:** The timer section is conditionally rendered with `if let timer = headerTimer, !timer.isExpired`. When no timer is active, the section disappears entirely.
**How to avoid:** Always show the timer section but display "--:--" or "Rest" placeholder when no timer is active. This prevents layout shifts and provides a consistent tap target.
**Warning signs:** Header width/layout jumps when timer starts/stops.

### Pitfall 6: ExercisePickerSheet Lacks Search from Workout Flow
**What goes wrong:** The `ExercisePickerSheet` in workout flow has `.searchable()` but the exercise library view's search is separate. Success criterion 4 requires search "from all entry points."
**Why it happens:** `ExercisePickerSheet` and `ExerciseLibraryView` have independent search implementations. The picker already has search capability but may need muscle group filter tabs.
**How to avoid:** Verify that `ExercisePickerSheet` search covers displayName, searchTerms, and movement name (it does -- already implemented in Phase 5-10). If muscle group filtering is also needed, add `MuscleGroupFilterTabs` to the picker.

## Code Examples

### Example 1: Fix Degree Symbol Encoding (Bash)
```bash
# Replace mojibake Â° with proper degree symbol in presets_all.json
cd GymAnals/Resources
sed -i '' 's/Â°/°/g' presets_all.json
# Validate JSON is still valid
python3 -m json.tool presets_all.json > /dev/null && echo "Valid JSON" || echo "INVALID JSON"
```

### Example 2: Gym Indicator in Workout Header
```swift
// Add gym info to WorkoutHeader
struct WorkoutHeader: View {
    let startDate: Date
    let totalSets: Int
    let headerTimer: SetTimer?
    let gym: Gym?  // NEW: gym reference
    let onTimerTap: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            // Gym indicator row
            if let gym {
                HStack(spacing: 6) {
                    Circle()
                        .fill(gym.colorTag.color)
                        .frame(width: 8, height: 8)
                    Text(gym.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Existing header content...
            HStack { /* Duration | Sets | Timer */ }
        }
        .padding()
        .background(.regularMaterial)
    }
}
```

### Example 3: Multi-Select Toggle Pattern
```swift
// Toggle exercise in/out of selection set
private func toggleSelection(_ exercise: Exercise) {
    if selectedExerciseIDs.contains(exercise.id) {
        selectedExerciseIDs.remove(exercise.id)
    } else {
        selectedExerciseIDs.insert(exercise.id)
    }
}

// Batch add all selected exercises
private func addSelectedExercises() {
    let selected = filteredExercises.filter { selectedExerciseIDs.contains($0.id) }
    for exercise in selected {
        onSelectExercise(exercise)
    }
}
```

### Example 4: Custom Exercise Edit Form
```swift
// In ExerciseDetailView, add edit capability for custom exercises
.toolbar {
    if !exercise.isBuiltIn {
        ToolbarItem(placement: .primaryAction) {
            Button("Edit") {
                showingEditSheet = true
            }
        }
    }
}
.sheet(isPresented: $showingEditSheet) {
    CustomExerciseEditView(exercise: exercise)
}
```

### Example 5: Hevy-Style Column Headers in Exercise Section
```swift
// Column header row above sets
HStack(spacing: 6) {
    Text("SET")
        .frame(width: 24)
    Text("PREVIOUS")
        .frame(width: 80)
    Text("KG")
        .frame(width: 50)
    Text("REPS")
        .frame(width: 50)
    Spacer()
}
.font(.caption2)
.foregroundStyle(.tertiary)
.padding(.horizontal, 8)
```

## Detailed Bug Analysis

### Bug Cluster 1: Gym State Management (Success Criteria 1, 2, 10)

**SC1 - Gym switching during active workouts:**
- **Root cause:** `WorkoutTabView` does not pass `hasActiveWorkout` to `GymSelectorHeader`. The gym selector is always enabled.
- **Files to modify:** `WorkoutTabView.swift`, `GymSelectorHeader.swift`, `GymSelectorSheet.swift`
- **Fix:** Add `isDisabled` parameter to header and sheet. When `hasActiveWorkout == true`, disable the selector button or show a warning.

**SC2 - New gym immediately selectable:**
- **Root cause:** `GymEditView.save()` inserts a new gym and saves context, but `GymSelectorSheet` is dismissed separately. When user creates a gym from Manage Gyms (opened from the selector sheet), the double-dismiss flow may cause timing issues.
- **Files to modify:** `GymManagementView.swift`, `GymEditView.swift`, possibly `WorkoutTabView.swift`
- **Fix:** After creating a gym, auto-select it (set `selectedGymIDString` to the new gym's ID) or ensure the selector refreshes its `@Query` data on reappear.

**SC10 - Gym indicator in workout header:**
- **Root cause:** `WorkoutHeader` does not receive or display gym information. `ActiveWorkoutView` passes `startDate`, `totalSets`, `headerTimer`, and `onTimerTap` but not the gym.
- **Files to modify:** `WorkoutHeader.swift`, `ActiveWorkoutView.swift`
- **Fix:** Add `gym: Gym?` parameter to `WorkoutHeader`. Display gym name with color dot. Apply gym color as accent tint to the header background material.

### Bug Cluster 2: Character Encoding (Success Criterion 3)

**SC3 - Degree symbol mojibake:**
- **Root cause:** `presets_all.json` was generated with a tool that produced Latin-1 encoded bytes for `°` which, when read as UTF-8, display as `Â°`. There are exactly 24 occurrences across exercise displayNames, notes, and searchTerms.
- **Files to modify:** `GymAnals/Resources/presets_all.json`
- **Fix:** Find-and-replace `Â°` with `°` in the JSON file. Validate JSON structure after fix.

### Bug Cluster 3: Exercise Library UX (Success Criteria 4, 5, 6)

**SC4 - Exercise search from all entry points:**
- **Root cause:** `ExercisePickerSheet` already has `.searchable()` and filters by displayName, searchTerms, and movement name. However, it lacks muscle group filter tabs that `ExerciseLibraryView` has.
- **Files to modify:** `ExercisePickerSheet.swift` (possibly add `MuscleGroupFilterTabs`)
- **Fix:** Add `MuscleGroupFilterTabs` to `ExercisePickerSheet` for parity with the library view. The search itself is already implemented.

**SC5 - Muscle weight sliders functional:**
- **Root cause:** `MuscleSlider` works correctly when `isEditing == true` (shows interactive `Slider`). When `isEditing == false`, it shows a read-only progress bar. The `MuscleWeightEditorView` defaults to non-editing mode. Users must discover the "Edit" toolbar button.
- **Files to modify:** `MuscleWeightEditorView.swift`, `MuscleWeightViewModel.swift`
- **Fix:** For the creation wizard context, start in editing mode. For detail view context, make the "Edit" button more discoverable (e.g., larger, with label text). Consider auto-entering edit mode when opened from detail view's "Edit Muscle Weights" button.

**SC6 - Custom exercises fully editable:**
- **Root cause:** `ExerciseDetailView` shows all data as read-only `LabeledContent`. The only editable aspect is the muscle weight editor (for non-built-in exercises) and the favorite toggle. There is no UI to edit displayName, equipment, movement, notes, dimensions, or timer settings.
- **Files to create:** `CustomExerciseEditView.swift` (or similar)
- **Files to modify:** `ExerciseDetailView.swift`
- **Fix:** Create an edit view/sheet for custom exercises. Add "Edit" toolbar button to `ExerciseDetailView` when `!exercise.isBuiltIn`. The edit view should allow changing displayName, selecting different equipment/movement, editing dimensions, notes, rest duration, and auto-start timer.

### Bug Cluster 4: Workout Logging UI (Success Criteria 7, 8, 9)

**SC7 - Multi-select exercise picker:**
- **Root cause:** `ExercisePickerSheet` uses single-tap to select and immediately dismiss. No multi-select capability.
- **Files to modify:** `ExercisePickerSheet.swift`, `ActiveWorkoutView.swift`
- **Fix:** Add `@State private var selectedExerciseIDs: Set<String>` to picker. Change row tap to toggle selection (add/remove from set). Add "Add (N)" confirmation button. Change the callback from `(Exercise) -> Void` to `([Exercise]) -> Void`.

**SC8 - Hevy-style set logging layout:**
- **Root cause:** `SetRowView` currently shows: `[#] [reps input] x [weight input] [unit] [timer badge] [checkmark]` with previous values as small hint text below. Hevy pattern is: `[#] [PREVIOUS] [WEIGHT] [REPS] [checkmark]` with column headers.
- **Files to modify:** `SetRowView.swift`, `ExerciseSectionView.swift`
- **Fix:** Restructure SetRowView layout. Add column header row to ExerciseSectionView above the sets. Move previous values from hint row to inline PREVIOUS column.

**SC9 - Rest timer visible and editable during workouts:**
- **Root cause:** `WorkoutHeader` only shows timer when `headerTimer != nil && !timer.isExpired`. Between sets with no active timer, the timer section vanishes. The `TimerControlsPopover` only appears when tapping an active timer.
- **Files to modify:** `WorkoutHeader.swift`, `ActiveWorkoutView.swift`
- **Fix:** Always show timer section in header (with placeholder when inactive). Make timer section tappable even when no timer is active to allow manually starting a rest timer. Add default duration editing capability.

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Single-select picker with dismiss | Multi-select with Set<ID> tracking | SwiftUI standard | Fewer sheet open/close cycles for adding exercises |
| Progress bar for read-only sliders | Always-interactive sliders with clear edit state | UX best practice | Removes hidden "Edit" button friction |
| Previous values as hint text | Column-based layout (Hevy-style) | Industry standard (Hevy, Strong) | Faster visual comparison during sets |

## Open Questions

1. **Timer editing when no timer is active:**
   - What we know: Currently timer controls only appear when tapping an active timer badge. SC9 says "visible and editable."
   - What's unclear: Should users be able to manually start a rest timer from the header even when no set is confirmed? Or just edit the default rest duration?
   - Recommendation: Allow tapping header timer area to start a manual timer with default duration. Add a timer duration stepper to the popover.

2. **Exercise picker search parity:**
   - What we know: `ExercisePickerSheet` has displayName/searchTerms/movement search. `ExerciseLibraryView` also has muscle group filter tabs.
   - What's unclear: Does "search available from all entry points" mean the picker needs muscle group tabs too, or just the search bar?
   - Recommendation: Add muscle group filter tabs to the picker for full parity. The component (`MuscleGroupFilterTabs`) already exists and is reusable.

3. **Custom exercise edit scope:**
   - What we know: SC6 says "fully editable (name, equipment, movement, etc.)." The current creation wizard has 5 steps.
   - What's unclear: Should editing reuse the wizard flow or provide a simpler single-form editor?
   - Recommendation: Use a single Form-based edit view (not wizard) since the exercise already exists. Simpler UX for editing vs. creation.

## Sources

### Primary (HIGH confidence)
- Direct code review of all 63 Swift source files in `/Users/opera_user/repo/GymAnals/GymAnals/`
- `presets_all.json` grep confirming 24 `Â°` mojibake occurrences
- `WorkoutTabView.swift` confirming `hasActiveWorkout` exists but is not passed to child components
- `ExercisePickerSheet.swift` confirming single-select dismiss-on-tap behavior
- `SetRowView.swift` confirming previous values shown as hint text below input row
- `WorkoutHeader.swift` confirming conditional timer rendering (`if let timer = headerTimer, !timer.isExpired`)
- `ExerciseDetailView.swift` confirming read-only display with no edit flow for custom exercises
- `MuscleWeightEditorView.swift` confirming `isEditing` defaults to `false`

### Secondary (MEDIUM confidence)
- Hevy app feature documentation for set logging layout patterns
- SwiftUI multi-select list patterns from Hacking with Swift and community resources

### Tertiary (LOW confidence)
- None; all findings verified through direct code review

## Metadata

**Confidence breakdown:**
- Bug root causes: HIGH - All identified through direct code review
- Fix patterns: HIGH - Using established SwiftUI patterns already in the codebase
- Hevy-style layout: MEDIUM - Based on app documentation, not pixel-perfect specs
- Encoding fix: HIGH - Confirmed mojibake pattern and count in source file

**Research date:** 2026-01-28
**Valid until:** 2026-02-28 (stable - all fixes are within existing codebase)
