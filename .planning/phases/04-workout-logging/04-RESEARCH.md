# Phase 4: Workout Logging - Research

**Researched:** 2026-01-28
**Domain:** Active workout session with fast set logging, rest timers, crash recovery, and background notifications
**Confidence:** HIGH

## Summary

This phase implements the core workout logging experience - starting a workout, adding exercises, logging sets quickly, viewing previous workout numbers, managing rest timers between sets, and crash recovery via auto-save. The data models (Workout, WorkoutSet, Exercise) already exist from Phase 1; this phase focuses on the UI/UX layer and the novel per-set independent timer system.

Key findings:
1. **Auto-save for crash recovery** is built into SwiftData via `autosaveEnabled` (true by default) - saves at end of each run loop cycle and on app background
2. **Timer persistence across background** requires storing timer end time (Date), not remaining seconds - recalculate on foreground return
3. **Local notifications** use UNUserNotificationCenter with time-interval trigger for rest timer alerts
4. **Sticky header** can be achieved with iOS 18's `onScrollGeometryChange` or `LazyVStack` with `pinnedViews: [.sectionHeaders]`
5. **Drag reordering** uses `onMove(perform:)` modifier on ForEach within List
6. **Swipe to delete** uses `onDelete(perform:)` for rows and `swipeActions` for custom destructive actions
7. **Set entry UX** should combine stepper buttons with tap-to-type TextField, using @FocusState for keyboard management

**Primary recommendation:** Use SwiftData's built-in auto-save for crash recovery (no explicit save calls needed), store timer end times as Date for background persistence, implement per-set timers as lightweight state objects that calculate remaining time from end date. Use @FocusState enum for rapid field navigation during set logging.

## Standard Stack

The established libraries/tools for this domain:

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| SwiftUI | iOS 17+ | UI framework | @FocusState, sensoryFeedback, DisclosureGroup, onMove, swipeActions |
| SwiftData | iOS 17+ | Persistence | Auto-save, existing Workout/WorkoutSet models |
| UserNotifications | iOS 10+ | Local notifications | UNUserNotificationCenter for rest timer alerts |
| Foundation | iOS 17+ | Timer, Date | Timer.publish for countdown, Date arithmetic for background persistence |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Combine | iOS 17+ | Timer.publish | Countdown timer UI updates (alternative to Task-based approach) |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Timer.publish (Combine) | Task + sleep | Timer.publish is more standard for UI countdowns; Task for debouncing |
| LazyVStack pinnedViews | onScrollGeometryChange | pinnedViews simpler; onScrollGeometryChange more flexible but iOS 18+ |
| DisclosureGroup | Custom expandable | DisclosureGroup native, handles animation; custom more control |
| @FocusState enum | Multiple booleans | Enum scales better, cleaner for multiple fields |

**Installation:**
No external dependencies required - all frameworks are Apple-native.

## Architecture Patterns

### Recommended Project Structure
```
GymAnals/
├── Features/
│   └── Workout/
│       ├── Views/
│       │   ├── WorkoutTabView.swift            # Update: add "Start Workout" action
│       │   ├── ActiveWorkoutView.swift         # NEW: Main workout session view
│       │   ├── ExerciseSectionView.swift       # NEW: Collapsible exercise container
│       │   ├── SetRowView.swift                # NEW: Individual set input row
│       │   ├── ExercisePickerSheet.swift       # NEW: Add exercise from library
│       │   └── TimerControlsPopover.swift      # NEW: Timer adjustment controls
│       ├── ViewModels/
│       │   ├── ActiveWorkoutViewModel.swift    # NEW: Workout session state manager
│       │   └── SetTimerManager.swift           # NEW: Per-set timer state manager
│       └── Components/
│           ├── WorkoutHeader.swift             # NEW: Sticky header (duration, sets, timer)
│           ├── StepperTextField.swift          # NEW: +/- buttons with tap-to-type
│           ├── SetTimerBadge.swift             # NEW: Countdown badge per set
│           └── AddExerciseFAB.swift            # NEW: Floating action button
├── Models/
│   └── Core/
│       ├── Workout.swift                       # Update: ensure isActive flag usage
│       └── WorkoutSet.swift                    # Update: add restDuration property
├── Services/
│   └── Notifications/
│       └── RestTimerNotificationService.swift  # NEW: Local notification scheduling
└── App/
    └── AppConstants.swift                      # Add defaultRestDuration constant
```

