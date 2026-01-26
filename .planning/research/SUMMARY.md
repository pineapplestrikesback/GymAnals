# Project Research Summary

**Project:** GymAnals - iOS Workout Tracker
**Domain:** Native iOS fitness/workout tracking with per-muscle volume analytics
**Researched:** 2026-01-26
**Confidence:** HIGH

## Executive Summary

This is a native iOS workout tracker focused on precise per-muscle volume tracking through user-defined muscle taxonomies and weighted exercise contributions. The competitive landscape is mature (Hevy, Strong, JEFIT dominate) with high table stakes, but the proposed differentiators - user-defined muscles, configurable exercise-to-muscle contribution ratios, and gym-specific exercise branching - are genuinely novel and address real gaps in existing products.

The recommended approach is SwiftUI + SwiftData with MVVM architecture using @Observable ViewModels. This stack provides zero external dependencies, excellent productivity, and adequate performance for workout data volumes. The critical path is data modeling first (relationships are foundational), followed by basic CRUD, then workout logging, and finally the differentiating volume analytics dashboard. Going this route avoids the most common pitfalls: SwiftData relationship memory issues, array-as-blob modeling mistakes, and volume calculation complexity underestimation.

The main risk is SwiftData performance at scale (iOS 18 introduced relationship memory issues) and volume calculation complexity (weighted contributions create exponential edge cases). Mitigation: explicit relationship loading with FetchDescriptor, paginated queries, and a dedicated VolumeCalculator service with comprehensive unit tests from day one.

## Key Findings

### Recommended Stack

The research strongly supports an all-Apple-native stack with zero external dependencies. Swift 6 brings strict concurrency and @Observable macro support, SwiftUI is the clear investment direction, and SwiftData (despite performance concerns) provides sufficient capability for workout data volumes while offering massive productivity gains over Core Data or GRDB.

**Core technologies:**
- **Swift 6 + SwiftUI (iOS 17+)**: Native declarative UI, @Observable replaces ObservableObject pattern, excellent Charts integration
- **SwiftData**: Local-first persistence with @Query integration, adequate performance for hundreds of exercises and thousands of sets, trivial CloudKit sync path for future
- **Swift Charts**: Native charting perfect for volume dashboards (BarMark for weekly volumes, LineMark for progress trends)
- **@Observable MVVM**: Modern state management pattern with pull-based property-level invalidation, superior to Combine-based approaches
- **Swift Testing**: Modern @Test macro for unit tests, parallel execution by default, replaces XCTest for non-UI tests

**Critical decision: SwiftData over GRDB**
The constraint explicitly specifies SwiftData, and research confirms it's "good enough" for this use case. GRDB would provide 20-30% better performance but adds external dependency, requires manual schema management, and provides no productivity advantage at this data scale. SwiftData's weaknesses (slower queries, CloudKit private-database-only sync) don't block MVP features.

**Version targets:**
iOS 17+ deployment target required for SwiftData. The project's iOS 26.2+ constraint is well above minimum requirements and gives access to all modern APIs including new HealthKit workout session APIs.

### Expected Features

The workout tracker market has matured significantly. Missing table stakes results in immediate user abandonment.

**Must have (table stakes):**
- Fast set logging (2-3 taps, <10 seconds per set) - industry expectation from Hevy/Strong
- Previous lift display inline during logging - users need to know what to beat
- 200-300+ exercise library with custom exercise creation
- Workout templates/routines for program following
- Rest timer with auto-start and notifications
- Offline-first functionality (gyms have poor connectivity) - CRITICAL
- Set type tags (warm-up, working, failure, drop sets)
- Basic progress charts and PR tracking
- CSV export (users own their data - non-negotiable)
- Workout history and notes

**Should have (competitive differentiators - YOUR MOAT):**
- User-defined muscle taxonomy (not fixed categories like "shoulders" - users define "front delt", "lateral delt", "rear delt") - NO COMPETITOR OFFERS THIS
- Weighted set contributions per exercise (bench press: chest 1.0, front delt 0.5, triceps 0.3) - UNIQUE, VALIDATED BY RP STRENGTH RESEARCH
- Per-muscle volume dashboard with weekly totals and target zone indicators (MV/MEV/MAV/MRV)
- Gym-specific exercise branches (same "Lat Pulldown" tracks differently at "Home Gym" vs "24hr Fitness") - NOVEL SOLUTION
- Freestyle training mode ("check volume, decide what to train" - shows undertrained muscles) - UNIQUE

