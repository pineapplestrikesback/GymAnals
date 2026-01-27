# Phase 3: Gyms - Context

**Gathered:** 2026-01-27
**Status:** Ready for planning

<domain>
## Phase Boundary

Define gyms and create exercise branches that track different weights per location. Gym selection lives in the workout tab. Workout logging itself is Phase 4.

</domain>

<decisions>
## Implementation Decisions

### Gym Management
- Gyms have name only (no notes, no equipment list)
- System-created "Default Gym" always exists and cannot be deleted or renamed
- User-created gyms can be deleted with options: delete + history, delete + keep history, delete + merge into another gym
- Gym list ordered by most recently used
- Each gym has a user-selectable color tag displayed as an accent dot/badge
- Gym management screen shows workout count per gym

### Gym Selection UX
- Gym selector lives in workout tab, above "Start new workout"
- Displayed as gym name with color dot
- Tapping opens a simple sheet with gym list + "Manage gyms" option
- "Manage gyms" navigates to full management screen
- Selected gym persists between app sessions
- Workout tab header shows subtle gym color accent
- During active workout: gym label is tappable but view-only (can't change mid-workout)
- To start at a different gym, change selection first (no quick-start shortcut)

### Exercise Branching
- Branch created when user chooses "Track at this gym" at log time (not automatic)
- Once branch exists, app remembers last choice for that exercise
- Branches appear only in exercise detail view (hidden in main library)
- Previous weight shown is gym-specific
- No copying history between gym branches — each starts fresh
- When first logging at a gym with no history, show hint: "Last at [Other Gym]: [weight]"
- Parent exercise name changes propagate to all branches
- Branches can have optional, additional gym-specific notes
- Custom exercises are globally available (not gym-specific)
- Favorites are global (not per-gym)

### Branch Inheritance
- Muscle weights always inherited from parent (no per-branch override)
- Equipment list is global only (inherited from parent)
- Deleting parent cascades to delete all branches
- Branch data is weight history only (notes mentioned above are optional)
- Deleting a branch: ask what to do with history (delete, keep, or merge)

### Claude's Discretion
- Color palette for gym tags
- Exact sheet presentation style
- Empty state for manage gyms screen
- Hint styling for cross-gym weight suggestions

</decisions>

<specifics>
## Specific Ideas

- "When adding a new exercise to an ongoing workout, user has the option to either start logging to the gym the workout started with or add the reps/weights to the default history"
- Exercise library should have optional toggle to filter by "exercises with history at current gym"

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 03-gyms*
*Context gathered: 2026-01-27*
