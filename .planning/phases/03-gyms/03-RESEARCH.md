# Phase 3: Gyms - Research

**Researched:** 2026-01-27
**Domain:** SwiftData gym management, persistent selection, exercise branching, gym-specific weight history
**Confidence:** HIGH

## Summary

This phase implements gym definitions and gym-specific exercise tracking. Users can create gyms with color tags, select their current gym (persisted across sessions), and create "branches" of exercises that track independent weight history per gym. The core data models (Gym, ExerciseWeightHistory) already exist from Phase 1; this phase focuses on the UI/UX layer and the branching logic.

Key findings:
1. **Persisting selected gym** requires storing UUID string in @AppStorage, then querying SwiftData to resolve the Gym object
2. **Color tag selection** should use a predefined palette (not full ColorPicker) with SwiftUI's `.palette` picker style
3. **Exercise branching** is a conceptual pattern - gym-specific weight history already exists via ExerciseWeightHistory model with gym reference
4. **Gym deletion with merge** requires manual relationship transfer before deletion (no SwiftData API for this)
5. **Default Gym** should be created via GymSeedService on first launch (same pattern as ExerciseSeedService)

**Primary recommendation:** Use @AppStorage for gym UUID persistence, predefined color palette stored as String rawValue, and confirmationDialog for deletion options. Exercise "branches" are simply filtered views of ExerciseWeightHistory by gym.

## Standard Stack

The established libraries/tools for this domain:

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| SwiftUI | iOS 17+ | UI framework | Native @AppStorage, presentationDetents, confirmationDialog |
| SwiftData | iOS 17+ | Persistence | Already established; Gym model exists |
| Foundation | iOS 17+ | UUID, Codable | UUID.uuidString for @AppStorage storage |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| None required | - | - | All functionality achievable with Apple frameworks |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Predefined color palette | ColorPicker | ColorPicker too flexible - palette ensures visual consistency |
| @AppStorage UUID | SwiftData "Settings" model | Settings model adds complexity for single value |
| confirmationDialog | Custom sheet | confirmationDialog is standard iOS delete pattern |

**Installation:**
No external dependencies required - all frameworks are Apple-native.

## Architecture Patterns

### Recommended Project Structure
```
GymAnals/
├── Features/
│   ├── Workout/
│   │   ├── Views/
│   │   │   ├── WorkoutTabView.swift          # Add gym selector header
│   │   │   ├── GymSelectorSheet.swift        # Gym selection sheet
│   │   │   └── GymManagementView.swift       # Full gym CRUD
│   │   ├── ViewModels/
│   │   │   └── GymSelectionViewModel.swift   # Selection state, persistence
│   │   └── Components/
│   │       ├── GymSelectorHeader.swift       # Gym name + color dot
│   │       └── GymColorPicker.swift          # Predefined color palette
│   └── ExerciseLibrary/
│       └── Views/
│           └── ExerciseDetailView.swift      # Add gym branches section
├── Models/
│   ├── Core/
│   │   └── Gym.swift                         # Add colorTag property
│   └── Enums/
│       └── GymColor.swift                    # NEW: Predefined gym colors
├── Services/
│   └── Seed/
│       └── GymSeedService.swift              # NEW: Create Default Gym
└── App/
    └── AppConstants.swift                    # Add defaultGymName constant
```

### Pattern 1: @AppStorage with SwiftData Object Resolution
**What:** Store UUID string in UserDefaults, resolve to SwiftData object on access
**When to use:** Persisting selected gym between app sessions
**Example:**
```swift
// Source: https://chriswu.com/posts/swiftui/appstoragepicker/

@Observable
@MainActor
final class GymSelectionViewModel {
    @ObservationIgnored
    @AppStorage("selectedGymID") private var selectedGymIDString: String = ""

    private let modelContext: ModelContext

    var selectedGym: Gym? {
        get {
            guard let uuid = UUID(uuidString: selectedGymIDString) else { return nil }
            let descriptor = FetchDescriptor<Gym>(predicate: #Predicate { $0.id == uuid })
            return try? modelContext.fetch(descriptor).first
        }
        set {
            selectedGymIDString = newValue?.id.uuidString ?? ""
        }
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
}
```

