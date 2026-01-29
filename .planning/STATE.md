# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-01-26)

**Core value:** Precise per-muscle volume tracking with user-defined muscles and weighted set contributions
**Current focus:** Quick Tasks - Exercise Context Menu

## Current Position

Phase: 6 of 7 (Bug Fixes)
Plan: 04 of 04 in current phase (Phase COMPLETE)
Status: Phase complete
Last activity: 2026-01-28 - Completed 06-04-PLAN.md (Multi-Select Picker, Timer, Gym Indicator)

Progress: [██████████████████████████████] 100% (32/32 total plans)

## Performance Metrics

**Velocity:**
- Total plans completed: 32
- Average duration: 8.2 min
- Total execution time: 264 min

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 01-foundation | 3 | 13 min | 4.3 min |
| 02-exercise-library | 5 | 61 min | 12.2 min |
| 03-gyms | 4 | 24 min | 6.0 min |
| 04-workout-logging | 6 | 55 min | 9.2 min |
| 05-exercise-library-rework | 10 | 81 min | 8.1 min |
| 06-bug-fixes | 4 | 30 min | 7.5 min |

**Recent Trend:**
- Last 5 plans: 05-10 (8 min), 06-01 (5 min), 06-02 (6 min), 06-03 (5 min), 06-04 (9 min)
- Trend: Bug fix plans completing quickly (focused scope, existing code modifications)

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
- [05-04]: String id allows snake_case identifiers for built-in movements
- [05-04]: exercises relationship temporarily commented until Exercise.movement exists
- [05-05]: Exercise.id changed from UUID to String for snake_case preset identifiers
- [05-05]: displayName changed from computed to stored property (presets have curated names)
- [05-05]: muscleWeights stored as [String: Double] dictionary (replaces VariantMuscle relationship)
- [05-05]: isUnilateral computed from dimensions.laterality (single source of truth)
- [05-05]: exerciseOrder/expandedExercises changed from UUID to String types
- [05-07]: Seed order: GymSeedService -> EquipmentSeedService -> MovementSeedService -> PresetSeedService
- [05-07]: Entity-specific seed services (one per model type) replace monolithic ExerciseSeedService
- [05-07]: PresetSeedService builds lookup maps from fetched entities for O(1) relationship linking
- [05-07]: Muscle key validation with warning (not failure) for graceful degradation
- [05-08]: JSON resources in app bundle (movements.json, equipment.json, presets_all.json)
- [05-08]: GymAnalsApp calls 4 seed services in dependency order on first launch
- [05-09]: ExerciseNameStepView pre-fills name from equipment + movement display names
- [05-09]: resetToDefault restores movement.defaultMuscleWeights (not just clearing)
- [05-10]: searchTerms matched in-memory (SwiftData can't query array contents)
- [05-10]: ExerciseRow shows equipment + category badge for richer context
- [05-10]: ExerciseDetailView shows dimensions, notes, sources, popularity, timer settings
- [05-10]: Built-in exercises read-only; custom exercises get muscle weight editor
- [06-01]: Lock icon (lock.fill) replaces chevron when gym selector disabled during active workout
- [06-01]: New Gym button in GymSelectorSheet with auto-select via createdDate max
- [06-01]: gymCountBeforeCreate snapshot pattern for new-entity detection across sheet presentation
- [06-03]: Column layout: SET(32pt) | PREVIOUS(80pt) | WEIGHT(flex) | REPS(flex) | CHECKMARK(36pt)
- [06-03]: Timer badge removed from SetRowView (moves to always-visible header in Plan 04)
- [06-02]: startInEditMode parameter defaults false for backward compatibility; callers opt-in
- [06-02]: Equipment/Movement pickers as private inline subviews for encapsulation
- [06-02]: Dimensions editing excluded from CustomExerciseEditView (set at creation only)
- [06-03]: Weight unit abbreviation moved from row to column header
- [06-04]: Multi-select with Set<String> for selectedExerciseIDs in exercise picker
- [06-04]: Always-visible timer with "--:--" placeholder and manual 120s start on tap
- [06-04]: Gym indicator as color dot + name row above stats in workout header

### Pending Todos

None yet.

### Blockers/Concerns

None - Phase 6 complete. All 4 plans executed successfully.

### Quick Tasks Completed

| # | Description | Date | Commit | Directory |
|---|-------------|------|--------|-----------|
| 001 | Exercise context menu (Edit, Delete, Duplicate) | 2026-01-29 | fda2845 | [001-exercise-context-menu](./quick/001-exercise-context-menu/) |

### Roadmap Evolution

- Phase 5: Exercise Library Rework (inserted before Analytics) - COMPLETE
- Phase 6: Bug Fixes (inserted 2026-01-28 to address 20 production-critical bugs before analytics) - COMPLETE
- Phase 7: Analytics (moved from Phase 6) - FUTURE

## Session Continuity

Last session: 2026-01-29
Stopped at: Completed quick-001 (Exercise context menu) - Ready for next task
Resume file: None

## Phase 5 Progress

Phase 5 (Exercise Library Rework) COMPLETE:
- 05-01: Supporting Types (COMPLETE)
- 05-02: Muscle Taxonomy Expansion (COMPLETE)
- 05-03: Equipment Model Updates (COMPLETE)
- 05-04: Movement Model Updates (COMPLETE)
- 05-05: Exercise Model Refactor (COMPLETE)
- 05-06: Remove Variant/VariantMuscle Models (COMPLETE)
- 05-07: Seed Services (COMPLETE)
- 05-08: JSON Resources and App Seeding (COMPLETE)
- 05-09: Exercise Creation Wizard Updates (COMPLETE)
- 05-10: Exercise Library View Updates (COMPLETE)

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

**Completed in 05-04:**
- Movement model: String id, displayName, categoryRaw, subcategory
- applicableDimensions and applicableEquipment constraint arrays
- defaultMuscleWeights dictionary for inherited targeting
- Removed variants relationship (Variant being phased out)
- Updated MovementStepView to use displayName

**Completed in 05-05:**
- Exercise model: String id, displayName (stored), dimensions, muscleWeights dict
- Direct movement relationship (replaces variant->movement chain)
- Computed isUnilateral, primaryMuscleGroup, sortedMuscleWeights
- Updated 15 downstream files for new Exercise API
- Movement.exercises relationship uncommented
- Variant.exercises inverse commented out

**Completed in 05-06:**
- Deleted Variant.swift and VariantMuscle.swift from Models/Core
- Removed Variant.self and VariantMuscle.self from PersistenceController schema
- Schema pruned from 9 to 7 models
- Build verified successful

**Completed in 05-07:**
- SeedData.swift: New Decodable types (EquipmentSeedData, MovementSeedData, PresetSeedData)
- EquipmentSeedService: Seeds 22 equipment types from equipment.json
- MovementSeedService: Seeds 30 movements from movements.json with muscle key validation
- PresetSeedService: Seeds 237 exercise presets from presets_all.json with lookup maps
- Deleted ExerciseSeedService.swift (deprecated Variant-based seeding)
- JSON resources: equipment.json, movements.json, presets_all.json added to bundle
- GymAnalsApp.init: Updated seeding order (Gym -> Equipment -> Movement -> Preset)

**Completed in 05-08:**
- JSON resources verified in app bundle (movements.json, equipment.json, presets_all.json)
- Old exercises.json deleted from Resources
- GymAnalsApp seeding wired and build verified
- Note: 05-07 and 05-08 ran in parallel; both created seed services (converged on same implementation)

**Completed in 05-09:**
- ExerciseCreationViewModel: dimensions property, suggestedName helper, Exercise.custom() with dimensions
- VariationStepView replaced with ExerciseNameStepView (equipment+movement suggested name, pre-fill)
- MuscleWeightViewModel: activeMuscles computed property, movement-aware resetToDefault
- All wizard views verified free of Variant/VariantMuscle references
- ExerciseCreationWizard updated to use ExerciseNameStepView

**Completed in 05-10:**
- ExerciseSearchResultsView: searchTerms in-memory filtering added
- ExerciseRow: equipment + category badges, muscle group subtitle
- ExerciseDetailView: dimensions, notes, sources, popularity, timer settings, toolbar favorite
- ExercisePickerSheet: searchTerms + movement name search
- Zero Variant references in codebase verified
- Full clean build passes