**Defer (v2+):**
- Apple Watch app (table stakes for serious competitors but can ship as v1.1)
- HealthKit integration (write-only to Apple Health, defer until core features solid)
- Progress photos, body measurements beyond weight
- Social features (Hevy does this well, but not your differentiator)
- AI workout suggestions (get manual tracking perfect first)

**Anti-features (explicitly avoid):**
- Calorie/nutrition tracking (scope creep, users have MyFitnessPal)
- Rigid algorithm-set targets (destroys motivation per research)
- Mandatory account creation (local-first with optional cloud backup)
- Complex gamification (patronizing to serious lifters)
- Workout content library (commodity, focus on user's own programs)

### Architecture Approach

Feature-based MVVM with @Observable ViewModels, SwiftData persistence, and a dedicated compute engine for volume calculations. Views stay thin and declarative, ViewModels handle business logic and state, Models define persistence schema, and a pure-function VolumeCalculator handles weighted contribution math.

**Major components:**
1. **SwiftData Models Layer** - @Model classes for Muscle, Exercise, ExerciseMuscle (junction table with contribution weights), Gym, ExerciseBranch (gym-specific exercise instance), WorkoutSet, Workout. Explicit inverse relationships prevent cascade failures.
2. **ViewModels (@Observable)** - WorkoutLogViewModel for active session state, VolumeViewModel for dashboard calculations, ExerciseLibraryViewModel for exercise management. Injected with ModelContext, use @MainActor for UI-bound state.
3. **Views (SwiftUI)** - Feature-based organization (WorkoutLog/, ExerciseLibrary/, VolumeDashboard/, History/). Use @Query for simple lists, @State for owned ViewModels, stay thin.
4. **Compute Engine** - VolumeCalculator with pure functions for volume aggregation. Handles weighted contributions: volume = sum(sets × reps × contribution_weight). Separate from views for testability.
5. **Services (optional)** - HealthKit integration layer (defer to Phase 5+), injected as dependencies.

**Key architectural decision: Junction table for weighted relationships**
Exercise-to-Muscle is many-to-many WITH attributes (contribution weight 0.0-1.0). Requires explicit ExerciseMuscle junction model. Don't use [String] arrays (become opaque Codable blobs, can't query) or implicit relationships (lose contribution data).

**Data flow patterns:**
- Read: SwiftData Models → @Query in View/ViewModel → View renders
- Write: User action → View → ViewModel method → ModelContext.insert/update → SwiftData persists
- Compute: @Query fetches sets → VolumeCalculator.calculate() → ViewModel exposes → View displays

### Critical Pitfalls

These are domain-specific pitfalls verified through official documentation and community battle scars. Each can cause rewrites or major delays.

1. **SwiftData relationship memory explosion (iOS 18+)** - Accessing .count on relationship arrays or loading models with @Attribute(.externalStorage) causes entire object graphs to load into memory. With hundreds of workouts and thousands of sets, the app runs out of memory and crashes. **Mitigation:** Use FetchDescriptor with relationshipKeyPathsForPrefetching for explicit loading, paginate queries with fetchLimit, test with 500+ workouts during development.

2. **Array properties as Codable blobs** - Modeling muscles as [String] arrays prevents filtering by muscle and breaks volume aggregation. SwiftData stores arrays as JSON blobs that SQLite can't search. **Mitigation:** Model Muscle as @Model entity with proper relationships from day one.

3. **@Query coupling throughout views** - Using @Query everywhere couples UI to SwiftData, makes views untestable, and requires touching every view if persistence changes. **Mitigation:** Centralize data access in repository/ViewModels, reserve @Query for top-level container views only.

4. **Volume calculation complexity underestimation** - Weighted contributions create exponential edge cases (bodyweight exercises, isometrics, drop sets, machine resistance curves). Apps ship with broken calculations. **Mitigation:** Dedicated VolumeCalculator service with comprehensive unit tests before building dashboard UI. Handle edge cases explicitly.

