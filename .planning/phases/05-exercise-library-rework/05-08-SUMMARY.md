---
phase: 05-exercise-library-rework
plan: 08
subsystem: database
tags: [swiftdata, json, seeding, bundle-resources, exercise-presets]

# Dependency graph
requires:
  - phase: 05-exercise-library-rework (plans 01-06)
    provides: Updated models (Equipment, Movement, Exercise) with String IDs and new properties
provides:
  - 3 JSON resource files in app bundle (movements, equipment, presets)
  - 4 seed services (Gym, Equipment, Movement, Preset) with dependency ordering
  - App initialization calling all seed services on first launch
affects: [05-09 Exercise Browser, 05-10 Final Integration]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Separate seed services per entity type (EquipmentSeedService, MovementSeedService, PresetSeedService)"
    - "Dependency-ordered seeding: gym -> equipment -> movement -> presets"
    - "PBXFileSystemSynchronizedRootGroup auto-includes Resources/*.json in bundle"

key-files:
  created:
    - GymAnals/Resources/movements.json
    - GymAnals/Resources/equipment.json
    - GymAnals/Resources/presets_all.json
    - GymAnals/Services/Seed/EquipmentSeedService.swift
    - GymAnals/Services/Seed/MovementSeedService.swift
    - GymAnals/Services/Seed/PresetSeedService.swift
  modified:
    - GymAnals/App/GymAnalsApp.swift
    - GymAnals/Services/Seed/SeedData.swift

key-decisions:
  - "Seed services created here (05-08) to unblock build, since 05-07 runs in parallel"
  - "Old ExerciseSeedService deleted (used deprecated Variant model)"
  - "Seed order: GymSeedService -> EquipmentSeedService -> MovementSeedService -> PresetSeedService"

patterns-established:
  - "Entity-specific seed services: each entity type has its own seedIfNeeded service"
  - "Preset seed service fetches existing entities and builds lookup maps for relationship linking"

# Metrics
duration: 9min
completed: 2026-01-28
---

# Phase 5 Plan 8: JSON Resources and App Seeding Summary

**237 exercise presets seeded from 3 JSON bundle resources via 4 dependency-ordered seed services on first launch**

## Performance

- **Duration:** 9 min
- **Started:** 2026-01-28T18:56:09Z
- **Completed:** 2026-01-28T19:05:18Z
- **Tasks:** 3
- **Files modified:** 10

## Accomplishments
- Copied 3 JSON files (movements.json, equipment.json, presets_all.json) to app bundle Resources
- Created 3 new seed services (Equipment, Movement, Preset) following seedIfNeeded pattern
- Updated GymAnalsApp to call all seed services in correct dependency order
- Deleted old ExerciseSeedService and exercises.json (deprecated Variant format)
- Build verified successful with Xcode

## Task Commits

Each task was committed atomically:

1. **Task 1: Copy JSON files to Resources folder** - `29d8b56` (chore)
2. **Task 2: Update GymAnalsApp to use new seed services** - `805a95d` (feat)
3. **Task 3: Delete old exercises.json** - included in Task 1 commit `29d8b56`

## Files Created/Modified
- `GymAnals/Resources/movements.json` - 30 movement definitions with dimensions and muscle weights
- `GymAnals/Resources/equipment.json` - 22 equipment types with categories and properties
- `GymAnals/Resources/presets_all.json` - 237 exercise presets with search terms and muscle targeting
- `GymAnals/Services/Seed/EquipmentSeedService.swift` - Seeds 22 equipment from equipment.json
- `GymAnals/Services/Seed/MovementSeedService.swift` - Seeds 30 movements with muscle key validation
- `GymAnals/Services/Seed/PresetSeedService.swift` - Seeds 237 presets with movement/equipment linking
- `GymAnals/Services/Seed/SeedData.swift` - Updated Decodable types matching new JSON structures
- `GymAnals/App/GymAnalsApp.swift` - Calls 4 seed services in dependency order
- `GymAnals/Resources/exercises.json` - Deleted (old Variant-based format)
- `GymAnals/Services/Seed/ExerciseSeedService.swift` - Deleted (used deprecated Variant model)

## Decisions Made
- Created seed services here (05-08) since 05-07 runs in parallel and hasn't delivered yet -- deviation Rule 3 (blocking)
- Seed order enforced in GymAnalsApp: gym first (no deps), equipment and movement next (no deps), presets last (requires both)
- PresetSeedService builds lookup maps from fetched entities for O(1) relationship linking
- Muscle key validation with warning logs (non-fatal) in both Movement and Preset seed services

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Created seed services from 05-07 plan spec**
- **Found during:** Task 2 (Update GymAnalsApp)
- **Issue:** 05-07 (seed services) runs in parallel and hasn't committed yet. GymAnalsApp.swift references EquipmentSeedService, MovementSeedService, PresetSeedService which don't exist
- **Fix:** Created all 3 seed services + updated SeedData.swift following 05-07 plan specification exactly
- **Files modified:** SeedData.swift, EquipmentSeedService.swift, MovementSeedService.swift, PresetSeedService.swift
- **Verification:** Build succeeded
- **Committed in:** 805a95d (Task 2 commit)

**2. [Rule 3 - Blocking] Deleted ExerciseSeedService.swift**
- **Found during:** Task 2 (Update GymAnalsApp)
- **Issue:** ExerciseSeedService.swift references deleted Variant model, preventing compilation
- **Fix:** Deleted ExerciseSeedService.swift, replaced with 3 new entity-specific seed services
- **Files modified:** ExerciseSeedService.swift (deleted)
- **Verification:** Build succeeded, no references to ExerciseSeedService remain
- **Committed in:** 805a95d (Task 2 commit)

---

**Total deviations:** 2 auto-fixed (2 blocking)
**Impact on plan:** Both were necessary to unblock build compilation. Seed services follow 05-07 plan spec exactly. When 05-07 agent completes, it will find these files already exist.

## Issues Encountered
- iPhone 16 simulator not available; used iPhone 17 Pro simulator for build verification

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- All 237 exercise presets ready to seed on first launch
- Exercise browser (05-09) can now display preset exercises
- Final integration (05-10) can verify end-to-end seeding flow

---
*Phase: 05-exercise-library-rework*
*Completed: 2026-01-28*