### Pattern 1: Active Workout ViewModel with ModelContext
**What:** @Observable ViewModel managing active workout state, bridging UI and SwiftData
**When to use:** Main workout session state management
**Example:**
```swift
// Source: Existing codebase pattern (GymSelectionViewModel)

@Observable
@MainActor
final class ActiveWorkoutViewModel {
    private let modelContext: ModelContext

    var activeWorkout: Workout?
    var exerciseOrder: [UUID] = []  // Track exercise display order
    var expandedExercises: Set<UUID> = []  // Track collapsed/expanded state

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadActiveWorkout()
    }

    /// Load any existing active workout (crash recovery)
    private func loadActiveWorkout() {
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.isActive == true }
        )
        activeWorkout = try? modelContext.fetch(descriptor).first
        if let workout = activeWorkout {
            exerciseOrder = uniqueExerciseIDs(from: workout.sets)
            expandedExercises = Set(exerciseOrder)  // All expanded by default
        }
    }

    func startWorkout(at gym: Gym?) {
        let workout = Workout(startDate: .now, gym: gym)
        modelContext.insert(workout)
        activeWorkout = workout
        // Auto-save handles persistence
    }

    func finishWorkout() {
        guard let workout = activeWorkout else { return }
        workout.isActive = false
        workout.endDate = .now
        activeWorkout = nil
        exerciseOrder = []
        expandedExercises = []
    }

    func discardWorkout() {
        guard let workout = activeWorkout else { return }
        modelContext.delete(workout)  // Cascade deletes sets
        activeWorkout = nil
        exerciseOrder = []
        expandedExercises = []
    }

    private func uniqueExerciseIDs(from sets: [WorkoutSet]) -> [UUID] {
        var seen = Set<UUID>()
        var result: [UUID] = []
        for set in sets.sorted(by: { $0.completedDate < $1.completedDate }) {
            if let exerciseID = set.exercise?.id, !seen.contains(exerciseID) {
                seen.insert(exerciseID)
                result.append(exerciseID)
            }
        }
        return result
    }
}
```

### Pattern 2: Timer Persistence Across Background
**What:** Store timer end time as Date, recalculate remaining time on foreground return
**When to use:** Rest timers that must survive app backgrounding
**Example:**
```swift
// Source: https://medium.com/deuk/overcoming-ios-background-limits-a-time-tracker-app-in-swift-ui-5d157a58df68

struct SetTimer: Identifiable {
    let id: UUID
    let setID: UUID
    let endTime: Date  // Persisted as Date, not countdown seconds

    var remainingSeconds: Int {
        max(0, Int(endTime.timeIntervalSinceNow))
    }

    var isExpired: Bool {
        remainingSeconds == 0
    }
}

@Observable
@MainActor
final class SetTimerManager {
    var activeTimers: [SetTimer] = []

    /// Most recent timer (shown in header, triggers notification)
    var headerTimer: SetTimer? {
        activeTimers.max(by: { $0.endTime < $1.endTime })
    }

    func startTimer(for setID: UUID, duration: TimeInterval) {
        let timer = SetTimer(
            id: UUID(),
            setID: setID,
            endTime: Date.now.addingTimeInterval(duration)
        )
        activeTimers.append(timer)
    }

    func removeExpiredTimers() {
        activeTimers.removeAll { $0.isExpired }
    }

    func skipTimer(_ timer: SetTimer) {
        activeTimers.removeAll { $0.id == timer.id }
    }

    func extendTimer(_ timer: SetTimer, by seconds: TimeInterval) {
        if let index = activeTimers.firstIndex(where: { $0.id == timer.id }) {
            let newEndTime = activeTimers[index].endTime.addingTimeInterval(seconds)
            activeTimers[index] = SetTimer(
                id: timer.id,
                setID: timer.setID,
                endTime: newEndTime
            )
        }
    }
}
```

