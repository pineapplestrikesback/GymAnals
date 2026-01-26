# Phase 1: Foundation - Context

**Gathered:** 2026-01-26
**Status:** Ready for planning

<domain>
## Phase Boundary

Establish SwiftData persistence with all core models and a navigable app shell. Users can launch the app to a tab-based navigation with placeholder content. All data models exist with proper relationships. App works fully offline.

</domain>

<decisions>
## Implementation Decisions

### Tab Structure
- **3 tabs:** Workout, Dashboard, Settings
- Default landing tab: Workout
- Tab bar style: SF Symbols with labels (standard iOS)
- Tapping active tab scrolls to top (standard iOS behavior)
- Navigation bar: Large titles that collapse on scroll
- Active workout indicator: Badge (red dot) on Workout tab

### Workout Tab
- Shows "Start Workout" button with recent workouts below when no active workout
- First launch: Setup prompt before first workout (gym + preferences)

### Dashboard Tab
- Hub page with summary info (7-day bar chart of workouts)
- Navigation buttons to sections: Gyms, Exercises, Muscle breakdown, Progress
- Exercise library lives inside Dashboard
- Gym management lives inside Dashboard

### Settings Tab
- Account (local profile/preferences) + app preferences
- No user accounts — pure local app
- Weight unit preference: User choice (kg or lbs) — single global setting

### Exercise Model Hierarchy (MAJOR CHANGE)
- **New hierarchy:** Movement → Variant → Equipment → Unilateral flag
- Movement = base pattern (Press, Pull, Row, Curl, etc.)
- Variant = specific variation (Incline Press, Decline Press, Preacher Curl)
- Equipment = equipment-specific version (Barbell Incline Press, Dumbbell Incline Press)
- Unilateral/Bilateral = flag on equipment level, for reference only (no special logging UI)
- **Muscle weights attach at Variant level** (not Movement, not Equipment)
- Users can create at all levels (movements, variants, equipment combos)
- Replaces the flat Exercise model from original requirements

### Gym Branches → Weight History
- ExerciseBranch model renamed to gym-specific weight history
- Same exercise entity, weight history tracked per-gym
- No separate "branch" exercises — just per-gym weight records

### Model Naming
- Muscle taxonomy: Detailed (30-40 muscles)
- Muscles grouped into muscle groups: Chest, Back, Shoulders, Arms, Core, Legs
- Muscle display: User preference toggle — simple names vs anatomical names
- Exercise categories: By muscle group (primary organization)
- Filtering: By Push/Pull/Legs AND Compound/Isolation (both available)
- Gym names: Free text name + optional location/address

### Custom Exercise Creation
- Template-based naming: User picks movement type + equipment, name auto-generated
- Movement types: Seeded in DB, user extendable
- Equipment types: Comprehensive list seeded, user can add custom

### Exercise Picker
- Shows favorites + recent first, then search for others
- Favorites: Explicit star toggle plus auto-suggested from usage history
- User notes: MVP (form tips deferred to future)
- No media/images in MVP

### Empty States
- Workout tab first launch: Setup prompt (create gym + set preferences)
- Dashboard empty: Placeholder chart structure with "No data yet" message
- Exercise library: Categories first (muscle groups), user drills down

### Claude's Discretion
- Exact layout spacing and typography
- Loading skeleton designs
- Error state handling
- Navigation transition animations

</decisions>

<specifics>
## Specific Ideas

- Exercise hierarchy enables future templates that reference Movement level, with specifics chosen at workout time based on available equipment
- "Reset to defaults" option when user edits built-in exercise muscle weights
- Built-in exercises marked as such, can't be deleted (only hidden)
- Users can freely edit muscle weights on built-in exercises

</specifics>

<deferred>
## Deferred Ideas

- Pre-populated form tips for exercises — future phase
- Exercise images/videos — not in MVP
- iCloud sync — no accounts for now
- Workout templates — future phase (hierarchy supports this)

</deferred>

---

## Data Model Summary

For researcher/planner reference:

**Muscles:** Hard-coded Swift enum (30-40 muscles)
**Muscle Groups:** Hard-coded enum, muscles reference it
**Movements:** Seeded in SQLite, user extendable
**Variants:** Seeded in SQLite, user extendable (muscle weights here)
**Equipment:** Seeded in SQLite, user extendable
**Exercises:** Variant + Equipment + Unilateral flag
**Gyms:** User-created, name + optional location
**Weight History:** Per-gym tracking for each exercise

**Seed Data:**
- Format: Pre-built SQLite database bundled in app
- Loading: On-demand (loaded from bundle when accessed, cached)
- Built-in flag on seeded exercises (can't delete, can hide, can edit weights, can reset)
- No default gyms — user creates during first-launch setup

---

*Phase: 01-foundation*
*Context gathered: 2026-01-26*
