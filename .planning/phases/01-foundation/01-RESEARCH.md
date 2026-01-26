# Phase 1: Foundation - Research

**Researched:** 2026-01-26
**Domain:** SwiftData persistence, SwiftUI navigation, iOS 17+ app architecture
**Confidence:** HIGH

## Summary

This phase establishes the data persistence layer using SwiftData and creates a tab-based navigation shell for a workout tracking app targeting iOS 17+. The research confirmed SwiftData is mature enough for this use case (especially after WWDC 2025 improvements), with well-documented patterns for model relationships, seed data, and SwiftUI integration.

Key findings:
- SwiftData is suitable for offline-first apps with moderate complexity
- Pre-populating data requires SQLite VACUUM approach to disable WAL
- Hard-coded Swift enums work well for static muscle data (30-40 cases)
- Feature-based folder structure with MVVM using `@Observable` is the 2025 standard
- TabView API differs between iOS 17 and iOS 18+ (use iOS 17 approach for deployment target)

**Primary recommendation:** Use SwiftData with explicit relationship macros, bundle pre-VACUUMed SQLite for seed data, and structure the app with feature-based folders using `@Observable` ViewModels.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| SwiftData | iOS 17+ | Persistence framework | Apple's modern Core Data replacement, declarative models with `@Model` |
| SwiftUI | iOS 17+ | UI framework | Declarative UI with native `@Observable` support |
| Swift | 6.x | Language | Modern concurrency, strict type safety |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Foundation | iOS 17+ | Date, UUID, Codable | Always needed for data types |
| SQLite3 (CLI) | N/A | Database tooling | Pre-processing seed database with VACUUM |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| SwiftData | GRDB | More SQL control, but loses Apple ecosystem alignment and `@Query` integration |
| SwiftData | Core Data | More mature migrations, but verbose and not declarative |
| Hard-coded enum | SwiftData model | More flexibility, but adds persistence complexity for static data |

**No external dependencies needed** - Foundation phase uses only Apple frameworks.

## Architecture Patterns

### Recommended Project Structure
```
GymAnals/
├── App/
│   ├── GymAnalsApp.swift        # @main, ModelContainer setup
│   └── AppConstants.swift       # Global constants
├── Features/
│   ├── Workout/
│   │   ├── Views/
│   │   │   └── WorkoutTabView.swift
│   │   └── ViewModels/
│   │       └── WorkoutViewModel.swift
│   ├── Dashboard/
│   │   ├── Views/
│   │   │   └── DashboardTabView.swift
│   │   └── ViewModels/
│   ├── Settings/
│   │   ├── Views/
│   │   │   └── SettingsTabView.swift
│   │   └── ViewModels/
│   └── Shared/
│       └── Components/          # Reusable UI components
├── Models/
│   ├── Core/
│   │   ├── Muscle.swift         # Enum (hard-coded)
│   │   ├── MuscleGroup.swift    # Enum (hard-coded)
│   │   ├── Movement.swift       # @Model (seeded, extendable)
│   │   ├── Variant.swift        # @Model (seeded, extendable)
│   │   ├── Equipment.swift      # @Model (seeded, extendable)
│   │   ├── Exercise.swift       # @Model (computed from hierarchy)
│   │   ├── VariantMuscle.swift  # @Model (muscle weights)
│   │   ├── Gym.swift            # @Model (user-created)
│   │   ├── Workout.swift        # @Model
│   │   └── WorkoutSet.swift     # @Model
│   └── Enums/
│       └── WeightUnit.swift     # Enum for kg/lbs
├── Services/
│   ├── Persistence/
│   │   ├── PersistenceController.swift  # ModelContainer factory
│   │   └── SeedDataLoader.swift         # First-launch seeding
│   └── HealthKit/               # Future phase
└── Resources/
    └── SeedData/
        └── seed.store           # Pre-VACUUMed SQLite database
```

### Pattern 1: ModelContainer Configuration
**What:** Centralized SwiftData container setup with seed data loading
**When to use:** App initialization in `@main` App struct
**Example:**
```swift
// Source: Hacking with Swift - ModelContainer configuration
@main
struct GymAnalsApp: App {
    let container: ModelContainer

    init() {
        do {
            // Check if this is first launch and seed data is needed
            container = try PersistenceController.shared.createContainer()
        } catch {
            fatalError("Failed to initialize SwiftData: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
```