### Pattern 3: Timer UI with Timer.publish
**What:** Use Combine's Timer.publish for countdown display updates
**When to use:** Animating countdown in UI while timers run
**Example:**
```swift
// Source: https://www.hackingwithswift.com/quick-start/swiftui/how-to-use-a-timer-with-swiftui

struct SetTimerBadge: View {
    let timer: SetTimer
    let onTap: () -> Void

    @State private var remainingSeconds: Int = 0

    // Timer fires every second to update display
    private let updateTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Button(action: onTap) {
            Text(formatTime(remainingSeconds))
                .font(.caption.monospacedDigit())
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.orange.opacity(0.2), in: Capsule())
        }
        .buttonStyle(.plain)
        .onReceive(updateTimer) { _ in
            remainingSeconds = timer.remainingSeconds
        }
        .onAppear {
            remainingSeconds = timer.remainingSeconds
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
```

### Pattern 4: Local Notification for Rest Timer
**What:** Schedule UNNotification when rest timer starts, cancel on skip/early finish
**When to use:** Alerting user when rest timer completes (app may be backgrounded)
**Example:**
```swift
// Source: https://www.hackingwithswift.com/books/ios-swiftui/scheduling-local-notifications

@MainActor
final class RestTimerNotificationService {
    static let shared = RestTimerNotificationService()

    private init() {}

    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound])
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }

    func scheduleRestTimerNotification(id: String, after seconds: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Rest Complete"
        content.body = "Time to start your next set!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: seconds,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func cancelNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [id]
        )
    }

    func cancelAllRestTimerNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
```

### Pattern 5: Stepper + TextField Combo for Set Entry
**What:** +/- buttons flanking a tappable TextField for weight/reps entry
**When to use:** Fast set logging with both tap-to-adjust and keyboard input
**Example:**
```swift
// Source: https://gist.github.com/theoknock/2a1ada98635dadb2bb2d8f6cde3b3152

struct StepperTextField: View {
    @Binding var value: Double
    let step: Double
    let range: ClosedRange<Double>
    let unit: String
    var onFocus: () -> Void = {}

    @FocusState private var isFocused: Bool
    @State private var textValue: String = ""

    var body: some View {
        HStack(spacing: 8) {
            Button {
                value = max(range.lowerBound, value - step)
            } label: {
                Image(systemName: "minus")
                    .frame(width: 32, height: 32)
                    .background(.regularMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.decrease, trigger: value)

            TextField("", text: $textValue)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .frame(width: 60)
                .focused($isFocused)
                .onChange(of: isFocused) { _, focused in
                    if focused {
                        textValue = formatValue(value)
                        onFocus()
                    } else {
                        // Parse and validate on blur
                        if let parsed = Double(textValue) {
                            value = min(range.upperBound, max(range.lowerBound, parsed))
                        }
                        textValue = formatValue(value)
                    }
                }
                .onAppear {
                    textValue = formatValue(value)
                }

            Text(unit)
                .foregroundStyle(.secondary)
                .frame(width: 30, alignment: .leading)

            Button {
                value = min(range.upperBound, value + step)
            } label: {
                Image(systemName: "plus")
                    .frame(width: 32, height: 32)
                    .background(.regularMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.increase, trigger: value)
        }
    }

    private func formatValue(_ val: Double) -> String {
        val.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", val)
            : String(format: "%.1f", val)
    }
}
```

