# Architecture Patterns

**Domain:** iOS Workout Tracker with Precise Muscle Volume Tracking
**Researched:** 2026-01-26
**Confidence:** HIGH (based on Apple documentation, established SwiftUI patterns, and real-world open-source examples)

## Recommended Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                           SwiftUI Views                              │
│  (Workout Log, Exercise Library, Volume Dashboard, History)         │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   │ @Observable binding
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         ViewModels (@Observable)                     │
│  (WorkoutLogViewModel, ExerciseLibraryViewModel, VolumeViewModel)   │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                    ┌──────────────┼──────────────┐
                    │              │              │
                    ▼              ▼              ▼
            ┌───────────┐  ┌───────────┐  ┌───────────┐
            │ Services  │  │ SwiftData │  │  Compute  │
            │(optional) │  │ @Query    │  │  Engine   │
            └───────────┘  └───────────┘  └───────────┘
                                   │
                                   ▼
            ┌─────────────────────────────────────────┐
            │           SwiftData Models              │
            │  (Muscle, Exercise, Workout, Set, Gym)  │
            └─────────────────────────────────────────┘
```

### Component Boundaries

| Component | Responsibility | Communicates With |
|-----------|---------------|-------------------|
| **Views** | Present UI, capture user intent, display state | ViewModels (via @Observable binding) |
| **ViewModels** | Business logic, state management, data transformation | SwiftData (@Query), Compute Engine |
| **SwiftData Models** | Define data schema, persist state, relationships | ModelContext, ModelContainer |
| **Compute Engine** | Volume calculations, progress metrics | ViewModels (pure functions, stateless) |
| **Services** (optional) | HealthKit, future integrations | ViewModels (injected dependencies) |

### Data Flow

**Read Path (View displays data):**
```
SwiftData Models → @Query in View/ViewModel → View renders
```

**Write Path (User creates/updates):**
```
User action → View → ViewModel method → ModelContext.insert/update → SwiftData persists
```

**Computed Values (Volume calculations):**
```
@Query fetches sets → Compute Engine calculates → ViewModel exposes → View displays
```

## Core Data Model

### Entity Relationship Diagram

```
                    ┌─────────────┐
                    │   Muscle    │
                    │─────────────│
                    │ id: UUID    │
                    │ name: String│
                    │ sortOrder   │
                    └──────┬──────┘
                           │
                           │ many-to-many via
                           │ ExerciseMuscle
                           ▼
┌─────────────┐    ┌────────────────────┐    ┌─────────────┐
│     Gym     │    │ ExerciseMuscle     │    │  Exercise   │
│─────────────│    │────────────────────│    │─────────────│
│ id: UUID    │    │ muscle: Muscle     │    │ id: UUID    │
│ name: String│    │ exercise: Exercise │    │ name: String│
│ sortOrder   │    │ contribution: Float│    │ notes: String│
└──────┬──────┘    └────────────────────┘    └──────┬──────┘
       │                                            │
       │                                            │
       │           ┌─────────────────────┐          │
       └──────────►│   ExerciseBranch    │◄─────────┘
                   │─────────────────────│
                   │ id: UUID            │
                   │ exercise: Exercise  │
                   │ gym: Gym (optional) │
                   │ lastWeight: Double? │
                   │ notes: String       │
                   └──────────┬──────────┘
                              │
                              │ inverse
                              ▼
                   ┌─────────────────────┐
                   │     WorkoutSet      │
                   │─────────────────────│
                   │ id: UUID            │
                   │ exerciseBranch      │
                   │ reps: Int           │
                   │ weight: Double      │
                   │ completedAt: Date   │
                   │ setNumber: Int      │
                   └──────────┬──────────┘
                              │
                              │ inverse
                              ▼
                   ┌─────────────────────┐
                   │      Workout        │
                   │─────────────────────│
                   │ id: UUID            │
                   │ startedAt: Date     │
                   │ endedAt: Date?      │
                   │ gym: Gym?           │
                   │ notes: String       │
                   │ sets: [WorkoutSet]  │
                   └─────────────────────┘
