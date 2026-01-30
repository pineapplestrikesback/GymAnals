# Exercise Type Update Summary

## Problem
All exercises were defaulting to `weightReps` (Weight & Reps) type, which incorrectly required weight input for bodyweight exercises like pull-ups and push-ups.

## Solution
Added `exerciseTypeRaw` field to **Exercise** model (presets), NOT to Movement model, because different exercises of the same movement pattern can have different logging types.

### Why Presets, Not Movements?
- A movement like "bench_press" includes BOTH "Push-Up" (bodyweight, reps only) AND "Barbell Bench Press" (weighted)
- A movement like "vertical_pull" includes BOTH "Pull-Up" (bodyweight, reps only) AND "Lat Pulldown" (weighted)
- Exercise type is determined by the **specific exercise (preset)**, not the movement pattern

## Changes Made

### 1. Code Updates

#### Exercise.swift
- Added `exerciseTypeRaw: Int` field with default value `ExerciseType.weightReps.rawValue`
- Added computed property `exerciseType: ExerciseType` for type-safe access
- Updated initializer to accept `exerciseType` parameter

#### SeedData.swift
- Added `exerciseTypeRaw: Int?` field to `SeedPreset` struct
- Optional field defaults to 0 (weightReps) for backward compatibility

#### PresetSeedService.swift
- Updated exercise creation to read and apply `exerciseTypeRaw` from JSON
- Falls back to `weightReps (0)` if field is missing

#### presets_all.json
- Added `exerciseTypeRaw` field to all 237 presets with appropriate values

### 2. Exercise Type Classifications

#### bodyweightReps (1) - 26 presets
Pure bodyweight exercises with reps only (no weight input needed):

**Push Exercises:**
- standard_push_up, incline_push_up, decline_push_up, diamond_push_up, push_up_wide
- bench_dip

**Pull Exercises:**
- pull_up_standard_grip, pull_up_wide_grip, pull_up_neutral_grip, chin_up
- inverted_row

**Leg Exercises:**
- pistol_squat, sissy_squat
- single_leg_hip_thrust, glute_bridge
- nordic_curl, sliding_leg_curl
- side_lying_hip_abduction

**Core Exercises:**
- crunch_basic, sit_up, decline_sit_up
- hanging_leg_raise, lying_leg_raise, hanging_knee_raise
- russian_twist
- ab_wheel_rollout

#### duration (4) - 3 presets
Time-based exercises (no reps or weight):
- **plank** - Standard plank hold
- **side_plank** - Side plank hold
- **wall_sit** - Isometric squat hold

#### weightReps (0) - 208 presets
Traditional weighted exercises (barbell, dumbbell, machine, cable, etc.):
- All barbell exercises (51 presets)
- All dumbbell exercises (53 presets)
- All machine exercises (43 presets)
- All cable exercises (38 presets)
- All other equipment (23 presets)

## How It Works

### For Users Logging Workouts

#### Bodyweight Exercises (type: bodyweightReps)
When logging pull-ups, push-ups, etc.:
- **Reps only**: Enter number of reps, no weight field shown
- Simple and logical for pure bodyweight movements

#### Time-Based Exercises (type: duration)
When logging planks, wall sits:
- **Time only**: Use timer, no reps or weight fields shown

#### Traditional Weighted (type: weightReps)
When logging barbell bench press, dumbbell curls, lat pulldown, etc.:
- **Weight + Reps**: Enter both weight and reps as normal

## Architecture Decision

### Exercise Model Has Exercise Type
```
Movement: "vertical_pull"
  ├─ Exercise: "Pull-Up" → exerciseType = bodyweightReps (1)
  └─ Exercise: "Lat Pulldown" → exerciseType = weightReps (0)

Movement: "bench_press"
  ├─ Exercise: "Push-Up" → exerciseType = bodyweightReps (1)
  └─ Exercise: "Barbell Bench Press" → exerciseType = weightReps (0)

Movement: "plank"
  └─ Exercise: "Plank" → exerciseType = duration (4)
```

This design allows the same movement pattern to support different logging types based on the specific exercise variation.

## Important Notes

### For New Installs
- New app installs will automatically get correct exercise types from presets_all.json

### For Existing Users
- Existing database entries still have default `exerciseTypeRaw = 0` values
- **Migration needed**: Run database migration to update existing Exercise records
- Or: Implement "Reseed Presets" feature to update existing exercises

### Migration Script Needed
You'll need to create a migration that updates existing Exercise records in SwiftData:
```swift
// Pseudo-code for migration
// This should update all bodyweight exercises to bodyweightReps
// and time-based exercises to duration

let bodyweightPresets = [
    "pull_up_standard_grip",
    "standard_push_up",
    // ... all bodyweight preset IDs
]

let durationPresets = ["plank", "side_plank", "wall_sit"]

for presetId in bodyweightPresets {
    if let exercise = fetchExercise(id: presetId) {
        exercise.exerciseType = .bodyweightReps
    }
}

for presetId in durationPresets {
    if let exercise = fetchExercise(id: presetId) {
        exercise.exerciseType = .duration
    }
}
```

## Testing Checklist

- [ ] Build and run app with new changes
- [ ] Verify seed data loads without errors
- [ ] Test logging pull-ups: should show Reps field only (no weight)
- [ ] Test logging plank: should show Time field only
- [ ] Test logging barbell bench press: should show Reps + Weight fields
- [ ] Test logging lat pulldown: should show Reps + Weight fields
- [ ] Check that all 237 presets have correct logging interface

## Files Modified

1. `/GymAnals/GymAnals/Models/Core/Exercise.swift` - Added exerciseTypeRaw field
2. `/GymAnals/GymAnals/Services/Seed/SeedData.swift` - Added exerciseTypeRaw to SeedPreset
3. `/GymAnals/GymAnals/Services/Seed/PresetSeedService.swift` - Uses exerciseTypeRaw from JSON
4. `/GymAnals/GymAnals/Resources/presets_all.json` - Added exerciseTypeRaw to all 237 presets

## Summary Statistics

- **Total Presets**: 237
- **weightReps (0)**: 208 presets (87.8%) - Traditional weighted
- **bodyweightReps (1)**: 26 presets (11.0%) - Pure bodyweight
- **duration (4)**: 3 presets (1.3%) - Time-based

## Analysis Documents Created

1. `/exercise_type_analysis.md` - Initial (incorrect) analysis
2. `/update_preset_types.py` - Python script used to update presets_all.json
3. This document - Correct implementation summary

---

**Date**: January 29, 2026
**Status**: ✅ Complete - Ready for testing
**Corrected**: Exercise types now correctly applied to presets, not movements