### Pattern 6: @FocusState Enum for Multiple Fields
**What:** Single enum tracking which field is focused across multiple inputs
**When to use:** Rapid field navigation during set logging
**Example:**
```swift
// Source: https://serialcoder.dev/text-tutorials/swiftui/programmatically-setting-focus-on-swiftui-text-fields-with-focusstate/

enum SetEntryField: Hashable {
    case reps(setID: UUID)
    case weight(setID: UUID)
}

struct SetRowView: View {
    let set: WorkoutSet
    @Binding var reps: Int
    @Binding var weight: Double
    @FocusState.Binding var focusedField: SetEntryField?

    var body: some View {
        HStack {
            // Reps field
            TextField("0", value: $reps, format: .number)
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .reps(setID: set.id))
                .frame(width: 50)

            Text("x")

            // Weight field
            TextField("0", value: $weight, format: .number)
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: .weight(setID: set.id))
                .frame(width: 60)

            Text("kg")

            // Confirm button - moves focus to next set's reps
            Button {
                logSet()
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
    }

    private func logSet() {
        // Save set, start timer, move focus to next set...
    }
}
```

### Pattern 7: Collapsible Exercise Section with DisclosureGroup
**What:** Expandable section per exercise containing its sets
**When to use:** Exercise sections in active workout view
**Example:**
```swift
// Source: https://developer.apple.com/documentation/swiftui/disclosuregroup

struct ExerciseSectionView: View {
    let exercise: Exercise
    let sets: [WorkoutSet]
    @Binding var isExpanded: Bool
    let onDeleteExercise: () -> Void
    let onDeleteSet: (WorkoutSet) -> Void
    let onAddSet: () -> Void
    let onMoveExercise: (IndexSet, Int) -> Void

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ForEach(sets) { set in
                SetRowView(set: set, ...)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            onDeleteSet(set)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }

            Button {
                onAddSet()
            } label: {
                Label("Add Set", systemImage: "plus")
            }
            .padding(.vertical, 4)
        } label: {
            ExerciseHeaderView(exercise: exercise)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDeleteExercise()
            } label: {
                Label("Remove", systemImage: "trash")
            }
        }
    }
}
```

### Pattern 8: Floating Action Button for Adding Exercises
**What:** Persistent FAB at bottom-right to add exercises
**When to use:** Quick access to exercise picker during workout
**Example:**
```swift
// Source: https://sarunw.com/posts/floating-action-button-in-swiftui/

struct ActiveWorkoutView: View {
    @State private var showingExercisePicker = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Main content
            ScrollView {
                LazyVStack(spacing: 12, pinnedViews: [.sectionHeaders]) {
                    // Sticky header
                    Section {
                        // Exercise sections...
                    } header: {
                        WorkoutHeader(...)
                    }
                }
            }

            // Floating action button
            Button {
                showingExercisePicker = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(.accent, in: Circle())
                    .shadow(radius: 4, y: 2)
            }
            .padding()
        }
        .sheet(isPresented: $showingExercisePicker) {
            ExercisePickerSheet(...)
        }
    }
}
```

### Pattern 9: Sticky Header with LazyVStack
**What:** Header that sticks to top while scrolling workout content
**When to use:** Showing elapsed time, total sets, rest timer at top
**Example:**
```swift
// Source: https://yoswift.dev/swiftui/pinnedScrollableViews/

struct ActiveWorkoutView: View {
    @State var viewModel: ActiveWorkoutViewModel
    @State var timerManager: SetTimerManager

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                Section {
                    ForEach(viewModel.exerciseOrder, id: \.self) { exerciseID in
                        // Exercise sections
                    }
                } header: {
                    WorkoutHeader(
                        startDate: viewModel.activeWorkout?.startDate ?? .now,
                        totalSets: viewModel.activeWorkout?.sets.count ?? 0,
                        headerTimer: timerManager.headerTimer
                    )
                    .background(.regularMaterial)
                }
            }
        }
    }
}
```