5. **Gym-specific exercise branch data explosion** - Naive approach: clone exercises for each gym. Result: volume fragments across dozens of duplicates, library becomes unusable. **Mitigation:** Separate Exercise (canonical identity) from ExerciseBranch (gym-specific settings), aggregate volume at Exercise level.

**Moderate pitfalls to watch:**
- @Observable ViewModel lifecycle confusion (use @State for owned objects, not inline creation)
- SwiftUI List performance with large workout history (use LazyVStack + pagination)
- Mid-workout state loss (auto-save draft after each set with debounce)
- HealthKit authorization UX (request at moment of value with clear explanation, not at launch)

## Implications for Roadmap

Based on architectural dependencies and pitfall prevention, here's the recommended phase structure:

### Phase 1: Foundation - Data Models & App Shell
**Rationale:** Everything depends on models existing and being correct. SwiftData relationships are foundational - mistakes here require rewrites. The junction table pattern for weighted contributions MUST be established now.

**Delivers:**
- All @Model classes (Muscle, Exercise, ExerciseMuscle, Gym, ExerciseBranch, WorkoutSet, Workout)
- ModelContainer setup with schema
- Basic tab-based navigation shell
- Initial CRUD for Muscles and Gyms (users need to define their taxonomy before anything else)

**Addresses:**
- Table stakes: foundation for all features
- Differentiators: enables user-defined muscle taxonomy, weighted contributions

**Avoids:**
- Pitfall #2 (array-as-blob modeling)
- Pitfall #5 (gym branch data explosion)
- Sets up mitigation for Pitfall #1 (relationship memory issues)

**Research flag:** SKIP - SwiftData patterns are well-documented, architecture research already thorough

### Phase 2: Core CRUD - Exercise Library & Management
**Rationale:** Users must set up their exercise library and muscle taxonomy before logging workouts. This phase establishes the content foundation.

**Delivers:**
- ExerciseListView with search and filtering
- ExerciseDetailView with create/edit
- MuscleContributionEditor (visual UI for setting exercise → muscle contribution weights)
- 200-300 pre-seeded exercise library with default muscle targets
- Custom exercise creation

**Addresses:**
- Table stakes: exercise library (200+ exercises), custom exercises
- Differentiators: muscle contribution weight editing UI

**Uses:**
- SwiftData @Query for exercise lists
- Swift Charts (preparation for later phases)

**Avoids:**
- Pitfall #12 (search performance) - add @Attribute(.index) on exercise name
- Pitfall #2 (proper relationship queries, not array filtering)

**Research flag:** SKIP - standard CRUD patterns, UI/UX is straightforward

### Phase 3: Workout Logging - Active Session Management
**Rationale:** Core value proposition. Must be fast (<10 seconds per set) and reliable. This is where competitors win or lose users.

**Delivers:**
- WorkoutLogViewModel with session state management
- WorkoutLogView with fast set input (reps/weight entry)
- ExercisePickerView with gym-aware branching
- Rest timer with auto-start and notifications
- Previous lift display inline
- Auto-save draft workouts (every set logged)
- Set type tags (warm-up, working, failure, drop set)

**Addresses:**
- Table stakes: fast set logging, previous lift display, rest timer, set type tags, offline-first
- Differentiators: gym-specific exercise branching in action

**Uses:**
- @Observable ViewModel pattern
- SwiftData ModelContext for persistence
- Background task API for auto-save

**Avoids:**
- Pitfall #8 (mid-workout state loss) - auto-save with debounce, crash recovery
- Pitfall #6 (@Observable lifecycle) - proper @State ownership
- Pitfall #3 (@Query coupling) - ViewModel owns data access

**Research flag:** CONSIDER - Rest timer background behavior and notification best practices might need research

### Phase 4: Analytics Foundation - Volume Dashboard
**Rationale:** This is the core differentiator. Volume calculations with weighted contributions are complex and must be correct. Build compute engine with comprehensive tests before UI.

**Delivers:**
- VolumeCalculator service (pure functions, heavily unit tested)
- Volume calculation for weighted muscle contributions
- VolumeViewModel with weekly/monthly aggregations
- VolumeDashboardView with per-muscle volume cards
- Swift Charts integration (BarMark for weekly volumes, SectorMark for muscle distribution)
- Target zone indicators (MV/MEV/MAV/MRV) - user-configurable