```

### SwiftData Model Definitions

```swift
// Muscle.swift
@Model
final class Muscle {
    @Attribute(.unique) var id: UUID
    var name: String
    var sortOrder: Int

    // Inverse handled via ExerciseMuscle junction table
    @Relationship(deleteRule: .cascade, inverse: \ExerciseMuscle.muscle)
    var exerciseMuscles: [ExerciseMuscle] = []

    init(name: String, sortOrder: Int = 0) {
        self.id = UUID()
        self.name = name
        self.sortOrder = sortOrder
    }
}

// Exercise.swift
@Model
final class Exercise {
    @Attribute(.unique) var id: UUID
    var name: String
    var notes: String

    @Relationship(deleteRule: .cascade, inverse: \ExerciseMuscle.exercise)
    var exerciseMuscles: [ExerciseMuscle] = []

    @Relationship(deleteRule: .cascade, inverse: \ExerciseBranch.exercise)
    var branches: [ExerciseBranch] = []

    init(name: String, notes: String = "") {
        self.id = UUID()
        self.name = name
        self.notes = notes
    }
}

// ExerciseMuscle.swift (junction table for weighted contributions)
@Model
final class ExerciseMuscle {
    @Attribute(.unique) var id: UUID
    var muscle: Muscle
    var exercise: Exercise
    var contribution: Double  // 0.0 to 1.0

    init(muscle: Muscle, exercise: Exercise, contribution: Double) {
        self.id = UUID()
        self.muscle = muscle
        self.exercise = exercise
        self.contribution = min(max(contribution, 0.0), 1.0)
    }
}

// Gym.swift
@Model
final class Gym {
    @Attribute(.unique) var id: UUID
    var name: String
    var sortOrder: Int

    @Relationship(deleteRule: .nullify, inverse: \ExerciseBranch.gym)
    var branches: [ExerciseBranch] = []

    @Relationship(deleteRule: .nullify, inverse: \Workout.gym)
    var workouts: [Workout] = []

    init(name: String, sortOrder: Int = 0) {
        self.id = UUID()
        self.name = name
        self.sortOrder = sortOrder
    }
}

// ExerciseBranch.swift (gym-specific exercise instance)
@Model
final class ExerciseBranch {
    @Attribute(.unique) var id: UUID
    var exercise: Exercise
    var gym: Gym?  // nil = default/home
    var lastWeight: Double?
    var notes: String

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.exerciseBranch)
    var sets: [WorkoutSet] = []

    init(exercise: Exercise, gym: Gym? = nil, notes: String = "") {
        self.id = UUID()
        self.exercise = exercise
        self.gym = gym
        self.notes = notes
    }
}

// WorkoutSet.swift
@Model
final class WorkoutSet {
    @Attribute(.unique) var id: UUID
    var exerciseBranch: ExerciseBranch
    var workout: Workout
    var reps: Int
    var weight: Double
    var completedAt: Date
    var setNumber: Int

    init(exerciseBranch: ExerciseBranch, workout: Workout, reps: Int, weight: Double, setNumber: Int) {
        self.id = UUID()
        self.exerciseBranch = exerciseBranch
        self.workout = workout
        self.reps = reps
        self.weight = weight
        self.completedAt = Date()
        self.setNumber = setNumber
    }
}

// Workout.swift
@Model
final class Workout {
    @Attribute(.unique) var id: UUID
    var startedAt: Date
    var endedAt: Date?
    var gym: Gym?
    var notes: String

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.workout)
    var sets: [WorkoutSet] = []

    init(gym: Gym? = nil, notes: String = "") {
        self.id = UUID()
        self.startedAt = Date()
        self.gym = gym
        self.notes = notes
    }

    var isActive: Bool { endedAt == nil }
}
```

## Component Details

### 1. Views Layer

**Feature-based organization:**

```
Features/
├── WorkoutLog/
│   ├── WorkoutLogView.swift         # Active workout screen
│   ├── WorkoutLogViewModel.swift    # Manages workout state
│   ├── SetInputView.swift           # Reps/weight entry
│   └── ExercisePickerView.swift     # Select exercise to add
├── ExerciseLibrary/
│   ├── ExerciseListView.swift       # Browse exercises
│   ├── ExerciseDetailView.swift     # Edit exercise + muscles
│   └── MuscleContributionEditor.swift # Set contribution weights
├── VolumeDashboard/
│   ├── VolumeDashboardView.swift    # Weekly volume overview
│   ├── MuscleVolumeCard.swift       # Per-muscle volume display
│   └── VolumeChartView.swift        # Visual volume breakdown
├── History/
│   ├── WorkoutHistoryView.swift     # Past workouts list
│   └── WorkoutDetailView.swift      # View past workout
└── Settings/
    ├── MuscleManagerView.swift      # CRUD for muscles
    └── GymManagerView.swift         # CRUD for gyms