### Pattern 2: @Observable ViewModel with SwiftData
**What:** ViewModel using @Observable macro that accesses ModelContext
**When to use:** Any view needing business logic separation from SwiftData
**Example:**
```swift
// Source: Hacking with Swift - MVVM with SwiftData
@Observable
@MainActor
final class WorkoutViewModel {
    private let modelContext: ModelContext

    var workouts: [Workout] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func loadWorkouts() throws {
        let descriptor = FetchDescriptor<Workout>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        workouts = try modelContext.fetch(descriptor)
    }
}
```

### Pattern 3: Hard-coded Enum with CaseIterable
**What:** Static data as Swift enum with computed properties
**When to use:** Muscle definitions that don't change at runtime
**Example:**
```swift
// Source: Swift enum best practices
enum Muscle: String, CaseIterable, Codable {
    // Chest
    case pectoralisMajorUpper = "pectoralis_major_upper"
    case pectoralisMajorLower = "pectoralis_major_lower"
    case pectoralisMinor = "pectoralis_minor"
    // ... 30-40 more cases

    var displayName: String {
        switch self {
        case .pectoralisMajorUpper: return "Upper Chest"
        case .pectoralisMajorLower: return "Lower Chest"
        // ...
        }
    }

    var anatomicalName: String {
        switch self {
        case .pectoralisMajorUpper: return "Pectoralis Major (Clavicular)"
        // ...
        }
    }

    var group: MuscleGroup {
        switch self {
        case .pectoralisMajorUpper, .pectoralisMajorLower, .pectoralisMinor:
            return .chest
        // ...
        }
    }
}

enum MuscleGroup: String, CaseIterable, Codable {
    case chest, back, shoulders, arms, core, legs

    var muscles: [Muscle] {
        Muscle.allCases.filter { $0.group == self }
    }
}
```

### Pattern 4: SwiftData Hierarchical Relationships
**What:** Parent-child model relationships with cascade delete
**When to use:** Movement -> Variant -> Exercise hierarchy
**Example:**
```swift
// Source: Hacking with Swift - SwiftData relationships
@Model
final class Movement {
    var name: String
    var isBuiltIn: Bool = true
    var isHidden: Bool = false

    @Relationship(deleteRule: .cascade)
    var variants: [Variant]? = []

    init(name: String) {
        self.name = name
    }
}

@Model
final class Variant {
    var name: String
    var isBuiltIn: Bool = true

    var movement: Movement?  // Inverse relationship (optional)

    @Relationship(deleteRule: .cascade)
    var muscleWeights: [VariantMuscle]? = []

    init(name: String) {
        self.name = name
    }
}

@Model
final class VariantMuscle {
    var muscle: Muscle  // Stored as raw value (Codable enum)
    var weight: Double  // 0.0 - 1.0 contribution

    var variant: Variant?

    init(muscle: Muscle, weight: Double) {
        self.muscle = muscle
        self.weight = weight
    }
}
```

### Pattern 5: TabView for iOS 17
**What:** Tab-based navigation using iOS 17 API
**When to use:** Main app navigation shell
**Example:**
```swift
// Source: SwiftUI TabView - iOS 17 approach
struct ContentView: View {
    @State private var selectedTab: Tab = .workout

    enum Tab: String {
        case workout, dashboard, settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            WorkoutTabView()
                .tabItem {
                    Label("Workout", systemImage: "figure.strengthtraining.traditional")
                }
                .tag(Tab.workout)

            DashboardTabView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                .tag(Tab.dashboard)

            SettingsTabView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
        }
    }
}
```

### Pattern 6: NavigationStack with Large Titles
**What:** Navigation with collapsing large title behavior
**When to use:** Each tab's root view
**Example:**
```swift
// Source: SwiftUI NavigationStack customization
struct WorkoutTabView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                // Content here
            }
            .navigationTitle("Workout")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
```

### Anti-Patterns to Avoid
- **Using @Relationship on both sides:** Causes "circular reference" error. Only use on parent side.
- **Inserting parent and children explicitly:** SwiftData auto-inserts related objects. Only insert the parent.
- **Subclassing @Model classes (pre-iOS 26):** Mark model classes as `final`.
- **Storing unsupported types:** Stick to basic types (Int, Double, String, Date, URL) or stable Codable types.
- **Creating ModelContext on background threads then using on main:** Context must stay on creating thread.

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Data persistence | Custom SQLite wrapper | SwiftData | Handles migrations, relationships, thread safety |
| Reactive data updates | Manual observers | `@Query` property wrapper | Auto-updates views on data changes |
| Object-to-object mapping | Custom mapping code | SwiftData relationships | Handles foreign keys, lazy loading automatically |
| JSON seed data parsing | Custom parser | `Codable` + `JSONDecoder` | Type-safe, handles nested structures |
| Database migrations | Manual ALTER TABLE | SwiftData lightweight migration | Auto-handles additive changes |

