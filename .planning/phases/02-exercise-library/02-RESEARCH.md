# Phase 2: Exercise Library - Research

**Researched:** 2026-01-27
**Domain:** SwiftUI exercise browser, SwiftData querying, 3D muscle visualization, custom slider controls
**Confidence:** MEDIUM-HIGH

## Summary

This phase delivers a comprehensive exercise library with search/filter, custom exercise creation wizard, and muscle weight editing with a 3D body model visualization. The research validates SwiftData querying patterns, identifies critical workarounds for enum-based filtering, and establishes RealityKit as the recommended 3D framework given SceneKit's deprecation at WWDC 2025.

Key findings:
1. **SwiftData search** requires a subview pattern where predicates are injected via initializer parameters (not inline @State)
2. **Enum filtering** in SwiftData requires storing rawValue and using computed properties (enums crash at runtime in predicates)
3. **RealityKit with RealityView** is the modern path for 3D rendering; SceneKit is deprecated
4. **JSON seeding** for 200+ exercises should use modelContainer's onSetup closure with first-launch detection
5. **Custom sliders with haptics** require SwiftUI's native `sensoryFeedback` modifier (iOS 17+) plus custom drag gesture for snap points

**Primary recommendation:** Use RealityKit for 3D muscle model, store muscle enum rawValues for filtering, implement search via subview pattern with debounced predicates.

## Standard Stack

The established libraries/tools for this domain:

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| SwiftUI | iOS 17+ | UI framework | Native Apple, required for sensoryFeedback |
| SwiftData | iOS 17+ | Persistence, queries | Already established in Phase 1 |
| RealityKit | iOS 17+ | 3D muscle model rendering | SceneKit deprecated WWDC 2025, RealityView works on iOS |
| Combine | iOS 13+ | Debounced search | Stable, simple debounce patterns |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| DebouncedOnChange | latest | Debounced onChange | Alternative to Combine if simpler API preferred |
| Steps (asam139) | latest | Wizard stepper UI | Optional - native NavigationStack may suffice |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| RealityKit | SceneKit | SceneKit deprecated, no new features, only bug fixes |
| Combine debounce | task(id:) debounce | task(id:) is simpler but less flexible |
| JSON seeding | Pre-built SQLite | Pre-built DB faster but harder to maintain |

**Installation:**
No external dependencies required - all frameworks are Apple-native.

## Architecture Patterns

### Recommended Project Structure
```
GymAnals/
├── Features/
│   └── ExerciseLibrary/
│       ├── Views/
│       │   ├── ExerciseLibraryView.swift       # Main browse view
│       │   ├── ExerciseSearchResultsView.swift # Subview with @Query
│       │   ├── ExerciseDetailView.swift        # Exercise detail/edit
│       │   ├── ExerciseCreationWizard.swift    # Multi-step wizard
│       │   ├── MuscleWeightEditor.swift        # 3D/List tab interface
│       │   └── MuscleSlider.swift              # Custom snap slider
│       ├── ViewModels/
│       │   ├── ExerciseLibraryViewModel.swift  # Search state, filters
│       │   └── MuscleWeightViewModel.swift     # Weight editing state
│       └── Components/
│           ├── MuscleGroupFilterTabs.swift     # Filter tab bar
│           ├── ExerciseRow.swift               # List row component
│           └── Muscle3DView.swift              # RealityView wrapper
├── Models/
│   └── Enums/
│       └── ExerciseType.swift                  # Weight & Reps, etc.
├── Services/
│   └── ExerciseSeedService.swift               # JSON loading at first launch
└── Resources/
    ├── exercises.json                          # 200+ exercises seed data
    └── MuscleModel.usdz                        # 3D body model asset
```

### Pattern 1: SwiftData Search with Subview Injection
**What:** Pass search parameters to a subview initializer that constructs the @Query predicate
**When to use:** Any dynamic filtering/search with SwiftData
**Example:**
```swift
// Source: https://www.hackingwithswift.com/books/ios-swiftui/dynamically-filtering-our-swiftdata-query

// Parent view holds search state
struct ExerciseLibraryView: View {
    @State private var searchText = ""
    @State private var selectedMuscleGroup: MuscleGroup?

    var body: some View {
        ExerciseSearchResultsView(
            searchText: searchText,
            muscleGroup: selectedMuscleGroup
        )
        .searchable(text: $searchText, prompt: "Search exercises")
    }
}

// Child view constructs predicate from injected parameters
struct ExerciseSearchResultsView: View {
    @Query private var exercises: [Exercise]

    init(searchText: String, muscleGroup: MuscleGroup?) {
        let muscleGroupRaw = muscleGroup?.rawValue
        _exercises = Query(filter: #Predicate<Exercise> { exercise in
            (searchText.isEmpty ||
             exercise.variant?.name.localizedStandardContains(searchText) == true) &&
            (muscleGroupRaw == nil ||
             exercise.variant?.primaryMuscleGroupRaw == muscleGroupRaw)
        }, sort: [SortDescriptor(\.variant?.name)])
    }

    var body: some View {
        List(exercises) { exercise in
            ExerciseRow(exercise: exercise)
        }
    }
}
```

