# Exercise Database Rework - Handoff Document

## Overview

This document provides context for reworking the iOS fitness app's exercise library to use a new research-backed muscle activation database.

## New Data Files

| File | Description |
|------|-------------|
| `presets_all.json` | 237 exercise presets with muscle weights (combined) |
| `presets_push.json` | 48 push exercises |
| `presets_legs.json` | 79 leg exercises |
| `presets_pull.json` | 62 pull exercises |
| `presets_arms_core.json` | 48 arm and core exercises |
| `movements.json` | 30 generic movement patterns |
| `equipment.json` | 22 equipment types |

## Data Model

### Exercise Preset Schema

```typescript
interface ExercisePreset {
  id: string;                    // Unique identifier (snake_case)
  displayName: string;           // Human-readable name
  searchTerms: string[];         // Alternative names for search
  movementID: string;            // Links to movements.json
  dimensions: {
    angle: string | null;        // flat, incline_15, incline_30, incline_45, decline
    gripWidth: string | null;    // narrow, standard, wide
    gripOrientation: string | null; // pronated, supinated, neutral
    stance: string | null;       // varies by movement
    laterality: string | null;   // bilateral, unilateral
  };
  equipmentID: string;           // Links to equipment.json
  muscleWeights: Record<string, number>; // Muscle activation 0.0-1.0
  notes: string;                 // Research notes and form cues
  sources: string[];             // Research citations
}
```

### Muscle Weight System

Weights are **relative activation levels** from 0.0 to 1.0:
- **1.0** = Primary mover (highest activation for this exercise)
- **0.7-0.9** = Major contributor
- **0.4-0.6** = Moderate contributor  
- **0.1-0.3** = Minor/stabilizer role

These are NOT percentages of max contraction. They represent how much each muscle contributes relative to the primary mover in that specific exercise.

### 32 Tracked Muscles

```
// Chest
pectoralisMajorUpper, pectoralisMajorLower

// Shoulders  
deltoidAnterior, deltoidLateral, deltoidPosterior

// Triceps
tricepsLongHead, tricepsLateralHead, tricepsMedialHead

// Biceps & Forearms
bicepsBrachii, bicepsBrachialis, forearms

// Back
latissimusDorsi, teresMajor, rhomboids
trapeziusUpper, trapeziusMiddle, trapeziusLower
rotatorCuff, serratusAnterior, erectorSpinae

// Core
rectusAbdominis, obliquesExternal, obliquesInternal

// Glutes
gluteusMaximus, gluteusMedius, gluteusMinimus

// Legs
quadricepsFemoris, hamstringsBicepsFemoris, hamstringsSemimembranosus
adductors, gastrocnemius, soleus
```

### Movement Patterns (30 total)

Generic movement IDs that group similar exercises:

**Push:** bench_press, overhead_press, dip, chest_fly, lateral_raise, front_raise

**Pull:** vertical_pull, horizontal_pull, shrug, rear_delt_fly, pullover

**Legs:** squat, leg_press, lunge, deadlift, hip_hinge, hip_thrust, back_extension, leg_extension, leg_curl, hip_abduction, hip_adduction, calf_raise

**Arms:** bicep_curl, preacher_curl, tricep_extension

**Core:** crunch, leg_raise, rotation, plank

### Equipment Types (22 total)

```
barbell, dumbbell, kettlebell, cable, machine, 
smith_machine, plate_loaded_machine, bodyweight, 
weighted_bodyweight, assisted, resistance_band,
suspension_trainer, landmine, medicine_ball, weight_plate,
parallel_bars, gymnastics_rings, trap_bar, ez_bar, stability_ball,
dual_cable, cable_machine_unilateral
```

## Key Design Decisions

### 1. No Delta Computation
Weights are stored directly on presets. The app does NOT compute deltas from a base movement. This simplifies the model and allows each exercise to have independently researched values.

### 2. Generic Movement IDs
Movement IDs are broad categories (e.g., `squat` not `barbell_back_squat`). The preset's `dimensions` object captures variations (grip, angle, stance).

### 3. Dimensions for Variations
Instead of separate presets for every variation, use dimensions:
- `bench_press` + `{angle: "incline_30"}` = Incline Bench Press
- `squat` + `{stance: "wide"}` = Wide Stance Squat

### 4. Relative Weights
A preset can have multiple muscles at 1.0 if they're equally primary. More commonly, one muscle is 1.0 and others are relative to it.

## Migration Considerations

### What Likely Needs to Change

1. **Exercise model/entity** - Add or update fields to match new schema
2. **Muscle enum** - Ensure all 32 muscles are defined
3. **Search** - Index `searchTerms` array for exercise lookup
4. **Movement relationships** - Update to use generic movement IDs
5. **Equipment relationships** - Add new equipment types
6. **Volume tracking** - If computing weekly muscle volume, use `muscleWeights` directly

### Sample Usage: Computing Weekly Volume

```swift
// For each completed set
func addVolumeFromSet(exercise: ExercisePreset, sets: Int, reps: Int, weight: Double) {
    let totalVolume = Double(sets * reps) * weight
    
    for (muscle, activation) in exercise.muscleWeights {
        weeklyVolume[muscle, default: 0] += totalVolume * activation
    }
}
```

### Sample Usage: Finding Exercises for a Muscle

```swift
func exercisesTargeting(_ muscle: String, minWeight: Double = 0.5) -> [ExercisePreset] {
    return allPresets.filter { preset in
        (preset.muscleWeights[muscle] ?? 0) >= minWeight
    }.sorted { 
        ($0.muscleWeights[muscle] ?? 0) > ($1.muscleWeights[muscle] ?? 0)
    }
}
```

## File Locations

After copying to your project:
```
/Resources/Data/
  ├── presets_all.json      (or split files)
  ├── movements.json
  └── equipment.json
```

Or load into Core Data / SwiftData at first launch.

## Questions to Resolve

1. **Split vs combined presets?** Use `presets_all.json` or keep category files separate?
3. **User custom exercises?** Schema supports it - just generate unique IDs
4. **Dimension editing?** Let users modify dimensions to create variations?

---

*Generated from dual-run research synthesis. 237 exercises with EMG-backed muscle activation weights.*
