# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-01-26)

**Core value:** Precise per-muscle volume tracking with user-defined muscles and weighted set contributions
**Current focus:** Phase 5 (Exercise Library Rework) - Plan 03 Complete

## Current Position

Phase: 5 of 6 (Exercise Library Rework)
Plan: 3 of 10 in current phase
Status: In progress
Last activity: 2026-01-28 - Completed 05-03-PLAN.md (Equipment Model Updates)

Progress: [███████████████████░] ~75% (21/~28 total plans estimate)

## Performance Metrics

**Velocity:**
- Total plans completed: 21
- Average duration: 7.7 min
- Total execution time: 170 min

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 01-foundation | 3 | 13 min | 4.3 min |
| 02-exercise-library | 5 | 61 min | 12.2 min |
| 03-gyms | 4 | 24 min | 6.0 min |
| 04-workout-logging | 6 | 55 min | 9.2 min |
| 05-exercise-library-rework | 3 | 17 min | 5.7 min |

**Recent Trend:**
- Last 5 plans: 04-06 (25 min), 05-01 (4 min), 05-02 (3 min), 05-03 (10 min)
- Trend: 05-03 included blocking fix for incomplete 05-04 commit

*Updated after each plan completion*

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- [Init]: SwiftData chosen over GRDB for Apple ecosystem alignment
- [Init]: User-defined muscles with weighted contributions (core differentiator)
- [Init]: Gym-specific exercise branches to solve multi-gym variance
- [01-01]: Fully qualified enum defaults for SwiftData macro compatibility
- [01-01]: 31-muscle taxonomy balanced for accuracy and usability
- [01-01]: Cascade delete on parent relationships only
- [01-02]: Feature-based folder structure for scalability
- [01-02]: Tab enum centralizes tab configuration (title, icon)
- [01-02]: NavigationStack per tab for independent navigation stacks
- [01-03]: Database in Application Support (not Documents) per Apple guidelines
- [01-03]: Singleton PersistenceController with @MainActor for thread safety
- [01-03]: In-memory preview container pattern for SwiftUI previews
- [02-01]: RawValue storage pattern for SwiftData enum predicate filtering
- [02-01]: Computed properties maintain type-safe enum API over rawValue storage
- [02-01]: Optional enum with fallback pattern (primaryMuscleGroup derives from muscle weights if nil)
- [02-02]: First-launch detection via Movement fetchCount == 0
- [02-02]: Primary muscle group derived from highest weighted muscle in variant
- [02-02]: Seed service pattern: static seedIfNeeded(context:) called from App init
- [02-03]: Task-based debounce pattern for @Observable (no Combine publishers)
- [02-03]: Subview @Query pattern for dynamic filtering
- [02-03]: In-memory search filter (SwiftData predicate expression limits)
- [02-04]: In-memory sorting for favorites (SortDescriptor<Bool> requires NSObject)
- [02-04]: @Observable ViewModel with change tracking for SwiftData edits
- [02-04]: sensoryFeedback(.impact) triggered by state change for slider haptics
- [02-05]: List/ForEach pattern for SwiftUI Binding initializer disambiguation
- [02-05]: Wizard ViewModel holds all step state, steps are pure views
- [02-05]: FlowLayout custom Layout for suggestion chips
- [03-01]: GymColor rawValue storage pattern for SwiftData predicate compatibility
- [03-01]: Default gym marked with isDefault=true to prevent deletion
- [03-01]: GymSeedService called before ExerciseSeedService in app init
- [03-03]: GymColorPicker uses .palette picker style for compact color display
- [03-03]: Deletion options via confirmationDialog with three choices
- [03-03]: Subview extraction pattern for ForEach SwiftData iteration
- [03-02]: @ObservationIgnored on @AppStorage prevents double-triggering in @Observable
- [03-02]: Subview pattern (GymSelectorRow) for ForEach closure isolation in Swift 6
- [03-02]: Computed selectedGym with fetch-on-access for consistency
- [03-04]: Delayed sheet transition (0.3s) via DispatchQueue.main.asyncAfter
- [03-04]: Dictionary grouping with compactMap for nil filtering in gymBranches
- [03-04]: Gym branches sorted by lastUsedDate for relevance ordering
- [04-01]: Date-based endTime for timer background persistence (iOS suspends countdown timers)
- [04-01]: Only header timer (most recent) triggers notifications to avoid spam
- [04-01]: 2.5 lbs weight increment matches standard plate availability
- [04-02]: Exercise order tracked as [UUID] array for display sequence
- [04-02]: Pre-fill new sets from previous workout values at same gym
- [04-02]: Crash recovery via isActive == true query on init
- [04-03]: @FocusState.Binding pattern for cross-view focus control
- [04-03]: Timer.publish(every: 1) for countdown UI updates
- [04-03]: Stepper input pattern: +/- buttons with keyboard fallback
- [04-04]: Closure-based binding pattern: (WorkoutSet) -> Binding<T> for ForEach scenarios
- [04-04]: Exercise picker limits to 50 recent when not searching (performance)
- [04-04]: FAB 56x56 size per Material Design guidelines
- [04-05]: LazyVStack with pinnedViews for sticky section headers
- [04-05]: ExerciseSectionForID helper view for SwiftData UUID fetching in ForEach
- [04-05]: Popover for timer controls (vs sheet) for inline editing
- [04-06]: StepperTextField for quick +/- adjustment with focus-aware button visibility
- [04-06]: Custom SwipeActionRow for swipe-to-delete outside List context
- [04-06]: highPriorityGesture for swipe to take precedence over scroll
- [04-06]: Checkmark toggle allows un-confirming sets and canceling timers
- [04-06]: Opaque background on swipe content to hide delete button at rest
- [05-01]: Empty string defaults in embedded Codable structs to avoid SwiftData optional decoding issues
- [05-01]: Popularity.sortOrder returns 1/2/3 (lower = more popular) for sorting
- [05-02]: serratusAnterior grouped under back (scapular movement assist)
- [05-02]: gluteusMinimus and adductors grouped under legs (hip stabilization/adduction)
- [05-03]: String id allows snake_case identifiers for built-in equipment, UUID strings for custom
- [05-03]: Convenience init preserves backward compatibility with existing seed service
- [05-03]: displayName replaces name for consistency with Movement model naming