### Pattern 2: Predefined Color Palette with Enum
**What:** Store color as String rawValue, display as predefined palette selection
**When to use:** Gym color tag selection (limited choices for visual consistency)
**Example:**
```swift
// Source: https://appmakers.dev/picker-and-paletteselectioneffect-in-swiftui/

enum GymColor: String, CaseIterable, Codable {
    case red, orange, yellow, green, blue, purple, pink, gray

    var color: Color {
        switch self {
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .blue: return .blue
        case .purple: return .purple
        case .pink: return .pink
        case .gray: return .gray
        }
    }
}

struct GymColorPicker: View {
    @Binding var selectedColor: GymColor

    var body: some View {
        Picker("Color", selection: $selectedColor) {
            ForEach(GymColor.allCases, id: \.self) { gymColor in
                Circle()
                    .fill(gymColor.color)
                    .frame(width: 24, height: 24)
                    .tag(gymColor)
            }
        }
        .pickerStyle(.palette)
    }
}
```

### Pattern 3: Gym Model with Color Tag (rawValue storage)
**What:** Store enum rawValue in SwiftData model for predicate compatibility
**When to use:** Gym color tag (follows existing pattern from Phase 2)
**Example:**
```swift
// Source: Existing codebase pattern from Variant.primaryMuscleGroupRaw

@Model
final class Gym {
    var id: UUID = UUID()
    var name: String = ""
    var isDefault: Bool = false  // NEW: Mark system default gym
    var colorTagRaw: String = GymColor.blue.rawValue  // NEW: Color storage
    var createdDate: Date = Date.now
    var lastUsedDate: Date?  // NEW: For ordering by most recently used

    @Relationship(deleteRule: .cascade, inverse: \Workout.gym)
    var workouts: [Workout] = []

    @Relationship(deleteRule: .cascade, inverse: \ExerciseWeightHistory.gym)
    var weightHistory: [ExerciseWeightHistory] = []

    /// Type-safe access to color tag
    var colorTag: GymColor {
        get { GymColor(rawValue: colorTagRaw) ?? .blue }
        set { colorTagRaw = newValue.rawValue }
    }

    init(name: String, colorTag: GymColor = .blue, isDefault: Bool = false) {
        self.name = name
        self.colorTagRaw = colorTag.rawValue
        self.isDefault = isDefault
    }
}
```

### Pattern 4: Default Gym Seeding
**What:** Create system "Default Gym" on first launch, never deletable
**When to use:** App initialization, similar to ExerciseSeedService
**Example:**
```swift
// Source: Existing ExerciseSeedService pattern

@MainActor
final class GymSeedService {
    static func seedIfNeeded(context: ModelContext) {
        // Check if any gyms exist
        let descriptor = FetchDescriptor<Gym>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        // Create default gym
        let defaultGym = Gym(
            name: AppConstants.defaultGymName,
            colorTag: .blue,
            isDefault: true
        )
        context.insert(defaultGym)

        do {
            try context.save()
            print("GymSeedService: Created default gym")
        } catch {
            print("GymSeedService: Failed to create default gym - \(error)")
        }
    }
}
```

### Pattern 5: Sheet with Presentation Detents
**What:** Medium-height sheet for gym selection, full height for management
**When to use:** Gym selector sheet (quick selection) vs gym management (full CRUD)
**Example:**
```swift
// Source: https://sarunw.com/posts/swiftui-bottom-sheet/

struct WorkoutTabView: View {
    @State private var showingGymSelector = false
    @State private var showingGymManagement = false

    var body: some View {
        NavigationStack {
            VStack {
                GymSelectorHeader(onTap: { showingGymSelector = true })
                // ... workout content
            }
        }
        .sheet(isPresented: $showingGymSelector) {
            GymSelectorSheet(
                onManageGyms: {
                    showingGymSelector = false
                    showingGymManagement = true
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingGymManagement) {
            NavigationStack {
                GymManagementView()
            }
            .presentationDetents([.large])
        }
    }
}
```