### Pattern 2: Enum Filtering Workaround
**What:** Store enum rawValue as Int/String, use computed property for enum access
**When to use:** Any SwiftData model with enum properties used in predicates
**Example:**
```swift
// Source: https://azamsharp.com/2025/01/23/filtering-swiftdata-models-using-enum.html

@Model
final class Exercise {
    // Store rawValue for predicate filtering
    var exerciseTypeRaw: Int = ExerciseType.weightReps.rawValue

    // Computed property for type-safe access
    var exerciseType: ExerciseType {
        get { ExerciseType(rawValue: exerciseTypeRaw) ?? .weightReps }
        set { exerciseTypeRaw = newValue.rawValue }
    }

    init(exerciseType: ExerciseType) {
        self.exerciseTypeRaw = exerciseType.rawValue
    }
}

// In predicate:
let typeRaw = ExerciseType.weightReps.rawValue
#Predicate<Exercise> { $0.exerciseTypeRaw == typeRaw }
```

### Pattern 3: Debounced Search with Combine
**What:** Delay search execution until user pauses typing
**When to use:** Search that triggers database queries or expensive operations
**Example:**
```swift
// Source: https://danielsaidi.com/blog/2025/01/08/creating-a-debounced-search-context-for-performant-swiftui-searches

@Observable
final class ExerciseLibraryViewModel {
    var searchText = ""
    var debouncedSearchText = ""

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Debounce 300ms per CONTEXT.md spec
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .assign(to: &$debouncedSearchText)
    }
}
```

### Pattern 4: Wizard Navigation with Steps
**What:** Multi-step form with progress indicator and back/next navigation
**When to use:** Exercise creation wizard (Movement -> Variations -> Equipment -> Type -> Muscles)
**Example:**
```swift
// Source: Custom implementation based on NavigationStack patterns

struct ExerciseCreationWizard: View {
    @State private var currentStep = 0
    @State private var movementName = ""
    @State private var selectedVariations: Set<Variation> = []
    @State private var selectedEquipment: Equipment?
    @State private var exerciseType: ExerciseType = .weightReps

    let steps = ["Movement", "Variations", "Equipment", "Type", "Muscles"]

    var body: some View {
        VStack {
            // Progress dots
            HStack(spacing: 8) {
                ForEach(0..<steps.count, id: \.self) { index in
                    Circle()
                        .fill(index <= currentStep ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }

            // Step content
            TabView(selection: $currentStep) {
                MovementStep(name: $movementName).tag(0)
                VariationsStep(selections: $selectedVariations).tag(1)
                EquipmentStep(selection: $selectedEquipment).tag(2)
                ExerciseTypeStep(type: $exerciseType).tag(3)
                MuscleWeightEditor().tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}
```

### Pattern 5: RealityView for 3D Muscle Model
**What:** Non-AR 3D model display with gesture controls
**When to use:** 3D muscle visualization tab
**Example:**
```swift
// Source: https://www.createwithswift.com/displaying-3d-objects-with-realityview-on-ios-ipados-and-macos/

import RealityKit
import SwiftUI

struct Muscle3DView: View {
    @State private var rotationAngle: Float = 0
    @Binding var muscleWeights: [Muscle: Double]

    var body: some View {
        RealityView { content in
            // Load USDZ model
            if let model = try? await Entity(named: "MuscleModel") {
                content.add(model)
            }
        } update: { content in
            // Update muscle colors based on weights
            // Traverse entities and apply materials
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    rotationAngle += Float(value.translation.width) * 0.01
                }
        )
    }
}
```

### Anti-Patterns to Avoid
- **Using @State in @Query predicates:** Causes "Instance member cannot be used on type" error - use subview injection pattern instead
- **Enum in predicates directly:** Compiles but crashes at runtime - store rawValue
- **Deep relationship access in predicates:** Silent failures - keep predicate property access shallow
- **SceneKit for new 3D work:** Deprecated as of WWDC 2025 - use RealityKit
- **Parsing JSON on every launch:** Check for existing data first to prevent duplication

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Search debouncing | Custom Timer logic | Combine debounce or DebouncedOnChange package | Race conditions, cancellation edge cases |
| Haptic feedback | UIFeedbackGenerator directly | SwiftUI sensoryFeedback modifier | SwiftUI-native, cleaner API, iOS 17+ |
| 3D model rendering | Custom Metal shaders | RealityKit RealityView | Apple-optimized, handles USD natively |
| Wizard progress UI | Custom view from scratch | NavigationStack with enum state or Steps package | Navigation state management is complex |
| Case-insensitive search | Manual .lowercased() calls | localizedStandardContains() | Handles Unicode, localization properly |