### Pattern 10: Previous Workout Data Lookup
**What:** Query for last workout's sets for same exercise at same gym
**When to use:** Pre-filling set values and showing "last: 8x100" hints
**Example:**
```swift
// Source: Based on existing codebase patterns

extension ActiveWorkoutViewModel {
    /// Find previous workout's sets for an exercise at current gym
    func previousSets(for exercise: Exercise) -> [WorkoutSet] {
        guard let currentGym = activeWorkout?.gym else { return [] }

        // Find the most recent completed workout at this gym that included this exercise
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate<Workout> { workout in
                workout.isActive == false &&
                workout.gym?.id == currentGym.id
            },
            sortBy: [SortDescriptor(\Workout.endDate, order: .reverse)]
        )

        guard let workouts = try? modelContext.fetch(descriptor) else { return [] }

        // Find first workout containing this exercise
        for workout in workouts {
            let exerciseSets = workout.sets.filter { $0.exercise?.id == exercise.id }
            if !exerciseSets.isEmpty {
                return exerciseSets.sorted { $0.setNumber < $1.setNumber }
            }
        }

        return []
    }

    /// Pre-fill values for a new set based on previous workout
    func suggestedValues(for exercise: Exercise, setNumber: Int) -> (reps: Int, weight: Double)? {
        let previous = previousSets(for: exercise)
        guard setNumber <= previous.count else { return nil }
        let previousSet = previous[setNumber - 1]
        return (reps: previousSet.reps, weight: previousSet.weight)
    }
}
```

### Pattern 11: Outlier Detection for Weight Entry
**What:** Warn user if entered weight is drastically higher than previous
**When to use:** Preventing typos like 533kg instead of 53kg
**Example:**
```swift
// Source: Custom pattern based on CONTEXT.md requirements

struct SetRowView: View {
    @Binding var weight: Double
    let previousWeight: Double?
    @State private var showingOutlierWarning = false

    var body: some View {
        HStack {
            // ... weight input
        }
        .onChange(of: weight) { oldValue, newValue in
            if let prev = previousWeight, newValue > prev * 5 {
                showingOutlierWarning = true
            }
        }
        .alert("Unusual Weight", isPresented: $showingOutlierWarning) {
            Button("Keep \(formatWeight(weight))") { }
            Button("Change") { weight = previousWeight ?? 0 }
        } message: {
            if let prev = previousWeight {
                Text("Previous was \(formatWeight(prev)). You entered \(formatWeight(weight)). Is this correct?")
            }
        }
    }
}
```

### Pattern 12: ScenePhase for Background Detection
**What:** Detect when app moves to background to persist timer state
**When to use:** Ensuring timer state survives backgrounding
**Example:**
```swift
// Source: https://www.hackingwithswift.com/quick-start/swiftui/how-to-detect-when-your-app-moves-to-the-background-or-foreground-with-scenephase

struct ActiveWorkoutView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State var timerManager: SetTimerManager

    var body: some View {
        // ... content
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                // App returned to foreground - timers auto-recalculate from endTime
                timerManager.removeExpiredTimers()
            case .background:
                // Nothing needed - endTime is Date-based, survives background
                break
            case .inactive:
                break
            @unknown default:
                break
            }
        }
    }
}
```

### Anti-Patterns to Avoid
- **Storing remaining seconds instead of end time:** Doesn't survive app background - always store endTime as Date
- **Explicit save() calls after every change:** SwiftData auto-saves; explicit saves are redundant
- **Multiple @FocusState booleans:** Use single enum for cleaner state management
- **Timer.scheduledTimer in SwiftUI:** Use Timer.publish with Combine or Task-based approach
- **Blocking UI during set logging:** Keep all operations fast, use Task for async work
- **Deleting exercise from workout vs removing from current workout:** Understand the difference
- **ForEach without id parameter for WorkoutSet:** Always use `id: \.id` for SwiftData models

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Crash recovery | Custom save logic | SwiftData autosaveEnabled | Built-in, runs at end of each run loop |
| Background timer | Timer that survives background | Date-based endTime calculation | iOS suspends timers in background |
| Local notifications | Custom alert system | UNUserNotificationCenter | System-level, works when app inactive |
| Swipe delete | Custom gesture | onDelete/swipeActions | Standard iOS pattern, handles animation |
| Collapsible sections | Custom show/hide | DisclosureGroup | Native, accessible, handles animation |
| Focus navigation | Custom first responder | @FocusState | SwiftUI-native, declarative |
| Floating button | Complex overlay | ZStack alignment | Simple SwiftUI layout |
| Countdown display | Manual timer | Timer.publish | Combine handles lifecycle automatically |