### Pattern 6: Confirmation Dialog for Deletion Options
**What:** Action sheet with multiple deletion options (delete, keep history, merge)
**When to use:** Deleting user-created gyms (not default gym)
**Example:**
```swift
// Source: https://useyourloaf.com/blog/swiftui-confirmation-dialogs/

struct GymManagementView: View {
    @State private var gymToDelete: Gym?
    @State private var showingDeleteOptions = false
    @State private var showingMergeSheet = false

    var body: some View {
        List {
            // ... gym list
        }
        .confirmationDialog(
            "Delete \(gymToDelete?.name ?? "Gym")?",
            isPresented: $showingDeleteOptions,
            titleVisibility: .visible
        ) {
            Button("Delete Gym and History", role: .destructive) {
                deleteGymWithHistory(gymToDelete)
            }
            Button("Delete Gym, Keep History") {
                deleteGymKeepHistory(gymToDelete)
            }
            Button("Merge into Another Gym...") {
                showingMergeSheet = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("What should happen to workouts recorded at this gym?")
        }
    }
}
```

### Pattern 7: Merging History to Another Gym (Manual Transfer)
**What:** Move ExerciseWeightHistory records to different gym before deletion
**When to use:** "Merge into another gym" deletion option
**Example:**
```swift
// Source: https://www.hackingwithswift.com/quick-start/swiftdata/working-with-relationships

func mergeGymHistory(from sourceGym: Gym, to targetGym: Gym, context: ModelContext) {
    // Transfer weight history
    for history in sourceGym.weightHistory {
        history.gym = targetGym
    }

    // Transfer workouts
    for workout in sourceGym.workouts {
        workout.gym = targetGym
    }

    // Update target gym's lastUsedDate if needed
    if let sourceLastUsed = sourceGym.lastUsedDate,
       let targetLastUsed = targetGym.lastUsedDate,
       sourceLastUsed > targetLastUsed {
        targetGym.lastUsedDate = sourceLastUsed
    }

    // Now safe to delete source (no cascade since children moved)
    context.delete(sourceGym)
    try? context.save()
}
```

### Pattern 8: Exercise Branches as Filtered History View
**What:** "Branches" are not separate Exercise objects, but filtered views of weight history
**When to use:** Showing gym-specific weight history in exercise detail
**Example:**
```swift
// Source: Conceptual pattern based on existing ExerciseWeightHistory model

struct ExerciseDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let exercise: Exercise

    var body: some View {
        List {
            // ... existing sections

            Section("Weight History by Gym") {
                ForEach(gymBranches, id: \.gym.id) { branch in
                    NavigationLink {
                        GymWeightHistoryView(exercise: exercise, gym: branch.gym)
                    } label: {
                        HStack {
                            Circle()
                                .fill(branch.gym.colorTag.color)
                                .frame(width: 12, height: 12)
                            Text(branch.gym.name)
                            Spacer()
                            Text("\(branch.entryCount) entries")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    /// Groups weight history by gym
    private var gymBranches: [(gym: Gym, entryCount: Int)] {
        let grouped = Dictionary(grouping: exercise.weightHistory) { $0.gym }
        return grouped.compactMap { gym, entries in
            guard let gym else { return nil }
            return (gym: gym, entryCount: entries.count)
        }
        .sorted { $0.gym.lastUsedDate ?? .distantPast > $1.gym.lastUsedDate ?? .distantPast }
    }
}
```

### Anti-Patterns to Avoid
- **Creating duplicate Exercise objects for each gym:** Use existing ExerciseWeightHistory.gym relationship instead
- **Using ColorPicker for gym colors:** Too many options, inconsistent app appearance - use predefined palette
- **Storing PersistentIdentifier directly in @AppStorage:** Not property-list compatible - store UUID.uuidString instead
- **Deleting default gym:** Always check `isDefault` before allowing deletion
- **Changing gym mid-workout:** Lock gym selection during active workout to maintain data integrity

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Persistent selection | Custom UserDefaults logic | @AppStorage with UUID string | SwiftUI-native, auto-refreshes views |
| Deletion confirmation | Custom alert | confirmationDialog | Standard iOS pattern, handles cancel automatically |
| Sheet heights | Custom modal | presentationDetents | Built-in, handles drag gestures properly |
| Color storage | Custom encoding | Enum with rawValue | Same pattern used throughout codebase |
| Gym ordering | Manual sorting | SortDescriptor with lastUsedDate | SwiftData optimized |