**Key insight:** SwiftData predicates have many silent failure modes. When something doesn't work, it often fails silently or returns empty results rather than crashing with a helpful error.

## Common Pitfalls

### Pitfall 1: SwiftData Enum Predicate Crashes
**What goes wrong:** App crashes at runtime when filtering by enum property
**Why it happens:** SwiftData cannot translate enum types to SQL; it only understands primitives
**How to avoid:** Store enum.rawValue in model, create computed property for enum access
**Warning signs:** Empty results when filtering, or `EXC_BAD_ACCESS` crashes

### Pitfall 2: Search Predicate Not Updating
**What goes wrong:** Search results don't change when search text changes
**Why it happens:** @Query predicates cannot use @State variables from the same view
**How to avoid:** Use subview pattern - pass search parameters to child view initializer
**Warning signs:** UI shows stale results, no errors in console

### Pitfall 3: Relationship Filtering Silently Fails
**What goes wrong:** Query returns no results even when matching data exists
**Why it happens:** Deep property access in predicates (e.g., $0.variant?.movement?.name) fails silently
**How to avoid:** Keep predicate access shallow; use persistentModelID for entity comparisons
**Warning signs:** Empty results, working predicate in simple test but not in app

### Pitfall 4: JSON Seeding Runs Multiple Times
**What goes wrong:** Duplicate exercises appear in library
**Why it happens:** No check for existing data before inserting JSON
**How to avoid:** Check fetchCount > 0 before seeding; use @AppStorage flag as backup
**Warning signs:** Exercise count grows each launch, duplicates in list

### Pitfall 5: 3D Model Performance Issues
**What goes wrong:** Laggy rotation/zoom, high memory usage, battery drain
**Why it happens:** Loading high-poly model, not using LOD, updating every frame
**How to avoid:** Use optimized USDZ with LOD; batch material updates; use throttled gesture handlers
**Warning signs:** Choppy gestures, device heating, memory warnings

### Pitfall 6: Slider Haptics Fire Too Frequently
**What goes wrong:** Constant vibration while dragging, unpleasant UX
**Why it happens:** Triggering haptic on every value change instead of snap points
**How to avoid:** Track previous snap position, only fire haptic when crossing threshold
**Warning signs:** Buzzing sensation, haptic motor overworking

## Code Examples

Verified patterns from official sources:

### JSON Seeding at First Launch
```swift
// Source: https://www.hackingwithswift.com/quick-start/swiftdata/how-to-pre-load-an-app-with-json

@main
struct GymAnalsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Movement.self, Variant.self, Exercise.self]) { result in
            do {
                let container = try result.get()

                // Check if already seeded
                let descriptor = FetchDescriptor<Movement>()
                let count = try container.mainContext.fetchCount(descriptor)
                guard count == 0 else { return }

                // Load JSON
                guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json") else {
                    fatalError("exercises.json not found in bundle")
                }

                let data = try Data(contentsOf: url)
                let seedData = try JSONDecoder().decode(ExerciseSeedData.self, from: data)

                // Insert movements, variants, exercises
                for movement in seedData.movements {
                    container.mainContext.insert(movement)
                }

            } catch {
                print("Failed to seed database: \(error)")
            }
        }
    }
}
```

### Sensory Feedback on Slider Snap
```swift
// Source: https://www.hackingwithswift.com/quick-start/swiftui/how-to-add-haptic-effects-using-sensory-feedback

struct MuscleSlider: View {
    @Binding var value: Double
    @State private var snapIndex: Int = 0

    // 0.05 increments = 21 levels (0, 0.05, 0.10... 1.0)
    private let snapValues = stride(from: 0.0, through: 1.0, by: 0.05).map { $0 }

    var body: some View {
        VStack {
            Text(String(format: "%.2f", value))

            Slider(value: $value, in: 0...1, step: 0.05)
                .sensoryFeedback(.impact(weight: .light), trigger: snapIndex)
                .onChange(of: value) { oldValue, newValue in
                    let newIndex = Int(round(newValue / 0.05))
                    if newIndex != snapIndex {
                        snapIndex = newIndex
                    }
                }
        }
    }
}
```

