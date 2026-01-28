# Phase 5: Exercise Library Rework - Context

**Gathered:** 2026-01-28
**Status:** Ready for planning

<domain>
## Phase Boundary

Replace the Variant-based exercise model with a dimensions-based model, seed 237 research-backed presets from the agent swarm research, and update the Muscle/Equipment models to match the new data structure.

**Source data:**
- `exercise_library_refactor/presets_all.json` — 237 exercise presets
- `exercise_library_refactor/movements.json` — 30 movement patterns with defaultMuscleWeights
- `exercise_library_refactor/equipment.json` — 22 equipment types

</domain>

<decisions>
## Implementation Decisions

### Data Model Structure

**Remove Variant model entirely** — replaced by dimensions concept

**Exercise model adopts preset schema:**
```swift
Exercise {
    id: String (snake_case for presets, UUID for custom)
    displayName: String (always stored, not computed)
    searchTerms: [String]
    movement: Movement (direct @Relationship, cascade delete)
    dimensions: Dimensions (embedded struct)
    equipment: Equipment (direct @Relationship)
    muscleWeights: [String: Double] (dictionary, not VariantMuscle relationship)
    popularity: Popularity enum (very_common, common, uncommon)
    notes: String
    sources: [String]

    // App-specific fields:
    gym: Gym?
    isFavorite: Bool
    lastUsedDate: Date?
    restDuration: TimeInterval
    autoStartTimer: Bool
    isBuiltIn: Bool
}
```

**Dimensions embedded struct:**
```swift
struct Dimensions: Codable {
    var angle: String?           // flat, incline_15, incline_30, incline_45, decline, etc.
    var gripWidth: String?       // narrow, standard, wide
    var gripOrientation: String? // pronated, supinated, neutral
    var stance: String?          // varies by movement
    var laterality: String?      // bilateral, unilateral
}
```

**Movement model updates:**
- Add `applicableDimensions: [String: [String]]` — valid dimension values per dimension type
- Add `applicableEquipment: [String]` — compatible equipment IDs
- Add `defaultMuscleWeights: [String: Double]` — inherited by custom exercises
- Add `category: String` (push, pull, legs, hinge, isolation, core, squat, lunge)
- Add `subcategory: String` (horizontal_push, vertical_pull, etc.)
- Add `notes: String`
- Add `sources: [String]`

**Remove isUnilateral from Exercise** — derive from `dimensions.laterality == "unilateral"`

**Exercise filtering uses Movement.category** — not MuscleGroup

**displayName always stored** — presets have it, custom exercises user enters their own

### Preset Behavior

**Built-in presets are read-only** — `isBuiltIn = true`, cannot modify
- Users can duplicate preset to create editable copy
- Users can create fully custom exercise from scratch

**Duplicating preset keeps muscleWeights** — copy inherits the EMG-researched weights

**Custom exercises inherit Movement.defaultMuscleWeights** — then user can edit

### Muscle Taxonomy

**34 muscles total** — current 31 + 3 new

**New muscles to add:**
- `serratusAnterior` → group: back, displayName: "Serratus"
- `gluteusMinimus` → group: legs, displayName: "Glute Min"
- `adductors` → group: legs, displayName: "Adductors"

**Keep quadriceps split** — `quadricepsRectus` + `quadricepsVastus` (not combined)

**Keep pectoralisMinor** — used in movements.json defaults

**MuscleGroup enum retained** — for analytics volume grouping (not exercise filtering)

**muscleWeights dictionary keys** — must match Muscle.rawValue exactly (validated at seed time)

**Settings preference for muscle names** — toggle simple displayName vs anatomicalName

### Equipment Updates

**22 equipment types from research** — keep all with full granularity

**Equipment model additions:**
```swift
Equipment {
    id: String
    displayName: String
    category: EquipmentCategory // free_weight, cable, machine, bodyweight, band, specialty
    properties: EquipmentProperties (embedded struct)
    notes: String
    isBuiltIn: Bool
}

struct EquipmentProperties: Codable {
    var bilateralOnly: Bool
    var resistanceCurve: String // gravity, constant, variable, ascending
    var stabilizationDemand: String // minimal, low, moderate, high, very_high
    var commonInGyms: Bool
}
```

**EquipmentCategory enum:**
- free_weight, cable, machine, bodyweight, band, specialty

**Equipment variants handled as separate entries** — ez_bar and trap_bar are their own Equipment (already in the 22)

### Claude's Discretion

- Exact migration of VariantMuscle data to dictionary format
- Seeding strategy (presets_all.json vs split files)
- How to handle orphaned Workout/WorkoutSet references during model restructure
- ExerciseType enum handling with new model
- Search index implementation for searchTerms

</decisions>

<specifics>
## Specific Ideas

- "Bundled exercises/movements should be stable — users can only duplicate and then change"
- Settings preference for anatomical vs simple muscle display names
- Movement categories (push/pull/legs/etc.) for exercise filtering instead of MuscleGroup

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 05-exercise-library-rework*
*Context gathered: 2026-01-28*