**Key insight:** Exercise "branches" are a UI concept, not a data model concept. The existing ExerciseWeightHistory model with its gym relationship already provides gym-specific tracking - no new models needed.

## Common Pitfalls

### Pitfall 1: Orphaned Weight History on Gym Deletion
**What goes wrong:** Weight history records become inaccessible after gym deletion
**Why it happens:** Cascade delete removes all related ExerciseWeightHistory
**How to avoid:** Offer "keep history" option that sets gym reference to nil or moves to default gym
**Warning signs:** Users complaining about lost workout data

### Pitfall 2: @AppStorage Not Updating SwiftUI Views
**What goes wrong:** Selected gym doesn't update in UI when changed
**Why it happens:** @AppStorage doesn't trigger @Observable's change detection
**How to avoid:** Use @ObservationIgnored on @AppStorage, expose selectedGym as computed property
**Warning signs:** Stale gym name displayed, works after app restart

### Pitfall 3: Multiple Default Gyms Created
**What goes wrong:** Multiple "Default Gym" records in database
**Why it happens:** Seed check only counts gyms, doesn't check for existing default
**How to avoid:** Check fetchCount == 0, or check for isDefault == true
**Warning signs:** Duplicate entries in gym list

### Pitfall 4: Gym Changed During Active Workout
**What goes wrong:** Workout data becomes inconsistent (some sets at old gym, some at new)
**Why it happens:** Allowing gym selection change while workout is active
**How to avoid:** Disable gym selector (or make view-only) during active workout
**Warning signs:** Weight history appears in wrong gym

### Pitfall 5: Color Not Persisting to SwiftData
**What goes wrong:** Gym color resets to default on app restart
**Why it happens:** Using Color directly instead of rawValue storage pattern
**How to avoid:** Store colorTagRaw (String), use computed colorTag for access
**Warning signs:** Colors reverting, SwiftData encoding errors

### Pitfall 6: Empty State Not Handled in Gym Selector
**What goes wrong:** Crash or blank sheet when no gyms exist
**Why it happens:** Not handling edge case where default gym creation failed
**How to avoid:** Always have fallback UI, ensure GymSeedService runs before first UI render
**Warning signs:** Blank sheets, nil crashes in gym selector

## Code Examples

Verified patterns from official sources and existing codebase:

### Gym Selector Header Component
```swift
// Source: Custom component following existing codebase patterns

struct GymSelectorHeader: View {
    let gym: Gym?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Circle()
                    .fill(gym?.colorTag.color ?? .gray)
                    .frame(width: 12, height: 12)
                Text(gym?.name ?? "Select Gym")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Image(systemName: "chevron.down")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.regularMaterial, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
```

### Gym Selection Sheet
```swift
// Source: Based on standard SwiftUI sheet patterns

struct GymSelectorSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Gym.lastUsedDate, order: .reverse) private var gyms: [Gym]

    @Binding var selectedGym: Gym?
    let onManageGyms: () -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(gyms) { gym in
                    Button {
                        selectedGym = gym
                        gym.lastUsedDate = .now
                        dismiss()
                    } label: {
                        HStack {
                            Circle()
                                .fill(gym.colorTag.color)
                                .frame(width: 16, height: 16)
                            Text(gym.name)
                            Spacer()
                            if gym.id == selectedGym?.id {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                    .tint(.primary)
                }

                Section {
                    Button("Manage Gyms") {
                        dismiss()
                        onManageGyms()
                    }
                }
            }
            .navigationTitle("Select Gym")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
```