```

### 2. ViewModels Layer

```swift
// WorkoutLogViewModel.swift
@Observable
final class WorkoutLogViewModel {
    private var modelContext: ModelContext

    var activeWorkout: Workout?
    var currentExerciseSets: [WorkoutSet] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func startWorkout(at gym: Gym?) { ... }
    func addSet(branch: ExerciseBranch, reps: Int, weight: Double) { ... }
    func endWorkout() { ... }
}

// VolumeViewModel.swift
@Observable
final class VolumeViewModel {
    private var modelContext: ModelContext
    private let volumeCalculator: VolumeCalculator

    var weeklyVolumeByMuscle: [Muscle: Double] = [:]
    var dateRange: DateInterval

    func calculateVolume(for sets: [WorkoutSet]) -> [Muscle: Double] {
        volumeCalculator.calculate(sets: sets)
    }
}
```

### 3. Compute Engine (Volume Calculation)

**Pure functions for volume calculation:**

```swift
// VolumeCalculator.swift
struct VolumeCalculator {
    /// Calculate volume per muscle from a collection of workout sets
    /// Volume = sum of (sets × reps × contribution_weight)
    /// Note: Weight is intentionally excluded - volume tracks "work" not "load"
    func calculate(sets: [WorkoutSet]) -> [Muscle: Double] {
        var volumeByMuscle: [Muscle: Double] = [:]

        for set in sets {
            let exercise = set.exerciseBranch.exercise
            for em in exercise.exerciseMuscles {
                let contribution = em.contribution
                let volume = Double(set.reps) * contribution
                volumeByMuscle[em.muscle, default: 0] += volume
            }
        }

        return volumeByMuscle
    }

    /// Alternative: Include weight for "volume load" calculation
    func calculateVolumeLoad(sets: [WorkoutSet]) -> [Muscle: Double] {
        var volumeByMuscle: [Muscle: Double] = [:]

        for set in sets {
            let exercise = set.exerciseBranch.exercise
            for em in exercise.exerciseMuscles {
                let contribution = em.contribution
                let volumeLoad = Double(set.reps) * set.weight * contribution
                volumeByMuscle[em.muscle, default: 0] += volumeLoad
            }
        }

        return volumeByMuscle
    }
}
```

### 4. SwiftData Integration

**ModelContainer setup:**

```swift
// GymAnalsApp.swift
@main
struct GymAnalsApp: App {
    let modelContainer: ModelContainer

