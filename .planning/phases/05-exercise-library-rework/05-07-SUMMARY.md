---
phase: 05-exercise-library-rework
plan: "07"
subsystem: data-seeding
tags: [seed-service, json, decodable, equipment, movement, exercise-preset]
dependency-graph:
  requires: ["05-03", "05-04", "05-05", "05-06"]
  provides: ["Equipment seed service", "Movement seed service", "Preset seed service", "New SeedData Decodable types"]
  affects: ["05-08", "05-09", "05-10"]
tech-stack:
  added: []
  patterns: ["Separate seed services per model", "Decodable types per JSON file", "Muscle key validation at seed time", "Dependency-ordered seeding (Equipment -> Movement -> Preset)"]
file-tracking:
  key-files:
    created:
      - GymAnals/Services/Seed/EquipmentSeedService.swift
      - GymAnals/Services/Seed/MovementSeedService.swift
      - GymAnals/Services/Seed/PresetSeedService.swift
      - GymAnals/Resources/equipment.json
      - GymAnals/Resources/movements.json
      - GymAnals/Resources/presets_all.json
    modified:
      - GymAnals/Services/Seed/SeedData.swift
      - GymAnals/App/GymAnalsApp.swift
    deleted:
      - GymAnals/Services/Seed/ExerciseSeedService.swift
      - GymAnals/Resources/exercises.json
decisions:
  - id: "05-07-01"
    choice: "Separate seed services per model type"
    reason: "Single-responsibility: each service owns one JSON file and one model type"
  - id: "05-07-02"
    choice: "Muscle key validation with warning (not failure)"
    reason: "Graceful degradation - invalid keys logged but don't block seeding"
  - id: "05-07-03"
    choice: "PresetSeedService builds lookup maps for Movement/Equipment IDs"
    reason: "Efficient O(1) relationship linking instead of O(n) per-preset fetching"
  - id: "05-07-04"
    choice: "Dependency-ordered seeding in GymAnalsApp.init"
    reason: "PresetSeedService requires Movement and Equipment already seeded"
metrics:
  duration: "5 min"
  completed: "2026-01-28"
---

# Phase 5 Plan 7: Seed Services Summary

**New seed services for equipment, movements, and exercise presets from separate JSON files**

## What Was Done

### Task 1: Update SeedData.swift with new Decodable types
Replaced the old `SeedData` (which used `SeedVariant`/`SeedMuscleWeight`) with three separate root types:
- `EquipmentSeedData` / `SeedEquipment` / `SeedEquipmentProperties`
- `MovementSeedData` / `SeedMovement` / `SeedApplicableDimensions` (with `toDictionary()` helper)
- `PresetSeedData` / `SeedPreset` / `SeedDimensions`

### Task 2: Create EquipmentSeedService
`EquipmentSeedService.seedIfNeeded(context:)` seeds 22 equipment types from `equipment.json`:
- Checks `FetchDescriptor<Equipment>` where `isBuiltIn == true`, count == 0
- Creates `Equipment` with `id`, `displayName`, `category`, `properties`, `notes`
- Saves with explicit `context.save()`

### Task 3: Create MovementSeedService
`MovementSeedService.seedIfNeeded(context:)` seeds 30 movements from `movements.json`:
- Checks `FetchDescriptor<Movement>` where `isBuiltIn == true`, count == 0
- Validates muscle weight keys against `Muscle` enum (prints warnings)
- Sets `applicableDimensions`, `applicableEquipment`, `defaultMuscleWeights`, `defaultDescription`, `notes`, `sources`

### Task 4: Create PresetSeedService
`PresetSeedService.seedIfNeeded(context:)` seeds 237 exercise presets from `presets_all.json`:
- Checks `FetchDescriptor<Exercise>` where `isBuiltIn == true`, count == 0
- Builds `[String: Movement]` and `[String: Equipment]` lookup maps for O(1) linking
- Creates `Exercise` with `Dimensions`, `muscleWeights`, `popularity`, `searchTerms`
- Validates muscle keys with collected `invalidMuscleKeys` set (single warning)

### Task 5: Remove old ExerciseSeedService
- Deleted `ExerciseSeedService.swift` (83 lines, used deprecated Variant model)
- Old `exercises.json` replaced with three new JSON files in prior commit
- Updated `GymAnalsApp.init()` seeding order:
  1. `GymSeedService.seedIfNeeded()` - default gym
  2. `EquipmentSeedService.seedIfNeeded()` - 22 equipment types
  3. `MovementSeedService.seedIfNeeded()` - 30 movements
  4. `PresetSeedService.seedIfNeeded()` - 237 exercise presets

## Decisions Made

| # | Decision | Rationale |
|---|----------|-----------|
| 1 | Separate seed services per model type | Single-responsibility: each service owns one JSON file and one model type |
| 2 | Muscle key validation with warning (not failure) | Graceful degradation - invalid keys logged but don't block seeding |
| 3 | PresetSeedService builds lookup maps | Efficient O(1) relationship linking instead of O(n) per-preset fetching |
| 4 | Dependency-ordered seeding in App init | PresetSeedService requires Movement and Equipment already seeded |

## Deviations from Plan

None - plan executed exactly as written.

## Verification

- Build succeeds with all seed services compiling
- EquipmentSeedService.swift contains `seedIfNeeded`
- MovementSeedService.swift contains `seedIfNeeded`
- PresetSeedService.swift contains `seedIfNeeded`
- ExerciseSeedService.swift deleted
- SeedData.swift contains `EquipmentSeedData`, `MovementSeedData`, `PresetSeedData`

## Commits

- `29d8b56`: chore(05-08): replace exercises.json with new JSON resources
- `805a95d`: feat(05-08): update seed services and app initialization

## Next Phase Readiness

- Equipment, Movement, and Exercise preset seed services are ready
- Blocker resolved: ExerciseSeedService.swift and old SeedData.swift no longer reference Variant/VariantMuscle
- Next: 05-08 (Exercise Preset Seeding - additional preset data) and 05-09 (Exercise Browser Updates)