### Filtering Exercises by Gym History
```swift
// Source: Based on existing ExerciseSearchResultsView pattern

struct ExercisesWithGymHistoryView: View {
    @Query private var exercises: [Exercise]
    let gym: Gym

    init(gym: Gym) {
        self.gym = gym
        // In-memory filter since to-many relationship predicates are complex
        _exercises = Query(sort: \Exercise.lastUsedDate, order: .reverse)
    }

    var exercisesWithHistory: [Exercise] {
        exercises.filter { exercise in
            exercise.weightHistory.contains { $0.gym?.id == gym.id }
        }
    }

    var body: some View {
        List(exercisesWithHistory) { exercise in
            ExerciseRow(exercise: exercise)
        }
    }
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| ActionSheet | confirmationDialog | iOS 15 (2021) | More options, better UX |
| Fixed sheet height | presentationDetents | iOS 16 (2022) | Flexible sheet sizing |
| UserDefaults wrapper | @AppStorage | iOS 14 (2020) | SwiftUI-native persistence |
| Enum in SwiftData | rawValue storage | iOS 17 (2023) | Required for predicate filtering |

**Deprecated/outdated:**
- **ActionSheet:** Use confirmationDialog (iOS 15+)
- **Storing PersistentIdentifier in UserDefaults:** Use custom UUID property with string storage

## Open Questions

Things that couldn't be fully resolved:

1. **Default Gym Selection on First Launch**
   - What we know: GymSeedService creates default gym, @AppStorage starts empty
   - What's unclear: Should app auto-select default gym, or leave selection empty until user chooses?
   - Recommendation: Auto-select default gym on first launch (set @AppStorage in GymSeedService)

2. **Cross-Gym Weight Hint Display**
   - What we know: CONTEXT.md says show "Last at [Other Gym]: [weight]" when logging at new gym
   - What's unclear: Where exactly this appears (workout logging is Phase 4)
   - Recommendation: Document pattern here, implement in Phase 4 workout logging

3. **Gym Branch Notes Storage**
   - What we know: CONTEXT.md mentions "branches can have optional, additional gym-specific notes"
   - What's unclear: Where to store this - ExerciseWeightHistory doesn't have notes field
   - Recommendation: Add optional `notes: String?` to ExerciseWeightHistory model

4. **Exercise Library Gym Filter Toggle**
   - What we know: CONTEXT.md suggests "optional toggle to filter by exercises with history at current gym"
   - What's unclear: Best UX for toggle placement in existing ExerciseLibraryView
   - Recommendation: Add filter toggle to toolbar, use in-memory filtering

## Sources

### Primary (HIGH confidence)
- [Hacking with Swift - @AppStorage](https://www.hackingwithswift.com/quick-start/swiftui/what-is-the-appstorage-property-wrapper) - Property wrapper usage
- [Sarunw - presentationDetents](https://sarunw.com/posts/swiftui-bottom-sheet/) - Sheet height customization
- [Use Your Loaf - confirmationDialog](https://useyourloaf.com/blog/swiftui-confirmation-dialogs/) - Deletion options pattern
- [Hacking with Swift - SwiftData Relationships](https://www.hackingwithswift.com/quick-start/swiftdata/working-with-relationships) - Moving children between parents
- [AppMakers - Palette Picker](https://appmakers.dev/picker-and-paletteselectioneffect-in-swiftui/) - Color palette selection

### Secondary (MEDIUM confidence)
- [Chris Wu - AppStorage with Picker](https://chriswu.com/posts/swiftui/appstoragepicker/) - UUID string storage pattern
- [Fatbobman - PersistentIdentifier](https://fatbobman.com/en/posts/nsmanagedobjectid-and-persistentidentifier/) - Why to use custom UUID instead
- [Hacking with Swift - SwiftData Delete](https://www.hackingwithswift.com/quick-start/swiftdata/how-to-delete-a-swiftdata-object) - Cascade delete behavior

### Tertiary (LOW confidence)
- Workout tracking database design articles - General patterns, not SwiftData-specific

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - All Apple frameworks, established patterns
- Gym model updates: HIGH - Follows existing rawValue pattern
- @AppStorage persistence: HIGH - Well-documented SwiftUI feature
- Exercise branching concept: HIGH - Realized via existing ExerciseWeightHistory model
- Deletion options UX: HIGH - Standard iOS confirmationDialog
- Merge history implementation: MEDIUM - Manual transfer, no SwiftData API

**Research date:** 2026-01-27
**Valid until:** 2026-02-27 (30 days - stable domain)

---

*Phase: 03-gyms*
*Research completed: 2026-01-27*