    init() {
        let schema = Schema([
            Muscle.self,
            Exercise.self,
            ExerciseMuscle.self,
            Gym.self,
            ExerciseBranch.self,
            WorkoutSet.self,
            Workout.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none  // Local-first for v1
        )

        do {
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
```

## Patterns to Follow

### Pattern 1: @Query in Views for Simple Lists

**What:** Use SwiftData's @Query macro directly in views for read-only lists
**When:** Displaying simple filtered/sorted collections
**Example:**

```swift
struct ExerciseListView: View {
    @Query(sort: \Exercise.name) private var exercises: [Exercise]

    var body: some View {
        List(exercises) { exercise in
            NavigationLink(value: exercise) {
                ExerciseRow(exercise: exercise)
            }
        }
    }
}
```

### Pattern 2: ViewModel for Complex State

**What:** Use @Observable ViewModels when state management is complex
**When:** Active workout session, computed values, multi-step operations
**Example:**

```swift
struct WorkoutLogView: View {
    @State private var viewModel: WorkoutLogViewModel

    init(modelContext: ModelContext) {
        _viewModel = State(initialValue: WorkoutLogViewModel(modelContext: modelContext))
    }

    var body: some View {
        // View that interacts with viewModel
    }
}
```

### Pattern 3: Junction Tables for Weighted Many-to-Many

**What:** Use explicit junction model when relationship has attributes
**When:** Exercise-Muscle relationship needs contribution weight
**Example:**

```swift
// Don't do: var muscles: [Muscle] (loses contribution data)
// Do: var exerciseMuscles: [ExerciseMuscle] (includes contribution)
```

### Pattern 4: Soft Cascades via Delete Rules

**What:** Use appropriate delete rules to maintain data integrity
**When:** Defining SwiftData relationships
**Rules:**
- `.cascade` when child has no meaning without parent (WorkoutSet without Workout)
- `.nullify` when child can exist independently (ExerciseBranch can lose Gym reference)

## Anti-Patterns to Avoid

### Anti-Pattern 1: Massive Views

**What:** Putting business logic, data fetching, and UI in one View
**Why bad:** Untestable, hard to maintain, violates separation of concerns
**Instead:** Extract business logic to ViewModels, keep views thin

### Anti-Pattern 2: Over-Engineering for Simple Cases

**What:** Creating ViewModels for trivial read-only lists
**Why bad:** SwiftUI + SwiftData handles this elegantly with @Query
**Instead:** Use @Query directly in views for simple CRUD screens

### Anti-Pattern 3: Implicit Relationships Without Inverses

**What:** Relying on SwiftData's inferred relationships for complex models
**Why bad:** Can cause cascade delete failures, confusing behavior
**Instead:** Always explicitly declare inverse relationships per [Apple guidance](https://developer.apple.com/documentation/swiftdata/relationship(_:deleterule:minimummodelcount:maximummodelcount:originalname:inverse:hashmodifier:))

### Anti-Pattern 4: Storing Computed Values

**What:** Persisting volume calculations in the database
**Why bad:** Data can become stale, must re-calculate on every contribution change
**Instead:** Calculate on-demand from source data, cache in ViewModel if needed

### Anti-Pattern 5: Global Singleton ViewModels

**What:** Using shared singletons for state management
**Why bad:** Makes testing difficult, creates hidden dependencies
**Instead:** Inject dependencies via initializers or environment

## Build Order (Dependencies)

Based on the component dependencies, here is the recommended build order:

### Phase 1: Foundation (No Dependencies)

1. **SwiftData Models** - Define all @Model classes
   - Muscle, Gym (standalone entities)
   - Exercise, ExerciseMuscle (exercise system)
   - ExerciseBranch, WorkoutSet, Workout (workout system)

2. **App Shell + Navigation**
   - Tab-based navigation structure
   - ModelContainer setup

**Rationale:** Everything else depends on models existing.

### Phase 2: Core CRUD (Depends on Phase 1)

3. **Settings/Management Views**
   - MuscleManagerView (create/edit muscles)
   - GymManagerView (create/edit gyms)

4. **Exercise Library**
   - ExerciseListView
   - ExerciseDetailView + MuscleContributionEditor

**Rationale:** Users need to set up their muscle list and exercises before tracking workouts.

### Phase 3: Workout Logging (Depends on Phases 1-2)

5. **Workout Session**
   - WorkoutLogViewModel
   - WorkoutLogView
   - SetInputView, ExercisePickerView

**Rationale:** Requires exercises and gyms to exist.

### Phase 4: Analytics (Depends on Phases 1-3)

6. **Volume Dashboard**
   - VolumeCalculator (compute engine)
   - VolumeViewModel
   - VolumeDashboardView

7. **History**
   - WorkoutHistoryView
   - WorkoutDetailView

**Rationale:** Requires logged workout data to display.

### Dependency Graph

```
┌───────────────────────────────────────────────────────────────┐
│ Phase 1: Foundation                                           │
│ ┌─────────────────────────┐  ┌─────────────────────────────┐  │
│ │ SwiftData Models        │  │ App Shell + Navigation      │  │
│ └─────────────────────────┘  └─────────────────────────────┘  │
└───────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌───────────────────────────────────────────────────────────────┐
│ Phase 2: Core CRUD                                            │
│ ┌─────────────────────────┐  ┌─────────────────────────────┐  │
│ │ Muscle/Gym Management   │  │ Exercise Library            │  │
│ └─────────────────────────┘  └─────────────────────────────┘  │
└───────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌───────────────────────────────────────────────────────────────┐
│ Phase 3: Workout Logging                                      │
│ ┌─────────────────────────────────────────────────────────┐   │
│ │ Workout Session (ViewModel + Views)                     │   │
│ └─────────────────────────────────────────────────────────┘   │
└───────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌───────────────────────────────────────────────────────────────┐
│ Phase 4: Analytics                                            │
│ ┌─────────────────────────┐  ┌─────────────────────────────┐  │
│ │ Volume Dashboard        │  │ Workout History             │  │
│ └─────────────────────────┘  └─────────────────────────────┘  │
└───────────────────────────────────────────────────────────────┘
```

## iOS-Specific Considerations

### SwiftUI Navigation (iOS 17+)

Use `NavigationStack` with typed navigation destinations:

```swift
@Observable
final class NavigationRouter {
    var exercisePath: [Exercise] = []
    var workoutPath: [Workout] = []
}
```

### @Observable vs ObservableObject

For iOS 17+, prefer `@Observable` macro over `ObservableObject`:
- Simpler syntax (no `@Published` needed)
- Better performance (fine-grained observation)
- Use `@State` to own the ViewModel in a View

### SwiftData @Query Limitations

- `@Query` can only be used in SwiftUI views
- For ViewModels, fetch via `ModelContext` directly
- Complex predicates may need `#Predicate` macro

## Sources

### HIGH Confidence (Official Documentation)
- [Apple SwiftData Documentation](https://developer.apple.com/xcode/swiftdata)
- [Apple @Relationship Macro Reference](https://developer.apple.com/documentation/swiftdata/relationship(_:deleterule:minimummodelcount:maximummodelcount:originalname:inverse:hashmodifier:))
- [Apple Schema.Relationship.DeleteRule](https://developer.apple.com/documentation/swiftdata/schema/relationship/deleterule-swift.enum)

### HIGH Confidence (Established Tutorials)
- [Hacking with Swift - SwiftData by Example](https://www.hackingwithswift.com/quick-start/swiftdata)
- [Hacking with Swift - One-to-Many Relationships](https://www.hackingwithswift.com/quick-start/swiftdata/how-to-create-one-to-many-relationships)
- [Hacking with Swift - Cascade Deletes](https://www.hackingwithswift.com/quick-start/swiftdata/how-to-create-cascade-deletes-using-relationships)
- [SwiftData Relationships - tanaschita.com](https://tanaschita.com/20240219-swiftdata-relationships/)

### MEDIUM Confidence (Community Patterns)
- [AzamSharp - SwiftData Architecture Patterns](https://azamsharp.com/2025/03/28/swiftdata-architecture-patterns-and-practices.html)
- [SwiftUI MVVM Best Practices - zthh.dev](https://zthh.dev/blogs/swiftui-mvvm-best-practices-tips-techniques)
- [Relationships in SwiftData - FatBobMan](https://fatbobman.com/en/posts/relationships-in-swiftdata-changes-and-considerations/)
- [Matteo Manferdini - MVVM in SwiftUI](https://matteomanferdini.com/swiftui-mvvm/)

### MEDIUM Confidence (Open Source Examples)
- [TeymiaHabit - SwiftUI/SwiftData Habit Tracker](https://github.com/amanbayserkeev0377/TeymiaHabit)
- [SwiftLift - iOS Workout Tracker](https://github.com/jadenzaleski/SwiftLift)
- [Fitness App - SwiftUI/Core Data](https://github.com/Imen-ks/Fitness)

### MEDIUM Confidence (Volume Tracking Domain)
- [Hevy App - Sets Per Muscle Group](https://www.hevyapp.com/features/sets-per-muscle-group-per-week/)
- [Fitbod - Personalized Workout Algorithms](https://fitbod.me/blog/the-best-personalized-workout-apps-for-strength-training-ranked-by-real-results-2025/)