**Addresses:**
- Differentiators: per-muscle volume dashboard, weighted contributions calculations
- Table stakes: basic progress charts

**Uses:**
- Swift Charts (BarMark, LineMark, AreaMark, SectorMark)
- VolumeCalculator compute engine
- Cached calculations in ViewModel

**Avoids:**
- Pitfall #4 (volume complexity underestimation) - dedicated service, comprehensive edge case handling
- Pitfall #13 (dashboard view body computation) - calculations in ViewModel, not view
- Pitfall #1 (relationship memory) - paginated queries for large history

**Research flag:** LIKELY NEEDED - Volume calculation edge cases (bodyweight, isometrics, machines) and research-backed target zones (MV/MEV/MAV/MRV) might need deeper domain research

### Phase 5: History & Progress - Workout Archives
**Rationale:** Users need to review past workouts and track long-term progress. Must handle large datasets gracefully.

**Delivers:**
- WorkoutHistoryView with date-based browsing
- WorkoutDetailView (read-only past workout)
- Exercise progress history (weight/reps over time with line charts)
- PR detection and display
- Body weight logging and history
- CSV export functionality

**Addresses:**
- Table stakes: workout history, basic charts, PR tracking, CSV export, body weight tracking

**Uses:**
- LazyVStack with pagination
- FetchDescriptor with fetchLimit for performance
- Swift Charts (LineMark for progress over time)

**Avoids:**
- Pitfall #7 (List performance) - LazyVStack, pagination, keep rows simple
- Pitfall #1 (relationship memory) - explicit relationship loading, don't access .count

**Research flag:** SKIP - standard patterns for history/list views

### Phase 6: Platform Integration - HealthKit & Ecosystem
**Rationale:** Table stakes for serious iOS fitness apps but not blocking MVP. Write-only to HealthKit is straightforward. Defer Apple Watch to post-launch.

**Delivers:**
- HealthKit integration (write workouts to Apple Health)
- Workout session API usage (iOS 26 brings this to iPhone)
- Settings for HealthKit permissions and data sync preferences
- Export/import for backup and data portability

**Addresses:**
- Table stakes: HealthKit sync, data export

**Uses:**
- HealthKit framework
- iOS 26 workout session APIs

**Avoids:**
- Pitfall #9 (HealthKit authorization UX) - request at moment of value, clear explanation, handle denial gracefully
- Don't implement bidirectional sync (write-only to HealthKit)

**Research flag:** LIKELY NEEDED - HealthKit workout session API (new in iOS 26) and data mapping best practices

### Phase 7: Polish & Differentiator Refinement
**Rationale:** Enhance core differentiators and add polish features that improve UX.

**Delivers:**
- Freestyle training mode (volume-aware "what to train" suggestions)
- Volume-aware workout template suggestions
- Workout templates/routines management
- Notes per workout and per exercise
- Enhanced muscle heat map visualization
- Onboarding flow for muscle taxonomy setup

**Addresses:**
- Differentiators: freestyle mode, volume-aware suggestions
- Table stakes: workout templates, notes

**Research flag:** SKIP - builds on existing volume dashboard, standard UX patterns

### Phase Ordering Rationale

**Dependency-driven sequence:**
- Phase 1 (Models) → Phase 2 (Library) → Phase 3 (Logging) → Phase 4 (Analytics) represents the natural dependency chain. You can't log workouts without exercises, can't calculate volume without logged sets.
- Phase 5 (History) depends on Phases 1-3 having data to display
- Phase 6 (HealthKit) integrates with completed workout data from Phase 3
- Phase 7 (Polish) builds on Phase 4's volume calculations

**Pitfall avoidance:**
- Foundation-first prevents Pitfall #2 (array modeling) and Pitfall #5 (branch explosion)
- Core CRUD before logging prevents library gaps during workout entry
- Analytics after logging ensures VolumeCalculator gets real data for testing
- HealthKit last prevents Pitfall #9 (premature permission requests)

**Architectural alignment:**
- Phases 1-2 build the data layer
- Phase 3 builds the interaction layer
- Phases 4-5 build the analytics layer
- Phase 6 builds the integration layer
- Phase 7 enhances all layers