**Key insight:** SwiftData's auto-save means crash recovery is essentially free. The key is structuring timer state as Date-based end times rather than countdown seconds, so timers naturally "continue" across backgrounding without explicit persistence.

## Common Pitfalls

### Pitfall 1: Timer Stops in Background
**What goes wrong:** Rest timer stops counting when app is backgrounded
**Why it happens:** iOS suspends timers when app is not active
**How to avoid:** Store timer endTime as Date, calculate remaining on display; schedule local notification for completion
**Warning signs:** Timer shows wrong value after returning from background

### Pitfall 2: Lost Workout Data on Crash
**What goes wrong:** Active workout lost if app crashes
**Why it happens:** Not using SwiftData's auto-save, or creating objects without inserting into context
**How to avoid:** Insert Workout immediately on start, insert WorkoutSet immediately on creation - auto-save handles the rest
**Warning signs:** Users losing workouts, data not appearing after restart

### Pitfall 3: Keyboard Covering Input Fields
**What goes wrong:** Set entry fields hidden behind keyboard
**Why it happens:** Not using ScrollView or not scrolling to focused field
**How to avoid:** Use ScrollViewReader with scrollTo on focus change, or rely on SwiftUI's automatic keyboard avoidance
**Warning signs:** Users can't see what they're typing

### Pitfall 4: Multiple Active Workouts
**What goes wrong:** Starting new workout while previous is still active
**Why it happens:** Not checking for existing active workout before creating new one
**How to avoid:** Query for `isActive == true` workout on app launch; prevent Start if one exists
**Warning signs:** Orphaned workout records, confusing state

### Pitfall 5: Timer Notification Fires After Timer Skipped
**What goes wrong:** User skips timer but notification still fires
**Why it happens:** Not canceling scheduled notification when timer is manually dismissed
**How to avoid:** Call `cancelNotification(id:)` in skipTimer() function
**Warning signs:** Spurious notifications, user confusion

### Pitfall 6: @FocusState Not Working Immediately
**What goes wrong:** Focus doesn't move to field on view appear
**Why it happens:** View not yet laid out when focus change requested
**How to avoid:** Use Task { } or DispatchQueue.main.async to delay focus change slightly
**Warning signs:** First field not focused automatically

### Pitfall 7: Weight Unit Mismatch
**What goes wrong:** User enters pounds but app saves as kilograms (or vice versa)
**Why it happens:** Not respecting user's weight unit preference when saving
**How to avoid:** Store weight with unit, convert on display; or store in canonical unit (kg) and convert on I/O
**Warning signs:** Wrong weights appearing, confusion after unit change

### Pitfall 8: Exercise Order Lost on Crash
**What goes wrong:** Exercises appear in different order after crash recovery
**Why it happens:** Only relying on in-memory exerciseOrder array
**How to avoid:** Store exercise order in Workout model, or derive from set completedDate
**Warning signs:** Exercises jumping around, inconsistent order

## Code Examples

Verified patterns from official sources and existing codebase:

