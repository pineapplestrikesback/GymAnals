# Requirements: GymAnals

**Defined:** 2026-01-26
**Core Value:** Precise per-muscle volume tracking with weighted set contributions

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Exercise Library & Muscles

- [ ] **EXER-01**: Pre-populated exercise library with 200+ common exercises
- [ ] **EXER-02**: User can create custom exercises
- [ ] **EXER-03**: Pre-defined comprehensive muscle taxonomy (granular: anterior/lateral/posterior delt, upper/lower chest, etc.)
- [ ] **EXER-04**: Each exercise has weighted muscle contributions (e.g., bench: chest 1.0, front delt 0.5, triceps 0.3)
- [ ] **EXER-05**: User can search and filter exercises

### Gyms

- [ ] **GYM-01**: User can define gyms they train at
- [ ] **GYM-02**: User can create gym-specific exercise branches (same exercise, different weight tracking per gym)

### Workout Logging

- [ ] **LOG-01**: User can start a workout (optionally at a specific gym)
- [ ] **LOG-02**: User can add exercises to active workout
- [ ] **LOG-03**: User can log sets with reps and weight
- [ ] **LOG-04**: User can see previous workout's numbers for each exercise
- [ ] **LOG-05**: User can edit/delete sets during active workout
- [ ] **LOG-06**: Rest timer between sets with notification
- [ ] **LOG-07**: User can finish and save workout
- [ ] **LOG-08**: Auto-save during workout (crash recovery)

### Analytics

- [ ] **ANAL-01**: Volume dashboard showing weekly sets per muscle (calculated from weighted contributions)
- [ ] **ANAL-02**: User can view workout history (browse past workouts by date)

### Data

- [ ] **DATA-01**: App works fully offline (SwiftData local persistence)

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Progress Tracking

- **PROG-01**: Exercise progress charts (weight/reps over time)
- **PROG-02**: PR tracking and notifications

### Templates

- **TMPL-01**: Save workout as template
- **TMPL-02**: Start workout from template
- **TMPL-03**: Copy previous workout

### Data & Sync

- **SYNC-01**: CSV export for backup/analysis
- **SYNC-02**: iCloud sync between devices

### Platform Integration

- **WATCH-01**: watchOS companion app
- **WATCH-02**: Log sets from watch
- **WATCH-03**: Rest timer with haptics on watch
- **HLTH-01**: HealthKit workout integration

### Advanced Analytics

- **ADVN-01**: Muscle balance analysis (compare related muscle groups)

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Calorie/nutrition tracking | Different domain, scope creep |
| Social features | Personal tool, not social network |
| Algorithm-driven workout suggestions | Research shows this kills motivation |
| Mandatory account/login | Local-first app, no server dependency |
| Video exercise demos | Storage/bandwidth, use external resources |
| Gamification/achievements | Serious lifters find this annoying per research |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| DATA-01 | Phase 1 | Pending |
| EXER-01 | Phase 2 | Pending |
| EXER-02 | Phase 2 | Pending |
| EXER-03 | Phase 2 | Pending |
| EXER-04 | Phase 2 | Pending |
| EXER-05 | Phase 2 | Pending |
| GYM-01 | Phase 3 | Pending |
| GYM-02 | Phase 3 | Pending |
| LOG-01 | Phase 4 | Pending |
| LOG-02 | Phase 4 | Pending |
| LOG-03 | Phase 4 | Pending |
| LOG-04 | Phase 4 | Pending |
| LOG-05 | Phase 4 | Pending |
| LOG-06 | Phase 4 | Pending |
| LOG-07 | Phase 4 | Pending |
| LOG-08 | Phase 4 | Pending |
| ANAL-01 | Phase 5 | Pending |
| ANAL-02 | Phase 5 | Pending |

**Coverage:**
- v1 requirements: 18 total
- Mapped to phases: 18
- Unmapped: 0

---
*Requirements defined: 2026-01-26*
*Last updated: 2026-01-26 after roadmap creation*
