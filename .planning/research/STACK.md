# Technology Stack

**Project:** iOS Workout Tracker (Per-Muscle Volume Tracking)
**Researched:** 2026-01-26
**Overall Confidence:** HIGH

---

## Recommended Stack

### Core Framework

| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| Swift | 6.x | Language | Current stable with strict concurrency, @Observable macro support, and best-in-class Swift-native async/await. Required for Swift Testing framework. | HIGH |
| SwiftUI | iOS 17+ | UI Framework | Declarative, Apple's primary investment direction. @Observable works natively. Charts integration is seamless. | HIGH |
| iOS Deployment Target | 17.0+ | Minimum OS | SwiftData requires iOS 17+. iOS 17 adoption is >85% in 2025. Your constraint says 26.2+, so this is well covered. | HIGH |

### Data Persistence

| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| SwiftData | iOS 17+ native | Local persistence | Native Apple solution, declarative @Model syntax, seamless @Query integration with SwiftUI. While slower than Core Data, the productivity gain is significant for your use case. Volume calculations and muscle tracking don't require extreme performance. | HIGH |

**Why SwiftData over GRDB:**
- Your constraint explicitly states "SwiftData for persistence"
- SwiftData is "good enough" for workout tracking data volumes (hundreds of exercises, thousands of sets)
- Native @Query property wrapper eliminates boilerplate
- Future CloudKit sync is trivial to enable
- GRDB would be overkill unless you're handling 10K+ concurrent records with complex aggregations

**SwiftData Limitations to Know:**
- Performance ranking: Direct SQLite > Core Data > SwiftData
- CloudKit sync only supports private database (no sharing between users)
- All properties must be optional or have defaults for CloudKit compatibility
- Avoid `@Attribute(.unique)` if you plan CloudKit sync later

### Data Visualization

| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| Swift Charts | iOS 16+ native | Volume dashboards, progress graphs | Apple's native charting framework. Perfect for weekly volume summaries, muscle heat maps, and exercise progress history. Supports real-time updates, animations, and accessibility out of the box. | HIGH |

**Chart Types You'll Need:**
- **BarMark**: Weekly volume per muscle group
- **LineMark**: Exercise progress over time (weight/reps)
- **AreaMark**: Volume distribution across workout
- **SectorMark**: Muscle group contribution breakdown

### Health Integration (Future)

| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| HealthKit | iOS 17+ | Workout sync, health data | Native framework. iOS 26 brings workout session APIs to iPhone/iPad (previously Watch-only). Start with read/write for workouts; expand to heart rate integration later. | HIGH |

**Note:** HealthKit integration should be Phase 2+. Get core volume tracking working first.

### Architecture Components

| Component | Implementation | Purpose | Why | Confidence |
|-----------|----------------|---------|-----|------------|
| State Management | @Observable classes | ViewModels | Replaces ObservableObject/Combine. Pull-based, property-level invalidation. Better performance than push-based @Published. | HIGH |
| View Binding | @State + @Bindable | View-ViewModel connection | @State holds @Observable reference; @Bindable for two-way bindings in views. | HIGH |
| Concurrency | Swift Concurrency (async/await) | Background operations | Native, no Combine dependency. Use @MainActor for UI-bound view models. | HIGH |
| Navigation | NavigationStack | App navigation | Modern SwiftUI navigation with type-safe paths and deep linking support. | HIGH |

### Testing

| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| Swift Testing | Xcode 16+ | Unit tests | Modern @Test macro, #expect assertions, parallel execution by default. Replaces XCTest for unit tests. | HIGH |
| XCTest | Current | UI tests only | Swift Testing doesn't support UI automation yet. Keep XCTest for XCUITest. | HIGH |

---

## Alternatives Considered

| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| Persistence | SwiftData | GRDB | Overkill for your data volume. Adds external dependency. SwiftData's productivity wins outweigh 20-30% performance delta at your scale. |
| Persistence | SwiftData | Core Data | Legacy API, verbose, Combine-centric. SwiftData is where Apple invests. Migration path exists if needed. |
| Persistence | SwiftData | Realm | External dependency, different sync model, MongoDB lock-in concerns. |
| State | @Observable | Combine + ObservableObject | Legacy pattern. @Observable is pull-based with precise invalidation vs. push-based broad updates. |
| Charts | Swift Charts | Charts (danielgindi) | External dependency. Swift Charts is native, maintained, and sufficient for fitness visualization. |
| Networking | None (local-first) | Alamofire | You don't need networking initially. When you do, URLSession + async/await is sufficient. |

---

## What NOT to Use

### Combine (for state management)
**Rationale:** @Observable replaces the need for Combine-based ObservableObject. Combine is still useful for specific reactive streams (timers, publishers), but don't build architecture around it in 2025/2026.

### Third-Party State Management (TCA, etc.)
**Rationale:** The Composable Architecture adds significant complexity. For a workout tracker with straightforward data flow, vanilla MVVM with @Observable is cleaner and more maintainable. TCA shines for apps with complex side effects and extreme testability requirements.

### UIKit
**Rationale:** Your constraint says "SwiftUI only." Good call. No hybrid architecture needed for this app type.

### External HTTP Libraries (Alamofire, Moya)
**Rationale:** URLSession with async/await covers all networking needs. Avoid dependencies until you have a concrete backend requirement.

### Realm/Firebase
**Rationale:** Lock-in concerns, different sync paradigms. SwiftData + CloudKit is the Apple-native path.

---

## Architecture Pattern

### Recommended: MVVM with @Observable

```
Feature/
├── Views/           # SwiftUI Views (thin, declarative)
├── ViewModels/      # @Observable classes (business logic)
├── Models/          # @Model structs/classes (SwiftData)
└── Components/      # Reusable view components
```

**Why MVVM:**
- Natural fit for SwiftUI + @Observable
- Clear separation: Views render, ViewModels compute, Models persist
- Testable: ViewModels can be unit tested without views
- Scalable: Feature-based folders keep codebase organized

**Key Patterns:**
```swift
// ViewModel pattern with @Observable
@Observable
@MainActor
final class WorkoutLogViewModel {
    var currentWorkout: Workout?
    var exercises: [Exercise] = []

    private let modelContext: ModelContext

    func addSet(exercise: Exercise, weight: Double, reps: Int) async {
        // Business logic here
    }
}

// View pattern
struct WorkoutLogView: View {
    @State private var viewModel: WorkoutLogViewModel

    var body: some View {
        // Thin, declarative view code
    }
}
```

---

## Project Configuration

### Package.swift / Dependencies

```swift
// NONE REQUIRED FOR INITIAL IMPLEMENTATION
// All technologies are Apple-native frameworks
```

**This is a major advantage:** Zero external dependencies for your core feature set.

### Info.plist Capabilities

```xml
<!-- Required for HealthKit (Phase 2+) -->
<key>NSHealthShareUsageDescription</key>
<string>Access workout history to import previous sessions</string>
<key>NSHealthUpdateUsageDescription</key>
<string>Save workout data to Apple Health</string>

<!-- For background workout tracking -->
<key>UIBackgroundModes</key>
<array>
    <string>processing</string>
</array>
```

---

## Version Compatibility Matrix

| Framework | Minimum iOS | Your Target (26.2+) | Status |
|-----------|-------------|---------------------|--------|
| SwiftUI | 13.0 | 26.2 | Full support |
| SwiftData | 17.0 | 26.2 | Full support |
| Swift Charts | 16.0 | 26.2 | Full support |
| HealthKit | 8.0 | 26.2 | Full support + new iOS 26 workout APIs |
| Swift Testing | 17.0 (Xcode 16) | 26.2 | Full support |
| @Observable | 17.0 | 26.2 | Full support |

Your iOS 26.2+ target gives you access to all modern APIs without compatibility concerns.

---

## SwiftData Model Design for Volume Tracking

Based on your requirements (user-defined muscles, weighted set contributions, gym-specific exercise branches):