### Pending Todos

None yet.

### Blockers/Concerns

None.

### Roadmap Evolution

- Phase 5: Exercise Library Rework (inserted before Analytics)
- Phase 6: Analytics (moved from Phase 5)

## Session Continuity

Last session: 2026-01-28
Stopped at: Completed 05-03-PLAN.md (Equipment Model Updates)
Resume file: None

## Phase 5 Progress

Phase 5 (Exercise Library Rework) in progress:
- 05-01: Supporting Types (COMPLETE)
- 05-02: Muscle Taxonomy Expansion (COMPLETE)
- 05-03: Equipment Model Updates (COMPLETE)
- 05-04: Movement Model Updates (COMPLETE - committed in 05-03 as blocking fix)
- 05-05: Exercise Model Refactor (pending)
- 05-06: Movement Seed Service (pending)
- 05-07: Equipment Seed Service (pending)
- 05-08: Exercise Preset Seeding (pending)
- 05-09: Exercise Browser Updates (pending)
- 05-10: Final Integration (pending)

**Completed in 05-01:**
- MovementCategory enum (7 cases)
- EquipmentCategory enum (6 cases)
- Popularity enum (3 cases with sortOrder)
- Dimensions embedded struct (5 properties)
- EquipmentProperties embedded struct (4 properties)

**Completed in 05-02:**
- Muscle enum expanded to 34 cases (verified, already done in 05-01)
- serratusAnterior, gluteusMinimus, adductors added
- MuscleGroup auto-includes via filter pattern

**Completed in 05-03:**
- Equipment model: String id, displayName, categoryRaw, properties, notes
- Convenience init for backward compatibility
- Updated views to use equipment.displayName
- Also fixed incomplete Movement model from 05-04 (String id, displayName, categoryRaw)
