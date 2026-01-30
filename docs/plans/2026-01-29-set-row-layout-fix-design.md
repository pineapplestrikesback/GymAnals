# Set Row Layout Fix & Timer Redesign

## Problem

After recent changes, the active workout set rows have several UX issues:

1. **Column misalignment** - PREVIOUS column uses `maxWidth: .infinity`, floating in the center with a large gap between it and KG/REPS fields
2. **Layout jitter on focus** - Inline +/- stepper buttons appear/disappear when fields are focused, causing columns to shift
3. **Inline timer badge takes variable space** - `SetTimerBadge` ("0:00" capsule) sits between REPS and checkmark, widening rows inconsistently
4. **Timer UX** - Inline countdown text is redundant with header timer

## Design

### 1. Proportional Column Layout

Replace the `HStack(spacing: 0)` in `SetRowView` with proportional `frame` widths.

| Column    | Weight   | Alignment | Content            |
|-----------|----------|-----------|--------------------|
| SET       | 1x       | center    | Set number         |
| PREVIOUS  | 2x       | leading   | "6 x 4" or "-"    |
| KG        | 1.5x     | center    | Weight text field  |
| REPS      | 1.5x     | center    | Reps text field    |
| Checkmark | fixed 40pt | center  | Confirm button     |

`ExerciseSectionView` column headers use the same proportional weights for perfect alignment. Layout is stable - calculated once per device width, never shifts.

### 2. Keyboard Toolbar for +/- Steppers

Remove all inline `stepperButton` views from `SetRowView`. Add a `.toolbar` modifier on `ActiveWorkoutView`:

```swift
.toolbar {
    ToolbarItemGroup(placement: .keyboard) {
        Button { decrementFocusedField() } label: {
            Image(systemName: "minus")
        }
        Button { incrementFocusedField() } label: {
            Image(systemName: "plus")
        }
        Spacer()
        Button("Done") { focusedField = nil }
    }
}
```

The toolbar reads `focusedField` to determine context:
- Weight focused: +/- adjusts by 1.0
- Reps focused: +/- adjusts by 1

Placed on `ActiveWorkoutView` (parent) to avoid duplicate toolbars.

### 3. Progress Bar Timer

Replace inline `SetTimerBadge` with a thin progress bar below each set row:

- **Height**: 3pt
- **Color**: Orange (matches existing timer theme)
- **Width**: Starts at full row width, animates linearly to 0
- **Progress**: `CGFloat(remainingSeconds) / CGFloat(totalDuration)`

**On expiry:**
1. Bar reaches zero width
2. Row background pulses once - subtle orange highlight fading in/out over ~0.6s
3. Both bar and pulse disappear, row returns to normal

**Data change:** Add `duration: TimeInterval` stored property to `SetTimer` (currently only stores `endTime`). Needed to calculate bar percentage.

Header countdown display remains unchanged - it's the only place showing actual time numbers.

## Files Changed

### Modified

| File | Changes |
|------|---------|
| `SetRowView.swift` | Proportional layout. Remove inline steppers. Remove `SetTimerBadge`. Add progress bar. Add expiry pulse. Remove focus-dependent layout logic. |
| `ExerciseSectionView.swift` | Update column headers to match proportional weights. Remove timer badge spacing. |
| `ActiveWorkoutView.swift` | Add keyboard toolbar with +/- and Done buttons. Wire increment/decrement to focused field. |
| `SetTimer.swift` | Add stored `duration: TimeInterval` property. |

### Deleted

| File | Reason |
|------|--------|
| `SetTimerBadge.swift` | Replaced entirely by progress bar. |

### Unchanged

- `WorkoutHeader.swift` - Keeps countdown display as-is
- `SetTimerManager.swift` - No changes
- `ActiveWorkoutViewModel.swift` - No changes
- All model/data layer files
