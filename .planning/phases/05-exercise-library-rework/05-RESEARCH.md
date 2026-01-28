# Phase 5: Exercise Library Rework - Research

**Researched:** 2026-01-28
**Domain:** SwiftData model refactoring with data migration
**Confidence:** HIGH

## Summary

This phase involves a significant data model refactor: replacing the Variant-based exercise model with a dimensions-based model while seeding 237 research-backed exercise presets. The core challenge is migrating existing data (including WorkoutSets and ExerciseWeightHistory) while restructuring how exercises relate to movements, equipment, and muscle weights.

The existing architecture uses a Movement -> Variant -> Exercise hierarchy with VariantMuscle junction tables. The new architecture flattens this to Movement -> Exercise with embedded Dimensions struct and dictionary-based muscleWeights. This is a substantial schema change requiring VersionedSchema migration.

**Primary recommendation:** Use SwiftData's VersionedSchema with custom migration stages to handle the Variant-to-dimensions transformation, preserve existing workout data by migrating Exercise references, and seed new presets as a separate post-migration step.

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| SwiftData | iOS 17+ | Data persistence | Already in use, native Apple solution |
| Foundation | iOS 17+ | Codable structs | Embedded types require Codable conformance |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| VersionedSchema | iOS 17+ | Schema migrations | Required for Variant model removal |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Dictionary muscleWeights | Keep VariantMuscle | Dictionary is simpler but loses relationship benefits |
| Embedded Dimensions struct | Separate Dimensions model | Embedded is correct for value semantics |
| Custom migration | Lightweight migration | Cannot do lightweight when removing a model |

## Architecture Patterns

### Recommended Project Structure

```
Models/
├── Core/
│   ├── Exercise.swift      # Updated: direct movement, dimensions, muscleWeights dict
│   ├── Movement.swift      # Updated: category, subcategory, defaultMuscleWeights
│   ├── Equipment.swift     # Updated: category, properties struct
│   ├── Workout.swift       # Unchanged
│   ├── WorkoutSet.swift    # Unchanged
│   └── ExerciseWeightHistory.swift  # Unchanged
├── Enums/
│   ├── Muscle.swift        # Updated: +3 new muscles
│   ├── MuscleGroup.swift   # Unchanged
│   ├── MovementCategory.swift  # NEW
│   ├── EquipmentCategory.swift # NEW
│   └── Popularity.swift    # NEW
├── Embedded/
│   ├── Dimensions.swift    # NEW: Codable struct
│   └── EquipmentProperties.swift  # NEW: Codable struct
└── Migration/
    ├── ExerciseSchemaV1.swift  # Current schema
    ├── ExerciseSchemaV2.swift  # New schema
    └── ExerciseMigrationPlan.swift

Services/
├── Seed/
│   ├── PresetSeedService.swift  # NEW: Seeds 237 presets
│   ├── MovementSeedService.swift # NEW: Seeds 30 movements
│   └── EquipmentSeedService.swift # Updated: Seeds 22 equipment
```

### Pattern 1: VersionedSchema for Model Changes

**What:** Define each schema version as a separate enum with namespaced models
**When to use:** When removing/restructuring models (not just adding properties)
**Example:**
```swift
// Source: Apple WWDC23 "Model your schema with SwiftData"
enum ExerciseSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [Movement.self, Variant.self, VariantMuscle.self, Exercise.self, ...]
    }

    @Model final class Variant { ... }
    @Model final class VariantMuscle { ... }
}

enum ExerciseSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] {
        [Movement.self, Exercise.self, ...]  // No Variant, no VariantMuscle
    }

    @Model final class Exercise {
        var dimensions: Dimensions  // Embedded struct
        var muscleWeights: [String: Double]  // Dictionary
        var movement: Movement?  // Direct relationship
    }
}
```

### Pattern 2: Embedded Codable Structs

**What:** Use Codable structs for value-type properties (stored as composite attributes)
**When to use:** When data has single owner and doesn't need separate querying
**Example:**
```swift
// Source: fatbobman.com/en/posts/considerations-for-using-codable-and-enums-in-swiftdata-models/
struct Dimensions: Codable, Hashable {
    var angle: String?
    var gripWidth: String?
    var gripOrientation: String?
    var stance: String?
    var laterality: String?
}

@Model final class Exercise {
    var dimensions: Dimensions = Dimensions()  // Flattened into record
}
```

### Pattern 3: Dictionary Storage for Muscle Weights

