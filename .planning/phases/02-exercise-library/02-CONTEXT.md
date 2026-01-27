# Phase 2: Exercise Library - Context

**Gathered:** 2026-01-27
**Status:** Ready for planning

<domain>
## Phase Boundary

Users can browse, search, and create exercises with weighted muscle contributions. This phase delivers the exercise library UI, search/filter functionality, custom exercise creation wizard, and muscle weight editing interface. Gym-specific exercise branches are Phase 3. Workout logging is Phase 4.

</domain>

<decisions>
## Implementation Decisions

### Exercise Hierarchy

- **Movement** (e.g., "Press", "Row") → **Variation(s)** (e.g., "Incline", "Wide grip") → **Equipment** (e.g., "Barbell", "Cable") → **Gym branch** (Phase 3)
- Muscle weights attach at **Movement + Variation + Equipment** level
- Both variations and equipment are **multi-select** (e.g., "Incline + Wide grip" or "Cable + Rope")
- Pre-assembled popular combinations ship with curated muscle weights
- Custom combinations get auto-populated defaults + inline warning that weights aren't curated
- User can always edit muscle weights

### Exercise Types (Hevy Model)

Each exercise has a type that determines logging fields:
1. **Weight & Reps** — Bench Press, Curls → Reps + KG
2. **Bodyweight Reps** — Pullups, Situps → Reps only
3. **Weighted Bodyweight** — Weighted Pullups → Reps + (+KG)
4. **Assisted Bodyweight** — Assisted Pullups → Reps + (-KG)
5. **Duration** — Planks, Yoga → Timer
6. **Duration & Weight** — Weighted Plank → KG + Time
7. **Distance & Duration** — Running, Cycling → Time + KM
8. **Weight & Distance** — Farmers Walk → KG + KM

- Pre-populated exercises have **locked** exercise type
- New custom movements default to **Weight & Reps**

### Browse Experience

- Exercises grouped by **broad muscle categories** (6-8 groups: Chest, Back, Shoulders, Arms, Legs, Core)
- List shows **name only** — tap for details
- Custom exercises have **subtle badge** to distinguish from pre-populated

### Add Exercise UI Flow

1. **Search box** at top with "+" button to create new
2. **Muscle group filter tabs** below (6-8 broad groups)
3. **No tab selected = show all** exercises
4. **Top section:** Starred first, then recent (fill to 8-10 total)
   - Starred exercises are **global** (not per-gym)
   - Recent = recently **logged** exercises
   - Section filters when muscle group selected
5. **Below:** All matching exercises, alphabetically sorted
6. **Search behavior:**
   - Debounced 300ms
   - Matches name + muscles (typing "tricep" finds exercises targeting triceps)
   - **AND logic** with muscle filter (search "press" + Back tab = only presses targeting back)
   - Empty results → two buttons: "Search in All" + "Add new exercise"
   - No text highlighting in results
7. **Haptic + visual feedback** on tab tap

### Custom Exercise Creation

- **Guided wizard** with progress dots: Movement → Variation(s) → Equipment → Exercise Type → Muscle Weights
- User **can create new movements** (name only required initially)
- Variations: **pre-defined suggestions + custom** option
- No summary step — flows directly to muscle weights screen
- **Archive by default**, delete only if exercise was never used

### Muscle Contribution UI

**Two-tab interface:**
- Tabs at top: "3D Model" | "List"
- Default to **3D Model** tab

**3D Model Tab:**
- Rotatable, zoomable via gestures
- **Grouped regions** (tap region → modal opens)
- Color gradient reflects weights in **real-time**
- When exercise has pre-configured weights, starts **zoomed to relevant area**
- Adapts to **dark/light mode**

**Muscle Group Modal (from 3D tap):**
- **Mini 3D** (view only, real-time color updates) + sliders below
- "**Set all in group**" button at top
- Dismiss → back to main 3D view

**List Tab:**
- **Top section:** Muscles already assigned (if any) — editable here
- **Below:** Collapsible muscle groups (Back, Shoulders, etc.)
- Expand group → individual muscles with sliders
- Muscles with weights appear in **both places** (top + within group), values synced

**Slider Behavior:**
- Hybrid: slider with **snap points**
- **0.05 increments** (21 levels: 0, 0.05, 0.10... 1.0)
- **Floating value** appears above thumb while dragging
- **Light haptic** at each snap point

**Editing:**
- **Edit button required** (not always editable)
- **Confirm on exit** (auto-save with confirmation if changes made)
- **Undo options:** "Undo last" | "Undo all this session" | "Reset to default" (last only for pre-configured)

**Copy Weights:**
- "Copy from..." opens exercise picker
- Top section shows **"most similar"** (same movement + similar muscles)
- **Preview + adjust** before applying copied weights

**Validation:**
- **Warning** if all muscles at 0, but allow saving
- Inline note for uncurated combinations

### JSON Schema (For Independent Research)

Format for exercise data population:
```json
{
  "movements": {
    "press": {
      "default_weights": {"chest_upper": 0.5, "chest_lower": 0.5, "triceps": 0.4, "front_delt": 0.3}
    }
  },
  "exercises": {
    "incline_press_barbell": {
      "movement": "press",
      "variations": ["incline"],
      "equipment": ["barbell"],
      "type": "weight_reps",
      "muscle_weights": {"chest_upper": 0.9, "chest_lower": 0.3, "triceps": 0.4, "front_delt": 0.5}
    }
  }
}
```
- Object with muscle keys: `{"chest_upper": 0.8, "triceps": 0.4}`
- Two-level hierarchy: movement defaults + exercise-level weights
- User can edit/specify/ignore at both levels

### Claude's Discretion

- Exact spacing and typography
- Loading skeleton design
- Error state handling
- 3D model implementation details (SceneKit vs RealityKit)
- Exact similarity algorithm for "most similar" exercises
- Default muscle weights for new movements

</decisions>

<specifics>
## Specific Ideas

- Exercise types copied from **Hevy** app's proven model
- "Most similar" for copy uses **movement + muscles** algorithm (prioritize same movement, then overlapping muscles)
- 3D model should feel **interactive and premium** — smooth rotation, responsive color updates
- Starred exercises persist **globally** across all gyms

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 02-exercise-library*
*Context gathered: 2026-01-27*
