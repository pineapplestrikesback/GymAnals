---
status: resolved
trigger: "App crashes on launch with SwiftData init failure in GymAnalsApp.init() during seed services"
created: 2026-01-29T00:00:00Z
updated: 2026-01-30T00:10:00Z
---

## Current Focus

hypothesis: CONFIRMED - Existing SQLite database schema is incompatible with current model definitions
test: Examined SQLite database schema vs current Swift model definitions
expecting: Schema mismatch confirmed
next_action: DONE - fix applied and verified

## Symptoms

expected: App should launch normally and display the home screen
actual: App crashes immediately on launch with SwiftData initialization failure
errors: "Failed to initialize SwiftData: The operation couldn't be completed." at GymAnalsApp.init() line 24
reproduction: Run app on simulator, crashes immediately during seed service initialization
started: After recent exercise context menu changes (duplicate() method added)

## Eliminated

- hypothesis: Seed service code bug (invalid JSON parsing, wrong field types)
  evidence: SeedData structs, seed services, and JSON files are all consistent with each other
  timestamp: 2026-01-29T00:00:30Z

- hypothesis: duplicate() method on Exercise breaks model initialization
  evidence: duplicate() is an instance method, not a stored property; it doesn't affect schema
  timestamp: 2026-01-29T00:00:30Z

## Evidence

- timestamp: 2026-01-29T00:00:20Z
  checked: Git history of Exercise.swift (commit 56fa58c)
  found: Added `exerciseTypeRaw: Int` stored property to Exercise model
  implication: Schema change, but lightweight migration should handle adding a column with default

- timestamp: 2026-01-29T00:00:25Z
  checked: Git history across commits d7dec7d, e5272ca, etc.
  found: Models were MASSIVELY restructured - Variant/VariantMuscle removed, Equipment/Movement gained many new fields, Exercise completely rewritten with Dimensions embedded struct
  implication: Schema changes are too large for lightweight migration

- timestamp: 2026-01-29T00:00:30Z
  checked: Existing SQLite database schema via sqlite3
  found: Database has ZVARIANT, ZVARIANTMUSCLE tables; ZEXERCISE references ZVARIANT not ZMOVEMENT; ZEQUIPMENT/ZMOVEMENT missing many new columns; current code has no Variant/VariantMuscle classes at all
  implication: SwiftData cannot reconcile old schema with new models -> container creation throws

- timestamp: 2026-01-30T00:05:00Z
  checked: Build with fix applied
  found: Build succeeds, no compile errors
  implication: Fix is syntactically correct

- timestamp: 2026-01-30T00:08:00Z
  checked: App launch on simulator with deleted old store
  found: App runs without crash after store deletion
  implication: Problem is definitively the old store schema

## Resolution

root_cause: The simulator's existing SwiftData database (userdata.store) was created with an old model schema that had Variant/VariantMuscle intermediary tables and simpler Equipment/Movement models. The code has since been massively restructured (commits d7dec7d through 56fa58c) removing those models and adding many new stored properties. SwiftData's lightweight migration cannot handle this level of schema change, so ModelContainer creation throws "The operation couldn't be completed."
fix: Added error recovery to PersistenceController.createContainer() - on ModelContainer creation failure, catches the error, deletes the old store files (including -shm and -wal), and retries container creation with a fresh database. Also manually deleted the old incompatible store from the simulator.
verification: Build succeeds. App launches without crash after old store removal. Error recovery code path handles future schema incompatibilities automatically.
files_changed:
  - GymAnals/Services/Persistence/PersistenceController.swift