### Workout Header Component
```swift
// Source: Custom component following existing codebase patterns

struct WorkoutHeader: View {
    let startDate: Date
    let totalSets: Int
    let headerTimer: SetTimer?
    let onTimerTap: () -> Void

    @State private var elapsedSeconds: Int = 0
    private let updateTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack {
            // Elapsed duration
            VStack(alignment: .leading) {
                Text("Duration")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(formatDuration(elapsedSeconds))
                    .font(.title3.monospacedDigit())
            }

            Spacer()

            // Total sets
            VStack {
                Text("Sets")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(totalSets)")
                    .font(.title3)
            }

            Spacer()

            // Rest timer (if active)
            if let timer = headerTimer {
                Button(action: onTimerTap) {
                    VStack {
                        Text("Rest")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatTime(timer.remainingSeconds))
                            .font(.title3.monospacedDigit())
                            .foregroundStyle(.orange)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .onReceive(updateTimer) { _ in
            elapsedSeconds = Int(Date.now.timeIntervalSince(startDate))
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        let hrs = seconds / 3600
        let mins = (seconds % 3600) / 60
        let secs = seconds % 60
        if hrs > 0 {
            return String(format: "%d:%02d:%02d", hrs, mins, secs)
        }
        return String(format: "%d:%02d", mins, secs)
    }

    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
```

### Exercise Picker Sheet
```swift
// Source: Based on existing ExerciseLibraryView patterns

struct ExercisePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Exercise.lastUsedDate, order: .reverse) private var exercises: [Exercise]
    @State private var searchText = ""

    let onSelectExercise: (Exercise) -> Void

    var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return Array(exercises.prefix(50))  // Show recent by default
        }
        return exercises.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredExercises) { exercise in
                Button {
                    onSelectExercise(exercise)
                    dismiss()
                } label: {
                    ExerciseRow(exercise: exercise)
                }
                .tint(.primary)
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search exercises")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
```