### Research Flags

**Phases likely needing /gsd:research-phase during planning:**

- **Phase 3 (Workout Logging):** Rest timer background behavior, notification best practices, iOS background task limitations for auto-save. Medium confidence on implementation details.

- **Phase 4 (Volume Dashboard):** Volume calculation edge cases (bodyweight exercises, isometrics, machine resistance curves), research-backed target zone ranges (MV/MEV/MAV/MRV standards), optimal caching strategies for large datasets. Low-medium confidence on domain-specific calculations.

- **Phase 6 (HealthKit Integration):** iOS 26 workout session API (new feature, limited documentation), HealthKit data mapping best practices, authorization flow UX patterns. Medium confidence - official docs exist but community patterns still emerging.

**Phases with standard patterns (skip research):**

- **Phase 1 (Foundation):** SwiftData modeling is well-documented, architecture patterns established
- **Phase 2 (Core CRUD):** Standard CRUD patterns, search/filter are solved problems
- **Phase 5 (History):** List views and pagination are well-understood patterns
- **Phase 7 (Polish):** Builds on existing systems, UX patterns are standard

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Official Apple documentation, verified through multiple sources. SwiftData limitations are well-understood from iOS 18 community experience. Zero external dependencies is low-risk. |
| Features | HIGH | Extensive competitor analysis (Hevy, Strong, JEFIT, Fitbod, StrengthLog). Table stakes are clear from market leaders. Differentiators validated against RP Strength research and user pain points. |
| Architecture | HIGH | MVVM + @Observable is established pattern for iOS 17+. SwiftData relationship patterns verified through Apple docs and community tutorials. VolumeCalculator separation is sound design. |
| Pitfalls | HIGH | SwiftData memory issues verified via Apple Developer Forums and WWDC sessions. Volume complexity validated through competitor teardowns and fitness domain research. HealthKit pitfalls from official documentation. |

**Overall confidence:** HIGH

Research is comprehensive with strong official documentation support (Apple WWDC, developer guides) and validated community patterns (Hacking with Swift, domain experts). Differentiators are validated through fitness research (RP Strength, Stronger By Science). The main uncertainties are implementation details (background tasks, caching strategies) rather than architectural or strategic concerns.

### Gaps to Address

**Volume calculation edge cases:** While the core weighted contribution model is sound, handling edge cases needs deeper domain research during Phase 4:
- Bodyweight exercises (estimated body weight × reps, or just reps?)
- Isometric holds (time-under-tension conversion to "volume")
- Drop sets and cluster sets (how to count contributions)
- Machine exercises with non-linear resistance curves
- **Handle during:** Phase 4 planning with /gsd:research-phase focused on fitness science literature

**Target zone standards (MV/MEV/MAV/MRV):** User-configurable is the safe path, but research-backed defaults would improve UX:
- Minimum Effective Volume (MEV) per muscle group
- Maximum Adaptive Volume (MAV) per muscle group
- Maximum Recoverable Volume (MRV) per muscle group
- **Handle during:** Phase 4 planning with domain-specific research into hypertrophy literature

**iOS 26 workout session API:** New feature with limited community adoption examples:
- Best practices for workout session lifecycle
- Data structure for session → HealthKit mapping
- Background processing and app backgrounding behavior
- **Handle during:** Phase 6 planning with focused API research

**SwiftData performance at scale:** While mitigation strategies are documented, real-world testing with 500+ workouts and 5000+ sets is needed:
- Optimal pagination size for history views
- Query performance with complex predicates
- Memory profiling with realistic data volumes
- **Handle during:** Phase 1 completion and ongoing performance testing

**Muscle taxonomy defaults:** While user-defined is the differentiator, need sensible defaults for first-time users:
- Standard muscle list based on anatomy
- Default contribution weights for common exercises
- Progressive disclosure strategy (start simple, allow customization)
- **Handle during:** Phase 2 planning, possibly UX research for onboarding

## Sources

### Primary (HIGH confidence)

