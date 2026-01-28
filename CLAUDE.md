# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build
xcodebuild -scheme GymAnals -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests
xcodebuild test -scheme GymAnals -destination 'platform=iOS Simulator,name=iPhone 16'

# Clean build
xcodebuild clean -scheme GymAnals
```

## Architecture

### Data Model (SwiftData)

The app uses a hierarchical exercise model with weighted muscle contributions:

```
Movement (e.g., "Bench Press")
  └── Variant (e.g., "Incline", "Close Grip")
        └── Exercise (user's instance, links to Equipment + Gym)
              └── VariantMuscle (weighted contribution: chest 1.0, triceps 0.3)
```

**Key relationships:**
- `Workout` contains `WorkoutSet` entries, each referencing an `Exercise`
- `Exercise` can have gym-specific branches via `ExerciseWeightHistory` (same exercise tracks different weights at different gyms)
- `Gym` has `isDefault` flag for the protected system gym

### SwiftData Patterns

**Enum storage for predicates:** SwiftData can't filter on enum types directly. Store as `rawValue` with computed property wrapper:
```swift
var primaryMuscleGroupRaw: String?  // Stored
var primaryMuscleGroup: MuscleGroup? {  // Computed, type-safe
    get { primaryMuscleGroupRaw.flatMap { MuscleGroup(rawValue: $0) } }
    set { primaryMuscleGroupRaw = newValue?.rawValue }
}
```

**Seed services:** First-launch data seeding via `seedIfNeeded(context:)` pattern, called from `GymAnalsApp.init()`. Detection uses `fetchCount == 0`.

**Preview containers:** Use `PersistenceController.preview` for in-memory SwiftUI previews.

### Feature Structure

Each feature follows MVVM with this layout:
```
Features/{FeatureName}/
  ├── Views/           # SwiftUI views
  ├── ViewModels/      # @Observable classes
  └── Components/      # Reusable subviews
```

**ViewModel pattern:** `@Observable @MainActor final class` with `ModelContext` dependency. Use `@ObservationIgnored` on `@AppStorage` properties to prevent double-triggering.

### Key Conventions

- **Views:** Thin, delegate logic to ViewModels
- **Models:** `@Model` classes with `UUID` id, cascade delete on parent relationships only
- **Enums:** `String` raw values, `CaseIterable`, `Codable`
- **Async:** Use `Task {}` for debouncing in `@Observable` (not Combine)