**What:** Store [String: Double] instead of junction table relationship
**When to use:** When you don't need to query by individual entries
**Example:**
```swift
@Model final class Exercise {
    var muscleWeights: [String: Double] = [:]  // Stored as BLOB/composite

    // Helper for type-safe access
    func weight(for muscle: Muscle) -> Double {
        muscleWeights[muscle.rawValue] ?? 0.0
    }
}
```

### Pattern 4: Custom Migration Stage

**What:** Use willMigrate/didMigrate closures for data transformation
**When to use:** When lightweight migration isn't sufficient
**Example:**
```swift
// Source: hackingwithswift.com/quick-start/swiftdata/how-to-create-a-complex-migration-using-versionedschema
enum ExerciseMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [ExerciseSchemaV1.self, ExerciseSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }

    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: ExerciseSchemaV1.self,
        toVersion: ExerciseSchemaV2.self,
        willMigrate: { context in
            // Transform Variant data before schema change
        },
        didMigrate: { context in
            // Seed new presets after schema change
        }
    )
}
```

### Anti-Patterns to Avoid

- **Querying embedded array contents:** SwiftData stores [String] arrays as binary data; predicates on array contents crash at runtime
- **Cascade delete with explicit save:** Calling context.save() before letting autosave handle cascade deletes can break the cascade
- **Modifying Codable struct properties between versions:** Changes to embedded Codable structs can break lightweight migration and CloudKit sync
- **Using Optional properties in embedded Codable:** SwiftData's decoder struggles with optional properties in embedded structs in some cases

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Schema versioning | Manual database version tracking | VersionedSchema + SchemaMigrationPlan | Apple's solution handles edge cases |
| Muscle weight validation | Manual validation code | Muscle.allCases intersection with dictionary keys | Type-safe validation at seed time |
| Exercise display name | String concatenation | Stored displayName property | Presets have curated names |
| Search indexing | Custom full-text search | In-memory filtering + stored searchTerms | SwiftData can't query array contents via predicate |

**Key insight:** SwiftData's predicate system is limited for complex queries. The existing pattern of fetching with @Query then filtering in-memory should continue for searchTerms matching.

## Common Pitfalls

### Pitfall 1: Attempting Lightweight Migration When Removing Models

**What goes wrong:** Removing the Variant and VariantMuscle models requires custom migration, not lightweight
**Why it happens:** Lightweight migration only handles additive changes or simple renames
**How to avoid:** Use VersionedSchema with custom MigrationStage from the start
**Warning signs:** "The migration could not be performed" errors at launch

### Pitfall 2: Orphaned WorkoutSets After Exercise Schema Change

**What goes wrong:** WorkoutSets reference Exercise by UUID; if Exercise identity changes, references break
**Why it happens:** Custom migration may recreate Exercise objects with new UUIDs
**How to avoid:** Keep Exercise.id stable during migration; update relationships in-place rather than recreating
**Warning signs:** WorkoutSets with nil exercise after migration

### Pitfall 3: Dictionary Keys Not Matching Muscle.rawValue

**What goes wrong:** muscleWeights dictionary keys don't match Muscle enum rawValue, causing zero weights
**Why it happens:** JSON preset data uses different key format than Swift enum
**How to avoid:** Validate at seed time: `assert(Muscle(rawValue: key) != nil)` for each preset muscle key
**Warning signs:** Exercises show 0% for all muscles despite preset having weights

### Pitfall 4: Embedded Struct Optional Property Decoding

**What goes wrong:** SwiftData fails to decode embedded Codable struct with optional properties
**Why it happens:** SwiftData's internal decoder has known issues with optionals in nested types
**How to avoid:** Use non-optional properties with empty string defaults, or use explicit Codable implementation
**Warning signs:** Runtime crash when loading exercises with Dimensions

### Pitfall 5: Cascade Delete Not Working After Migration

**What goes wrong:** Deleting Movement doesn't cascade to Exercise in V2 schema
**Why it happens:** Cascade delete requires proper @Relationship inverse definition and autosave
**How to avoid:** Verify relationship definitions in V2 schema; test delete behavior post-migration
**Warning signs:** Orphaned exercises remaining after movement deletion

### Pitfall 6: searchTerms Array Not Queryable

**What goes wrong:** Attempting `#Predicate { $0.searchTerms.contains(searchText) }` crashes
**Why it happens:** SwiftData stores [String] as binary plist; contents aren't queryable via predicate
**How to avoid:** Fetch all exercises, filter in memory: `exercises.filter { $0.searchTerms.contains(...) }`
**Warning signs:** "unsupportedKeyPath" error at runtime