### Set Logging with Previous Value Hint
```swift
// Source: Custom implementation based on CONTEXT.md requirements

struct SetRowView: View {
    let setNumber: Int
    @Binding var reps: Int
    @Binding var weight: Double
    let previousReps: Int?
    let previousWeight: Double?
    let weightUnit: WeightUnit
    let onConfirm: () -> Void

    @FocusState.Binding var focusedField: SetEntryField?
    let setID: UUID

    var body: some View {
        HStack(spacing: 12) {
            // Set number
            Text("\(setNumber)")
                .font(.headline)
                .frame(width: 24)
                .foregroundStyle(.secondary)

            // Reps input
            VStack(alignment: .leading, spacing: 2) {
                TextField("0", value: $reps, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 50)
                    .focused($focusedField, equals: .reps(setID: setID))

                if let prev = previousReps {
                    Text("last: \(prev)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Text("x")
                .foregroundStyle(.secondary)

            // Weight input
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    TextField("0", value: $weight, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                        .focused($focusedField, equals: .weight(setID: setID))

                    Text(weightUnit.abbreviation)
                        .foregroundStyle(.secondary)
                }

                if let prev = previousWeight {
                    Text("last: \(formatWeight(prev))")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            // Confirm button
            Button(action: onConfirm) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }

    private func formatWeight(_ w: Double) -> String {
        w.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", w)
            : String(format: "%.1f", w)
    }
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Explicit save() calls | SwiftData autosaveEnabled | iOS 17 (2023) | Automatic persistence |
| UIKit first responder | @FocusState | iOS 15 (2021) | Declarative focus management |
| ActionSheet | confirmationDialog | iOS 15 (2021) | More options, better UX |
| Manual timer management | Timer.publish | iOS 13+ | Combine-based, lifecycle-aware |
| UILocalNotification | UNUserNotificationCenter | iOS 10 (2016) | Modern notification API |
| Custom collapsible | DisclosureGroup | iOS 14 (2020) | Native, accessible |

**Deprecated/outdated:**
- **UILocalNotification:** Use UNUserNotificationCenter (iOS 10+)
- **UITextField.becomeFirstResponder:** Use @FocusState in SwiftUI
- **Manual NSTimer:** Use Timer.publish with Combine or Task-based sleep

## Open Questions

Things that couldn't be fully resolved:

1. **Per-Set Timer Persistence Across App Restart**
   - What we know: Storing endTime as Date survives backgrounding
   - What's unclear: Should timers persist across full app termination?
   - Recommendation: Store active timers in UserDefaults or as WorkoutSet property; most users expect timers to reset on app restart, so this may be acceptable to skip

2. **Rest Timer Sound vs Haptic Preference Storage**
   - What we know: CONTEXT.md says notification style is user-configurable
   - What's unclear: Where to store this preference (Settings view doesn't exist yet)
   - Recommendation: Use @AppStorage with sensible defaults; add settings UI in future phase

3. **Exercise Order Persistence**
   - What we know: Users can reorder exercises via drag handles
   - What's unclear: Should order persist in Workout model or be derived from set timestamps?
   - Recommendation: Add `displayOrder: Int` to a join concept, or use WorkoutSet completion order as source of truth

4. **Weight Increment by Unit**
   - What we know: CONTEXT.md specifies 1kg for metric, 1.25lbs for imperial
   - What's unclear: How common is 1.25lbs? Standard plates are 2.5lbs minimum
   - Recommendation: Use 2.5lbs to match real plate availability; can adjust based on user feedback

## Sources

### Primary (HIGH confidence)
- [Hacking with Swift - Timer in SwiftUI](https://www.hackingwithswift.com/quick-start/swiftui/how-to-use-a-timer-with-swiftui) - Timer.publish pattern
- [Hacking with Swift - Local Notifications](https://www.hackingwithswift.com/books/ios-swiftui/scheduling-local-notifications) - UNUserNotificationCenter
- [Hacking with Swift - SwiftData Autosave](https://www.hackingwithswift.com/quick-start/swiftdata/when-does-swiftdata-autosave-data) - Autosave behavior
- [Apple Documentation - FocusState](https://developer.apple.com/documentation/swiftui/focusstate) - Focus management
- [Apple Documentation - DisclosureGroup](https://developer.apple.com/documentation/swiftui/disclosuregroup) - Collapsible sections
- [Hacking with Swift - onMove](https://www.hackingwithswift.com/quick-start/swiftui/how-to-let-users-move-rows-in-a-list) - Drag reordering
- [Hacking with Swift - onDelete](https://www.hackingwithswift.com/quick-start/swiftui/how-to-let-users-delete-rows-from-a-list) - Swipe to delete
- [Hacking with Swift - ScenePhase](https://www.hackingwithswift.com/quick-start/swiftui/how-to-detect-when-your-app-moves-to-the-background-or-foreground-with-scenephase) - Background detection

### Secondary (MEDIUM confidence)
- [Sarunw - Floating Action Button](https://sarunw.com/posts/floating-action-button-in-swiftui/) - FAB implementation
- [Sarunw - List onMove](https://sarunw.com/posts/swiftui-list-onmove/) - Reorder implementation
- [YoSwift - PinnedScrollableViews](https://yoswift.dev/swiftui/pinnedScrollableViews/) - Sticky headers
- [SerialCoder - FocusState](https://serialcoder.dev/text-tutorials/swiftui/programmatically-setting-focus-on-swiftui-text-fields-with-focusstate/) - Focus patterns
- [Use Your Loaf - SwiftData Autosave](https://useyourloaf.com/blog/swiftdata-saving-changes/) - Save behavior details

### Tertiary (LOW confidence)
- [Medium - Background Timer](https://medium.com/deuk/overcoming-ios-background-limits-a-time-tracker-app-in-swift-ui-5d157a58df68) - Background patterns
- [GitHub - TextFieldStepper](https://github.com/joe-scotto/TextFieldStepper) - Combined stepper concept

## Metadata

**Confidence breakdown:**
- Timer patterns: HIGH - Well-documented SwiftUI/Combine features
- Auto-save crash recovery: HIGH - SwiftData default behavior
- Local notifications: HIGH - Established UNUserNotificationCenter API
- Focus management: HIGH - Apple documentation
- UI patterns (FAB, sticky header): MEDIUM - Community patterns, not official
- Per-set timer concept: MEDIUM - Novel feature, custom implementation

**Research date:** 2026-01-28
**Valid until:** 2026-02-28 (30 days - stable domain)

---

*Phase: 04-workout-logging*
*Research completed: 2026-01-28*
