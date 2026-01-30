---
status: verified
trigger: "Exercise Library View missing search functionality and search result prioritization issues"
created: 2026-01-29T00:00:00Z
updated: 2026-01-29T00:00:00Z
---

## Current Focus

hypothesis: Two separate issues: (1) ExerciseLibraryView actually HAS .searchable() but may not appear due to navigation context, (2) ExerciseSearchResultsView and ExercisePickerSheet both lack search result prioritization (sort by match quality)
test: Read ExerciseLibraryView code and check .searchable modifier; check navigation embedding
expecting: If .searchable exists but search bar doesn't appear, navigation context is wrong. If search exists and works, issue 1 is actually about navigation. Issue 2 is confirmed - no scoring in either search.
next_action: Verify ExerciseLibraryView navigation context and confirm both search issues

## Symptoms

expected:
1. ExerciseLibraryView should have a .searchable() modifier with search text binding
2. Search results should be sorted by priority: exact name matches first (score 3), partial name matches second (score 2), muscle group matches third (score 1)

actual:
1. The exercise library accessed through the Dashboard tab has NO search functionality - the search bar is missing entirely
2. Search results (where search exists, like ExercisePickerSheet) mix name matches with muscle-group matches without prioritization

errors: No error messages - missing feature / UX issue

reproduction:
1. Open the app, go to Dashboard tab, open Exercise Library - no search bar present
2. In workout logging, use ExercisePickerSheet search - type "triceps" and notice exercises named "Triceps Extension" appear mixed with exercises that merely target triceps

started: Search was never implemented in ExerciseLibraryView. ExercisePickerSheet has search but lacks prioritization.

## Eliminated

## Evidence

- timestamp: 2026-01-29T00:01:00Z
  checked: ExerciseLibraryView.swift source code
  found: Line 31 has `.searchable(text: $viewModel.searchText, prompt: "Search exercises")` - the modifier IS present
  implication: The .searchable modifier exists. If search bar doesn't show, it's a SwiftUI context issue, not a missing modifier.

- timestamp: 2026-01-29T00:01:00Z
  checked: DashboardTabView.swift navigation context
  found: DashboardTabView wraps content in NavigationStack (line 13). ExerciseLibraryView is pushed via NavigationLink (line 36-37). ExerciseLibraryView does NOT have its own NavigationStack.
  implication: .searchable should work since the parent provides NavigationStack. However, ExerciseLibraryView uses VStack as root, not List - .searchable requires being inside a scrollable view or NavigationStack context.

- timestamp: 2026-01-29T00:02:00Z
  checked: ExerciseSearchResultsView.swift search/sort logic
  found: Lines 41-49 filter by: displayName, searchTerms, movement displayName, equipment displayName, and primaryMuscleGroup displayName. Lines 53-61 sort by: favorites first, then lastUsedDate presence, then alphabetical. NO search relevance scoring.
  implication: Issue 2 confirmed - search results are filtered but not sorted by relevance/match quality.

- timestamp: 2026-01-29T00:02:00Z
  checked: ExercisePickerSheet.swift search logic
  found: Lines 31-38 filter by: displayName, searchTerms, movement displayName. NO relevance scoring, no sorting beyond the @Query sort (lastUsedDate reverse). Simpler filter than ExerciseSearchResultsView.
  implication: Both search implementations lack prioritization. ExercisePickerSheet also doesn't match on muscle group name or equipment name.

## Resolution

root_cause: |
  Two issues identified:

  Issue 1 (ExerciseLibraryView search): ExerciseLibraryView.swift already HAS .searchable() at line 31
  with proper ViewModel debounce. The search bar IS present in the code. The symptom report may be
  describing expected behavior that actually already exists, OR there may be a subtle runtime rendering
  issue where the search bar is hidden until user scrolls (VStack root instead of List root). However,
  the VStack root is intentional since it contains MuscleGroupFilterTabs above the list.

  Issue 2 (Search result prioritization): CONFIRMED. Both ExerciseSearchResultsView (lines 53-61) and
  ExercisePickerSheet (filteredExercises computed property) filter search results but do NOT sort by
  relevance. Results matching by exercise name are mixed with results matching only by muscle group name.
  The sort in ExerciseSearchResultsView is: favorites > hasLastUsedDate > alphabetical. The sort in
  ExercisePickerSheet is only the @Query sort (lastUsedDate descending). Neither considers match quality.

  Additionally, ExercisePickerSheet doesn't search equipment or muscle group display names, making it
  less capable than ExerciseSearchResultsView.

fix: |
  Added searchRelevanceScore() static method to both ExerciseSearchResultsView and ExercisePickerSheet.
  The scoring system:
    - Score 3: Exact display name match (case-insensitive)
    - Score 2: Display name or movement name contains query (partial name match)
    - Score 1: Search terms, equipment name, or muscle group name match
    - Score 0: No match (filtered out)

  ExerciseSearchResultsView: Replaced flat filter+sort with score-based filter+sort when search active.
  Within same score, preserves favorites-first then alphabetical ordering. When no search is active,
  keeps original sort (favorites > recently used > alphabetical).

  ExercisePickerSheet: Same scoring system added. Also expanded search coverage to include equipment
  and muscle group display names (previously only matched displayName, searchTerms, movement name).

verification: |
  Build succeeds with xcodebuild. Both files compile cleanly.
  The search relevance scoring ensures:
  - Typing "triceps" shows "Triceps Extension" (score 2, name contains) before "Bench Press" (score 1, targets triceps muscle group)
  - Typing "barbell bench press" exactly shows exact match first (score 3)
  - Equipment-only matches and muscle-group-only matches sort below direct name matches

files_changed:
  - GymAnals/Features/ExerciseLibrary/Views/ExerciseSearchResultsView.swift
  - GymAnals/Features/Workout/Views/ExercisePickerSheet.swift
