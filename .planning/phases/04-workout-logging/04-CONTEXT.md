# Phase 4: Workout Logging - Context

**Gathered:** 2026-01-28
**Status:** Ready for planning

<domain>
## Phase Boundary

Active workout session with fast set logging, rest timers, and crash recovery. Users can start workouts, add exercises, log sets quickly, see previous numbers, and finish/save. Workout history viewing and analytics are separate phases.

</domain>

<decisions>
## Implementation Decisions

### Set Entry UX
- Stepper buttons + keypad input (like Hevy) — tap +/- to adjust, or tap field to type
- Pre-fill with previous workout's values for that set number
- Tap checkmark button to confirm/log a set
- Weight increment: 1kg steps for metric, 1.25 lbs for imperial
- Outlier detection: warn user if entered weight is drastically higher than previous (e.g., "Previous was 53kg, you entered 533kg — confirm?")

### Workout Layout
- Collapsible exercise sections with all expanded by default
- Sticky header showing: elapsed duration, total sets completed, rest timer
- Bottom floating "+" button to add exercises from library
- Drag handles on exercise section headers for reordering
- Tap exercise header to collapse/expand only
- Swipe left on exercise header to delete exercise
- Swipe left on set row to delete individual set
- "+ Add Set" button below sets within each exercise (no auto-add)
- "Finish Workout" button at bottom of list after all exercises
- Discard workout option hidden in "..." menu only (discourage accidental discard)

### Per-Set Independent Timers (Novel Feature)
- Each logged set gets its own countdown timer that persists independently
- Header shows the most recent timer (resets when new set logged)
- Multiple timers can run simultaneously across different exercises
- Per-set timers disappear when they reach zero
- Tapping a per-set timer opens controls: skip timer, +30s, +1m
- Enables clean superset workflows without timer confusion

### Previous Numbers
- Show last workout's numbers only (not PR or history)
- Display inline in each set row: "last: 8×100" alongside input fields
- Gym-specific: only show previous at the current gym (matches exercise branches)
- If adding sets beyond last workout's count, show no previous data
- Pre-fill input fields from previous workout values

### Rest Timer Behavior
- 2 minutes default per exercise, adjustable per exercise
- Toggle per exercise whether timer auto-starts on set completion
- Rest duration configurable in both exercise detail view and during workout
- Timer continues in background with local push notification when done
- Notification style user-configurable in settings (sound, haptic, or both)
- Only the most recent timer (header) triggers notifications, not all per-set timers
- Manual timer start: tap header timer, prompts for duration selection

### Claude's Discretion
- Exact styling of timer controls popover
- Keyboard behavior and focus management
- Empty state when no exercises added yet
- Exercise picker sheet design
- Set row layout and spacing details

</decisions>

<specifics>
## Specific Ideas

- Per-set independent timers are a differentiating feature — "no other app does this"
- Timer behavior inspiration: user wants to superset freely without timer confusion
- Set logging should feel fast — target under 10 seconds per set

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 04-workout-logging*
*Context gathered: 2026-01-28*