**Official Apple Documentation:**
- [Apple SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Apple HealthKit Documentation](https://developer.apple.com/documentation/healthkit)
- [Apple Swift Charts Documentation](https://developer.apple.com/documentation/charts)
- [Apple Swift Testing Documentation](https://developer.apple.com/xcode/swift-testing)
- [WWDC 2025: Track Workouts with HealthKit (Session 322)](https://developer.apple.com/videos/play/wwdc2025/322/)
- [WWDC 2025: Optimize SwiftUI Performance (Session 306)](https://developer.apple.com/videos/play/wwdc2025/306/)

**Apple Developer Forums (verified issues):**
- [SwiftData iOS 18 Memory Issues (Thread 761522)](https://developer.apple.com/forums/thread/761522)
- [SwiftData CPU Issues (Thread 747858)](https://developer.apple.com/forums/thread/747858)
- [@Observable with MVVM (Thread 732200)](https://forums.developer.apple.com/forums/thread/732200)

### Secondary (MEDIUM-HIGH confidence)

**Technical Tutorials (established sources):**
- [Hacking with Swift: SwiftData by Example](https://www.hackingwithswift.com/quick-start/swiftdata)
- [Hacking with Swift: Common SwiftData Errors](https://www.hackingwithswift.com/quick-start/swiftdata/common-swiftdata-errors-and-their-solutions)
- [FatBobman: Key Considerations Before Using SwiftData](https://fatbobman.com/en/posts/key-considerations-before-using-swiftdata/)
- [FatBobman: Relationships in SwiftData](https://fatbobman.com/en/posts/relationships-in-swiftdata-changes-and-considerations/)
- [AzamSharp: SwiftData Architecture Patterns](https://azamsharp.com/2025/03/28/swiftdata-architecture-patterns-and-practices.html)
- [High Performance SwiftData Apps (Jacob's Tech Tavern)](https://blog.jacobstechtavern.com/p/high-performance-swiftdata)

**Competitor Analysis:**
- [Hevy App Features](https://www.hevyapp.com/features/)
- [Hevy: Sets Per Muscle Group](https://www.hevyapp.com/features/sets-per-muscle-group-per-week/)
- [Strong vs Hevy Comparison 2025](https://gymgod.app/blog/strong-vs-hevy)
- [Best Workout Apps 2025 Comparison](https://just12reps.com/best-weightlifting-apps-of-2025-compare-strong-fitbod-hevy-jefit-just12reps/)
- [Garage Gym Reviews: Best Workout Apps](https://www.garagegymreviews.com/best-workout-apps)

**Volume Tracking Science:**
- [RP Strength: Training Volume Landmarks](https://rpstrength.com/blogs/articles/training-volume-landmarks-muscle-growth)
- [PMC: Set-Volume for Limb Muscles](https://pmc.ncbi.nlm.nih.gov/articles/PMC6681288/)
- [Stronger By Science: Training Volume](https://www.strongerbyscience.com/volume/)
- [Fitbod Algorithm Blog](https://fitbod.me/blog/the-best-personalized-workout-apps-for-strength-training-ranked-by-real-results-2025/)

### Tertiary (MEDIUM confidence)

**Community Patterns & Analysis:**
- [Architecture Playbook for iOS 2025 (Medium)](https://medium.com/@mrhotfix/the-architecture-playbook-for-ios-2025-swiftui-concurrency-modular-design-a35b98cbf688)
- [Modern MVVM in SwiftUI 2025 (Medium)](https://medium.com/@minalkewat/modern-mvvm-in-swiftui-2025-the-clean-architecture-youve-been-waiting-for-72a7d576648e)
- [SwiftUI MVVM Best Practices (zthh.dev)](https://zthh.dev/blogs/swiftui-mvvm-best-practices-tips-techniques)
- [Core Data vs SwiftData 2025 (DistantJob)](https://distantjob.com/blog/core-data-vs-swiftdata/)
- [SwiftData @Query Considered Harmful (Pado)](https://pado.name/blog/2025/02/swiftdata-query/)

**User Pain Points:**
- [7 Things People Hate in Fitness Apps](https://www.ready4s.com/blog/7-things-people-hate-in-fitness-apps)
- [Fitness App Motivation Study](https://studyfinds.org/fitness-app-motivation-study-myfitnesspal/)
- [Fitness App Development Mistakes](https://www.resourcifi.com/fitness-app-development-mistakes-avoid/)

---
*Research completed: 2026-01-26*
*Ready for roadmap: YES*