## Code Examples

### New Exercise Model Structure

```swift
// Source: CONTEXT.md decisions
@Model
final class Exercise {
    var id: String = UUID().uuidString  // snake_case for presets, UUID for custom
    var displayName: String = ""
    var searchTerms: [String] = []
    var dimensions: Dimensions = Dimensions()
    var muscleWeights: [String: Double] = [:]
    var popularityRaw: String = Popularity.common.rawValue
    var notes: String = ""
    var sources: [String] = []

    // App-specific fields
    var isFavorite: Bool = false
    var lastUsedDate: Date?
    var restDuration: TimeInterval = 120
    var autoStartTimer: Bool = true
    var isBuiltIn: Bool = false

    // Relationships
    var movement: Movement?
    var equipment: Equipment?
    var gym: Gym?

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.exercise)
    var workoutSets: [WorkoutSet] = []

    @Relationship(deleteRule: .cascade, inverse: \ExerciseWeightHistory.exercise)
    var weightHistory: [ExerciseWeightHistory] = []

    var popularity: Popularity {
        get { Popularity(rawValue: popularityRaw) ?? .common }
        set { popularityRaw = newValue.rawValue }
    }

    var isUnilateral: Bool {
        dimensions.laterality == "unilateral"
    }
}
```

### Dimensions Embedded Struct

```swift
// Source: CONTEXT.md decisions
struct Dimensions: Codable, Hashable {
    var angle: String = ""           // flat, incline_15, incline_30, incline_45, decline
    var gripWidth: String = ""       // narrow, standard, wide
    var gripOrientation: String = "" // pronated, supinated, neutral
    var stance: String = ""          // varies by movement
    var laterality: String = ""      // bilateral, unilateral

    // Use empty string instead of nil to avoid SwiftData optional decoding issues
    var isEmpty: Bool {
        angle.isEmpty && gripWidth.isEmpty && gripOrientation.isEmpty &&
        stance.isEmpty && laterality.isEmpty
    }
}
```

### Updated Movement Model

```swift
@Model
final class Movement {
    var id: String = UUID().uuidString
    var displayName: String = ""
    var categoryRaw: String = MovementCategory.push.rawValue
    var subcategory: String = ""
    var applicableDimensions: [String: [String]] = [:]  // dimension type -> valid values
    var applicableEquipment: [String] = []  // equipment IDs
    var defaultMuscleWeights: [String: Double] = [:]
    var defaultDescription: String = ""
    var notes: String = ""
    var sources: [String] = []
    var isBuiltIn: Bool = true
    var isHidden: Bool = false
    var exerciseTypeRaw: Int = ExerciseType.weightReps.rawValue

    @Relationship(deleteRule: .cascade, inverse: \Exercise.movement)
    var exercises: [Exercise] = []

    var category: MovementCategory {
        get { MovementCategory(rawValue: categoryRaw) ?? .push }
        set { categoryRaw = newValue.rawValue }
    }
}
```

### Preset Seed Service

```swift
@MainActor
final class PresetSeedService {
    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate { $0.isBuiltIn == true }
        )
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        guard let url = Bundle.main.url(forResource: "presets_all", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let presetData = try? JSONDecoder().decode(PresetData.self, from: data) else {
            print("PresetSeedService: Failed to load presets_all.json")
            return
        }

        // Fetch movements and equipment for relationship linking
        let movements = try? context.fetch(FetchDescriptor<Movement>())
        let equipment = try? context.fetch(FetchDescriptor<Equipment>())
        let movementMap = Dictionary(uniqueKeysWithValues: (movements ?? []).map { ($0.id, $0) })
        let equipmentMap = Dictionary(uniqueKeysWithValues: (equipment ?? []).map { ($0.id, $0) })

        for preset in presetData.presets {
            // Validate muscle keys at seed time
            for key in preset.muscleWeights.keys {
                assert(Muscle(rawValue: key) != nil, "Invalid muscle key: \(key)")
            }

            let exercise = Exercise()
            exercise.id = preset.id
            exercise.displayName = preset.displayName
            exercise.searchTerms = preset.searchTerms
            exercise.dimensions = Dimensions(
                angle: preset.dimensions.angle ?? "",
                gripWidth: preset.dimensions.gripWidth ?? "",
                gripOrientation: preset.dimensions.gripOrientation ?? "",
                stance: preset.dimensions.stance ?? "",
                laterality: preset.dimensions.laterality ?? ""
            )
            exercise.muscleWeights = preset.muscleWeights
            exercise.popularityRaw = preset.popularity
            exercise.notes = preset.notes
            exercise.sources = preset.sources
            exercise.isBuiltIn = true
            exercise.movement = movementMap[preset.movementID]
            exercise.equipment = equipmentMap[preset.equipmentID]

            context.insert(exercise)
        }

        try? context.save()
    }
}
```

