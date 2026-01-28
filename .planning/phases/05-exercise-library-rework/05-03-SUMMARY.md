---
phase: 05-exercise-library-rework
plan: 03
subsystem: database
tags: [swiftdata, equipment, model, category, embedded-struct]

# Dependency graph
requires:
  - phase: 05-01
    provides: EquipmentCategory enum, EquipmentProperties embedded struct
provides:
  - Updated Equipment model with String id, categoryRaw, properties, displayName
  - Backward-compatible initializer for existing seed service
affects: [05-07, 05-08, 05-09]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "String id for snake_case built-in identifiers"
    - "categoryRaw with computed accessor for SwiftData filtering"
    - "Embedded Codable struct (EquipmentProperties) in @Model"

key-files:
  created: []
  modified:
    - GymAnals/Models/Core/Equipment.swift
    - GymAnals/Models/Core/Exercise.swift
    - GymAnals/Features/ExerciseLibrary/Views/ExerciseDetailView.swift

key-decisions:
  - "String id allows snake_case identifiers (e.g., 'barbell') for built-in equipment while supporting UUID strings for custom"
  - "Convenience init(name:isBuiltIn:) preserves backward compatibility with ExerciseSeedService"
  - "displayName replaces name for consistency with Movement model naming"

patterns-established:
  - "Model id migration: UUID -> String with UUID().uuidString default"
  - "Embedded struct pattern: EquipmentProperties stored directly in @Model"

# Metrics
duration: 10min
completed: 2026-01-28
---

# Phase 05 Plan 03: Equipment Model Updates Summary

**Equipment model updated with String-based id, EquipmentCategory classification, and embedded EquipmentProperties struct for physical characteristics**

## Performance

- **Duration:** 10 min
- **Started:** 2026-01-28T15:50:09Z
- **Completed:** 2026-01-28T16:00:16Z
- **Tasks:** 1
- **Files modified:** 5

## Accomplishments
- Updated Equipment model with new schema matching equipment.json structure
- Changed id from UUID to String for snake_case built-in identifiers
- Added categoryRaw with computed category accessor for type-safe enum access
- Added embedded EquipmentProperties struct for physical characteristics
- Preserved backward compatibility via convenience initializer

## Task Commits

Each task was committed atomically:

1. **Task 1: Update Equipment model with new properties** - `e5272ca` (feat)

**Plan metadata:** pending

## Files Created/Modified
- `GymAnals/Models/Core/Equipment.swift` - Updated with String id, displayName, categoryRaw, properties, notes
- `GymAnals/Models/Core/Exercise.swift` - Updated to use equipment.displayName
- `GymAnals/Features/ExerciseLibrary/Views/ExerciseDetailView.swift` - Updated to use equipment.displayName
- `GymAnals/Features/ExerciseLibrary/Views/WizardSteps/MovementStepView.swift` - Updated to use Movement.displayName
- `GymAnals/Models/Core/Movement.swift` - Completed model update from 05-04 (was incomplete)

## Decisions Made
- **String id for identifiers:** Allows snake_case IDs like "barbell" for built-in equipment while UUID strings work for custom equipment
- **displayName over name:** Matches Movement model naming convention established in 05-04
- **Convenience initializer:** Maintains backward compatibility with existing ExerciseSeedService that uses `Equipment(name:isBuiltIn:)`

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Updated views using equipment.name to equipment.displayName**
- **Found during:** Task 1 (Equipment model update)
- **Issue:** Renaming `name` to `displayName` broke ExerciseDetailView and Exercise.displayName computed property
- **Fix:** Updated all references from `equipment?.name` to `equipment?.displayName`
- **Files modified:** Exercise.swift, ExerciseDetailView.swift
- **Verification:** Build succeeds
- **Committed in:** e5272ca (part of task commit)

**2. [Rule 3 - Blocking] Completed Movement model updates from 05-04**
- **Found during:** Task 1 (build verification)
- **Issue:** Previous 05-04 commit was incomplete - Movement.swift not included but views referenced displayName
- **Fix:** Included Movement model changes and MovementStepView updates
- **Files modified:** Movement.swift, MovementStepView.swift
- **Verification:** Build succeeds, all displayName references resolve
- **Committed in:** e5272ca (part of task commit)

---

**Total deviations:** 2 auto-fixed (2 blocking)
**Impact on plan:** Both auto-fixes necessary for build to succeed. Movement changes belong to 05-04 but were not properly committed previously. No scope creep - all changes support the planned objective.

## Issues Encountered
- The 05-04 commit (feat(05-04)) was incomplete - it updated views to use Movement.displayName but didn't include Movement.swift itself, causing build failures. Resolved by including the complete Movement model changes in this commit.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Equipment model ready for seeding 22 equipment types from equipment.json
- Plan 05-07 (Equipment Seed Service) can now proceed
- All model updates (Equipment, Movement) have consistent naming patterns (displayName, String id, categoryRaw)

---
*Phase: 05-exercise-library-rework*
*Completed: 2026-01-28*