**Key insight:** SwiftData abstracts SQLite complexity. Attempting to work around it (like accessing the underlying database) breaks its guarantees. Use SwiftData's APIs, not direct SQL.

## Common Pitfalls

### Pitfall 1: WAL Mode Prevents Database Bundling
**What goes wrong:** Pre-populated SwiftData database can't be reliably copied to app bundle
**Why it happens:** SwiftData uses SQLite WAL (write-ahead logging) which splits data across multiple files
**How to avoid:** Use SQLite VACUUM command to consolidate database before bundling:
```bash
sqlite3 source.store
VACUUM INTO 'bundle.store';
```
**Warning signs:** Missing data after bundling, database appearing empty on first launch

### Pitfall 2: Duplicate Registration on Relationship Insert
**What goes wrong:** "Fatal error: Duplicate registration attempt for object with id..."
**Why it happens:** Inserting both parent and child objects explicitly
**How to avoid:** Only insert the parent object; SwiftData auto-inserts related objects
**Warning signs:** Crash when creating objects with relationships

### Pitfall 3: Cascade Delete Not Working
**What goes wrong:** Child objects remain after parent deletion
**Why it happens:** Using `@Relationship` on both sides, or explicitly saving context before delete completes
**How to avoid:** Only use `@Relationship(deleteRule: .cascade)` on parent side, omit macro on child
**Warning signs:** Orphaned records in database

### Pitfall 4: @Query Not Updating
**What goes wrong:** View doesn't refresh when data changes
**Why it happens:** Using relationship traversal instead of direct `@Query` on child type
**How to avoid:** Use `@Query` for data that needs reactive updates, not parent.children access
**Warning signs:** Stale data in UI after modifications

### Pitfall 5: Thread-unsafe ModelContext Access
**What goes wrong:** Crashes or data corruption
**Why it happens:** Using ModelContext from wrong thread/actor
**How to avoid:** Main thread uses `@Environment(\.modelContext)`, background uses `@ModelActor`
**Warning signs:** EXC_BAD_ACCESS, sporadic crashes on save

### Pitfall 6: Large Enum Switch Exhaustion
**What goes wrong:** Massive switch statements for 30-40 muscle cases
**Why it happens:** Computing properties for each case individually
**How to avoid:** Use dictionaries or static computed properties where appropriate
**Warning signs:** 100+ line switch statements

### Pitfall 7: Seeding Data on Every Launch
**What goes wrong:** Duplicate seed data, slow launches
**Why it happens:** Not checking if database already populated
**How to avoid:** Check fetch count before seeding:
```swift
var descriptor = FetchDescriptor<Movement>()
descriptor.fetchLimit = 1
guard try context.fetch(descriptor).isEmpty else { return }
```
**Warning signs:** Duplicated exercises, slow startup

## Code Examples

Verified patterns from official sources:

### First-Launch Seed Data Check
```swift
// Source: Andrew Bancroft - Pre-populate SwiftData
func loadSeedDataIfNeeded(context: ModelContext) throws {
    var descriptor = FetchDescriptor<Movement>()
    descriptor.fetchLimit = 1

    // Only seed if database is empty
    guard try context.fetch(descriptor).isEmpty else {
        return
    }

    // Load from bundled database
    guard let seedURL = Bundle.main.url(forResource: "seed", withExtension: "store") else {
        fatalError("Seed database not found in bundle")
    }

    // Copy seed data (implementation depends on approach)
    try loadSeedData(from: seedURL, into: context)
}
```

### ModelContainer with Bundled Read-Only Data
```swift
// Source: Hacking with Swift - Pre-populate SwiftData
func createContainer() throws -> ModelContainer {
    let schema = Schema([
        Movement.self,
        Variant.self,
        VariantMuscle.self,
        Equipment.self,
        Gym.self,
        Workout.self,
        WorkoutSet.self
    ])

    // For read-only bundled data
    guard let bundleURL = Bundle.main.url(forResource: "seed", withExtension: "store") else {
        fatalError("Seed database not found")
    }

    let config = ModelConfiguration(
        schema: schema,
        url: bundleURL,
        allowsSave: false  // Read-only for bundled data
    )

    return try ModelContainer(for: schema, configurations: config)
}
```

### Dual-Store Configuration (Seed + User Data)
```swift
// Source: Hacking with Swift - Multiple configurations
func createDualContainer() throws -> ModelContainer {
    let schema = Schema([
        Movement.self, Variant.self, VariantMuscle.self, Equipment.self,
        Gym.self, Workout.self, WorkoutSet.self
    ])

    // User data - writable
    let userDataURL = URL.applicationSupportDirectory
        .appending(path: "userdata.store")
    let userConfig = ModelConfiguration(
        "UserData",
        schema: schema,
        url: userDataURL
    )

    return try ModelContainer(for: schema, configurations: userConfig)
}
```

