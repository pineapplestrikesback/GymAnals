---
status: resolved
trigger: "PresetSeedService fails to load presets_all.json from bundle - exercise list empty on launch"
created: 2026-01-30T00:00:00Z
updated: 2026-01-30T00:00:02Z
---

## Current Focus

hypothesis: CONFIRMED AND FIXED
test: Swift JSON decoding test script + full project build
expecting: N/A - resolved
next_action: Archive session

## Symptoms

expected: Exercise list should be populated with preset exercises on app launch
actual: Exercise list is empty
errors: PresetSeedService: Failed to load presets_all.json from bundle
reproduction: Open the app
started: Current state when building and running

## Eliminated

- hypothesis: presets_all.json not included in app bundle
  evidence: File exists at GymAnals/Resources/presets_all.json, project uses fileSystemSynchronizedGroups, file confirmed present in built .app bundle
  timestamp: 2026-01-30T00:00:00Z

- hypothesis: Bundle.main.url cannot find the file
  evidence: fileSystemSynchronizedGroups ensures automatic inclusion, file confirmed in .app bundle
  timestamp: 2026-01-30T00:00:00Z

## Evidence

- timestamp: 2026-01-30T00:00:00Z
  checked: presets_all.json file existence and project structure
  found: File exists at GymAnals/Resources/presets_all.json, project uses fileSystemSynchronizedGroups (auto-includes files)
  implication: File IS in the bundle, issue is elsewhere in the guard chain

- timestamp: 2026-01-30T00:00:00Z
  checked: JSON validity and field completeness
  found: Valid JSON with 237 presets, all required fields present
  implication: JSON structure is valid but decoding may fail

- timestamp: 2026-01-30T00:00:01Z
  checked: Swift JSON decoding with replica SeedPreset model
  found: DecodingError.typeMismatch at index 32 (standard_push_up) - "Expected to decode String but found number instead" for exerciseTypeRaw field
  implication: ROOT CAUSE - 29 presets have integer exerciseTypeRaw (1 or 4) instead of string values

- timestamp: 2026-01-30T00:00:01Z
  checked: Which presets have integer values and what they should be
  found: 26 presets with exerciseTypeRaw=1 (bodyweight exercises), 3 presets with exerciseTypeRaw=4 (duration exercises like planks)
  implication: Integer 1 maps to "bodyweight_reps", integer 4 maps to "duration"

- timestamp: 2026-01-30T00:00:02Z
  checked: Post-fix verification - Swift JSON decode test
  found: "SUCCESS: Decoded 237 presets" - all presets decode correctly
  implication: Fix verified - data issue resolved

- timestamp: 2026-01-30T00:00:02Z
  checked: Post-fix build verification
  found: BUILD SUCCEEDED with both JSON data fix and improved error handling
  implication: No compilation issues introduced

## Resolution

root_cause: JSONDecoder fails to decode presets_all.json because 29 preset entries have integer exerciseTypeRaw values (1 or 4) instead of the expected string values ("bodyweight_reps" or "duration"). The SeedPreset model declares exerciseTypeRaw as String?, so integer values cause a typeMismatch decoding error. Since the guard clause combines URL lookup, data loading, and JSON decoding into one statement, the failure prints the generic "Failed to load presets_all.json from bundle" message.
fix: (1) Replaced all 29 integer exerciseTypeRaw values in presets_all.json with correct strings: 1->"bodyweight_reps" (26 entries), 4->"duration" (3 entries). (2) Improved error handling in PresetSeedService.swift to separate bundle lookup failure from decode failure, printing the actual error.
verification: Swift decode script confirms all 237 presets decode successfully. Project build succeeds.
files_changed:
  - GymAnals/Resources/presets_all.json
  - GymAnals/Services/Seed/PresetSeedService.swift