```swift
@Model
final class Muscle {
    var name: String
    var displayOrder: Int
    var isCustom: Bool

    @Relationship(inverse: \ExerciseMuscle.muscle)
    var exerciseMuscles: [ExerciseMuscle] = []
}

@Model
final class Exercise {
    var name: String
    var notes: String?

    // Gym-specific branching
    @Relationship(inverse: \ExerciseBranch.parentExercise)
    var branches: [ExerciseBranch] = []

    @Relationship(inverse: \ExerciseMuscle.exercise)
    var muscleContributions: [ExerciseMuscle] = []
}

@Model
final class ExerciseMuscle {
    var exercise: Exercise?
    var muscle: Muscle?
    var contributionWeight: Double // 0.0-1.0 percentage
}

@Model
final class WorkoutSet {
    var weight: Double
    var reps: Int
    var timestamp: Date
    var rpe: Int? // Rate of Perceived Exertion

    var exercise: Exercise?
    var workout: Workout?

    // Computed volume (weight * reps)
    var volume: Double {
        weight * Double(reps)
    }
}
```

**Volume Calculation Strategy:**
```swift
// Per-muscle volume = sum of (set.volume * muscleContribution.weight)
func weeklyVolumeByMuscle(from workouts: [Workout]) -> [Muscle: Double] {
    // Aggregate sets, multiply by contribution weights
}
```

---

## Sources

### Official Documentation
- [Apple Developer - SwiftData](https://developer.apple.com/documentation/swiftdata)
- [Apple Developer - HealthKit](https://developer.apple.com/documentation/healthkit)
- [Apple Developer - Swift Charts](https://developer.apple.com/documentation/charts)
- [Apple Developer - Swift Testing](https://developer.apple.com/xcode/swift-testing)
- [WWDC25 - Track workouts with HealthKit on iOS and iPadOS](https://developer.apple.com/videos/play/wwdc2025/322/)

### Technical Analysis
- [Key Considerations Before Using SwiftData - Fatbobman](https://fatbobman.com/en/posts/key-considerations-before-using-swiftdata/) (MEDIUM confidence - verified against multiple sources)
- [SwiftData by Example - Hacking with Swift](https://www.hackingwithswift.com/quick-start/swiftdata) (HIGH confidence)
- [Core Data vs SwiftData 2025 - DistantJob](https://distantjob.com/blog/core-data-vs-swiftdata/) (MEDIUM confidence)
- [Swift Testing vs XCTest - Infosys](https://blogs.infosys.com/digital-experience/mobility/swift-testing-vs-xctest-a-comprehensive-comparison.html) (MEDIUM confidence)

### Architecture Patterns
- [Architecture Playbook for iOS 2025 - Medium](https://medium.com/@mrhotfix/the-architecture-playbook-for-ios-2025-swiftui-concurrency-modular-design-a35b98cbf688) (MEDIUM confidence)
- [Modern MVVM in SwiftUI 2025 - Medium](https://medium.com/@minalkewat/modern-mvvm-in-swiftui-2025-the-clean-architecture-youve-been-waiting-for-72a7d576648e) (MEDIUM confidence)

---

## Confidence Summary

| Recommendation | Confidence | Rationale |
|----------------|------------|-----------|
| Swift 6 + SwiftUI | HIGH | Apple's primary investment, stable, well-documented |
| SwiftData | HIGH | Fits your constraints, adequate for workout data volumes |
| Swift Charts | HIGH | Native, full-featured, perfect for volume visualization |
| @Observable MVVM | HIGH | Modern pattern, replaces Combine-based approaches |
| Swift Testing | HIGH | Apple's new standard, superior DX to XCTest |
| HealthKit (future) | HIGH | Native, iOS 26 brings new workout APIs to iPhone |
| Zero external deps | HIGH | Reduces maintenance, aligns with "minimal dependencies" constraint |

---

## Next Steps for Roadmap

1. **Phase 1:** Data models (Muscle, Exercise, ExerciseMuscle, Set, Workout) with SwiftData
2. **Phase 2:** Core workout logging UI with SwiftUI
3. **Phase 3:** Volume calculation engine and dashboard with Swift Charts
4. **Phase 4:** Exercise progress history and analytics
5. **Phase 5:** HealthKit integration (optional, based on priority)
6. **Phase 6:** Gym-specific exercise branching