### @Query with Predicate
```swift
// Source: Apple Developer Documentation
struct ExerciseListView: View {
    @Query(sort: \Movement.name)
    private var movements: [Movement]

    // With filtering
    @Query(filter: #Predicate<Movement> { !$0.isHidden })
    private var visibleMovements: [Movement]

    var body: some View {
        List(movements) { movement in
            Text(movement.name)
        }
    }
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| ObservableObject + @Published | @Observable macro | iOS 17 (2023) | Simpler syntax, no @Published needed |
| NavigationView | NavigationStack | iOS 16 (2022) | Programmatic navigation with path |
| Core Data | SwiftData | iOS 17 (2023) | Declarative models, less boilerplate |
| TabView (old API) | TabView + Tab (iOS 18) | iOS 18 (2024) | Type-safe tabs - but use iOS 17 API for compatibility |
| @StateObject | @State with @Observable | iOS 17 (2023) | @State now works with reference types |

**Deprecated/outdated:**
- **NavigationView:** Use NavigationStack (iOS 16+)
- **ObservableObject:** Use @Observable macro (iOS 17+)
- **@EnvironmentObject injection pattern:** Can use @Environment with @Observable

## Open Questions

Things that couldn't be fully resolved:

1. **Seed Data: Bundle Copy vs Runtime Load**
   - What we know: Both approaches work; bundled read-only is simpler but less flexible
   - What's unclear: Best approach for user-editable seed data (they can edit muscle weights)
   - Recommendation: Copy bundled database to Documents on first launch, making it writable

2. **Exercise Model: Composite or Separate Entity**
   - What we know: Hierarchy is Movement -> Variant -> (muscle weights) -> Equipment
   - What's unclear: Whether Exercise should be explicit model or computed from Variant + Equipment + Unilateral
   - Recommendation: Make Exercise an explicit @Model with references, not just computed. Simplifies Workout/WorkoutSet relationships.

3. **Per-Gym Weight History Structure**
   - What we know: Same exercise can have different weight history per gym
   - What's unclear: Best relationship structure (Exercise has many GymWeightHistory, or Gym has many ExerciseWeightHistory)
   - Recommendation: Create ExerciseWeightHistory model with references to both Exercise and Gym

## Sources

### Primary (HIGH confidence)
- [Hacking with Swift - SwiftData by Example](https://www.hackingwithswift.com/quick-start/swiftdata) - Relationships, pre-population, common errors
- [Hacking with Swift - TabView](https://www.hackingwithswift.com/quick-start/swiftui/how-to-embed-views-in-a-tab-bar-using-tabview) - iOS 17 API
- [Andrew Bancroft - Pre-populate SwiftData](https://www.andrewcbancroft.com/blog/ios-development/data-persistence/pre-populate-swiftdata-persistent-store/) - Seed data patterns
- [AzamSharp - SwiftData Architecture Patterns 2025](https://azamsharp.com/2025/03/28/swiftdata-architecture-patterns-and-practices.html) - MVVM, relationships

### Secondary (MEDIUM confidence)
- [Fatbobman - Key Considerations Before Using SwiftData](https://fatbobman.com/en/posts/key-considerations-before-using-swiftdata/) - Limitations, type restrictions
- [GitHub - VacuumTest](https://github.com/keithsharp/VacuumTest) - SQLite VACUUM approach for bundling
- [Medium - SwiftData with MVVM](https://medium.com/@darrenthiores/the-ultimate-guide-to-swiftdata-in-mvvm-achieves-separation-of-concerns-12305f9e82d1) - Separation patterns
- [Medium - Feature-based folder structure 2025](https://medium.com/@minalkewat/2025s-best-swiftui-architecture-mvvm-clean-feature-modules-3a369a22858c) - Project organization

### Tertiary (LOW confidence)
- Various Medium articles on Swift 6 concurrency - Approaches still evolving
- Apple Developer Forums threads on cascade delete issues - Workarounds may change

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Apple frameworks, well-documented
- Architecture (MVVM + @Observable): HIGH - Established pattern with official samples
- SwiftData relationships: HIGH - Multiple sources agree
- Pre-population approach: MEDIUM - Works but requires VACUUM workaround
- Pitfalls: HIGH - Documented errors with solutions

**Research date:** 2026-01-26
**Valid until:** 2026-02-26 (30 days - stable frameworks)