### Muscle Group Filter Tabs with Haptic
```swift
// Source: https://swiftwithmajid.com/2023/10/10/sensory-feedback-in-swiftui/

struct MuscleGroupFilterTabs: View {
    @Binding var selectedGroup: MuscleGroup?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterTab(title: "All", isSelected: selectedGroup == nil) {
                    selectedGroup = nil
                }

                ForEach(MuscleGroup.allCases) { group in
                    FilterTab(title: group.displayName, isSelected: selectedGroup == group) {
                        selectedGroup = group
                    }
                }
            }
            .padding(.horizontal)
        }
        .sensoryFeedback(.selection, trigger: selectedGroup)
    }
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| SceneKit for 3D | RealityKit + RealityView | WWDC 2025 | SceneKit deprecated, migrate to RealityKit |
| UIImpactFeedbackGenerator | sensoryFeedback modifier | iOS 17 (2023) | SwiftUI-native haptics |
| NSPredicate (Core Data) | #Predicate macro | iOS 17 (2023) | Type-safe, compile-time checked |
| Combine for search | task(id:) debounce | iOS 15+ (option) | Simpler but less flexible |

**Deprecated/outdated:**
- **SceneKit**: Deprecated WWDC 2025, only receives critical bug fixes
- **NSPredicate with strings**: Replaced by type-safe #Predicate macro
- **UIViewRepresentable for AR**: RealityView now native SwiftUI

## Open Questions

Things that couldn't be fully resolved:

1. **3D Muscle Model Asset Source**
   - What we know: USDZ format required, Creative Commons options exist (Z-Anatomy, BodyParts3D)
   - What's unclear: Quality of free assets for iOS, whether color-per-muscle is achievable
   - Recommendation: Prototype with free asset; budget for professional model if quality insufficient

2. **RealityView Non-AR Camera Mode**
   - What we know: Documentation mentions "virtual camera" for non-AR mode
   - What's unclear: Exact API for setting virtual camera on iOS (most examples are visionOS)
   - Recommendation: Research during implementation; fallback to ARView with AR disabled if needed

3. **SwiftData Predicate Performance at Scale**
   - What we know: Works well for typical app sizes
   - What's unclear: Performance with 200+ exercises and complex muscle-based filters
   - Recommendation: Add @Index to frequently filtered properties; test with full dataset early

4. **Multi-Variation/Equipment Storage**
   - What we know: CONTEXT.md specifies multi-select for both variations and equipment
   - What's unclear: Best way to model this in SwiftData (junction table vs array)
   - Recommendation: Use junction tables (many-to-many) for query flexibility

## Sources

### Primary (HIGH confidence)
- [Hacking with Swift - SwiftData Predicates](https://www.hackingwithswift.com/quick-start/swiftdata/how-to-filter-swiftdata-results-with-predicates) - Predicate syntax, limitations, examples
- [Hacking with Swift - Dynamic Filtering](https://www.hackingwithswift.com/books/ios-swiftui/dynamically-filtering-our-swiftdata-query) - Subview injection pattern
- [Hacking with Swift - JSON Seeding](https://www.hackingwithswift.com/quick-start/swiftdata/how-to-pre-load-an-app-with-json) - First-launch data loading
- [Hacking with Swift - Sensory Feedback](https://www.hackingwithswift.com/quick-start/swiftui/how-to-add-haptic-effects-using-sensory-feedback) - iOS 17+ haptics

### Secondary (MEDIUM confidence)
- [AzamSharp - Enum Filtering Workaround](https://azamsharp.com/2025/01/23/filtering-swiftdata-models-using-enum.html) - rawValue storage pattern
- [Create with Swift - RealityView on iOS](https://www.createwithswift.com/displaying-3d-objects-with-realityview-on-ios-ipados-and-macos/) - Non-AR 3D rendering
- [Swift with Majid - Sensory Feedback](https://swiftwithmajid.com/2023/10/10/sensory-feedback-in-swiftui/) - Feedback types and usage
- [Daniel Saidi - Debounced Search](https://danielsaidi.com/blog/2025/01/08/creating-a-debounced-search-context-for-performant-swiftui-searches) - Combine debounce pattern

### Tertiary (LOW confidence - needs validation)
- WWDC 2025 SceneKit deprecation - Referenced in multiple articles but official session not directly verified
- RealityKit virtual camera for non-AR - Mentioned in tutorials, exact iOS API unclear
- Free USDZ muscle models - Availability confirmed, quality for this use case unverified

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - All Apple frameworks, well-documented
- Architecture patterns: HIGH - Established SwiftUI/SwiftData patterns
- Pitfalls: HIGH - Multiple verified sources documenting same issues
- 3D implementation: MEDIUM - RealityKit recommended but iOS non-AR examples sparse
- Asset sourcing: LOW - Free options exist but quality unverified

**Research date:** 2026-01-27
**Valid until:** 2026-02-27 (30 days - stable domain)

---

*Phase: 02-exercise-library*
*Research completed: 2026-01-27*