### In-Memory Search Filtering

```swift
// Since searchTerms array can't be queried via predicate, filter in memory
private var filteredExercises: [Exercise] {
    if searchText.isEmpty {
        return exercises
    }
    let lowered = searchText.lowercased()
    return exercises.filter { exercise in
        exercise.displayName.localizedCaseInsensitiveContains(searchText) ||
        exercise.searchTerms.contains { $0.lowercased().contains(lowered) } ||
        exercise.movement?.displayName.localizedCaseInsensitiveContains(searchText) == true
    }
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Variant + VariantMuscle junction | Embedded Dimensions + Dict muscleWeights | This refactor | Simpler model, fewer entities |
| MuscleGroup filtering | MovementCategory filtering | This refactor | More intuitive exercise organization |
| Computed displayName | Stored displayName | This refactor | Preset names are curated |
| ExerciseType on Movement | ExerciseType on Exercise (via Movement) | Keep existing | No change needed |

**Deprecated/outdated:**
- Variant model: Replaced by dimensions concept
- VariantMuscle model: Replaced by muscleWeights dictionary
- primaryMuscleGroupRaw: Replaced by Movement.category for filtering

## Open Questions

1. **Migration of Existing Workouts**
   - What we know: WorkoutSet references Exercise by relationship; Exercise.id is UUID
   - What's unclear: How to preserve Exercise identity during migration if model structure changes significantly
   - Recommendation: Keep Exercise.id stable (don't recreate objects); migrate properties in-place if possible

2. **ExerciseType Location**
   - What we know: Currently on Movement; CONTEXT.md doesn't explicitly address this
   - What's unclear: Should ExerciseType move to Exercise for more flexibility?
   - Recommendation: Keep on Movement (presets inherit from movement); add override capability if needed later

3. **Custom Exercise Creation Flow**
   - What we know: Wizard currently creates Variant first, then Exercise
   - What's unclear: New flow for custom exercises without Variant
   - Recommendation: Redesign wizard to: select Movement -> set Dimensions -> pick Equipment -> adjust muscleWeights (inheriting from Movement.defaultMuscleWeights)

4. **Muscle Enum Sync with JSON Keys**
   - What we know: presets_all.json uses camelCase muscle keys (e.g., "pectoralisMajorUpper")
   - What's unclear: Are all 34 muscles (including new 3) present in JSON?
   - Recommendation: Audit JSON keys against Muscle enum after adding new muscles; add validation assertion

## Sources

### Primary (HIGH confidence)

- [Apple WWDC23: Model your schema with SwiftData](https://developer.apple.com/videos/play/wwdc2023/10195/) - VersionedSchema pattern
- [Hacking with Swift: SwiftData migrations](https://www.hackingwithswift.com/quick-start/swiftdata/how-to-create-a-complex-migration-using-versionedschema) - Custom migration stages
- [Hacking with Swift: Embedded structs and enums](https://www.hackingwithswift.com/quick-start/swiftdata/using-structs-and-enums-in-swiftdata-models) - Codable embedding

### Secondary (MEDIUM confidence)

- [fatbobman: Codable considerations in SwiftData](https://fatbobman.com/en/posts/considerations-for-using-codable-and-enums-in-swiftdata-models/) - Codable struct limitations
- [Hacking with Swift: Predicates](https://www.hackingwithswift.com/quick-start/swiftdata/how-to-filter-swiftdata-results-with-predicates) - Predicate limitations with arrays
- [Apple Forums: Cascade delete issues](https://developer.apple.com/forums/thread/740649) - Known cascade delete behaviors

### Tertiary (LOW confidence)

- [Apple Forums: Array predicate crashes](https://developer.apple.com/forums/thread/747296) - Confirms array query limitation

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Using existing SwiftData patterns already in codebase
- Architecture: HIGH - Patterns well-documented, similar refactors exist
- Migration: MEDIUM - Custom migration has edge cases; test thoroughly
- Pitfalls: HIGH - Multiple official sources confirm limitations

**Research date:** 2026-01-28
**Valid until:** 2026-02-28 (30 days - stable domain)
