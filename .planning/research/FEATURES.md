# Feature Landscape: iOS Workout Tracker

**Domain:** Native iOS workout tracker with per-muscle volume focus
**Researched:** 2026-01-26
**Confidence:** HIGH (extensive competitor analysis via multiple sources)

## Executive Summary

The iOS workout tracker market is mature and competitive, dominated by Hevy, Strong, JEFIT, Fitbod, and StrengthLog. Table stakes have evolved significantly - users now expect fast logging (under 10 seconds per set), offline functionality, previous lift display, and basic progress tracking. The proposed differentiators (user-defined muscles, weighted set contributions, gym-specific exercise branches) are genuinely novel - no major competitor offers them.

---

## Table Stakes

Features users expect. Missing = product feels incomplete or users leave immediately.

| Feature | Why Expected | Complexity | Dependencies | Notes |
|---------|--------------|------------|--------------|-------|
| **Fast set logging** | Industry standard is 2-3 taps; users abandon slow apps | Medium | Core data model | Hevy/Strong excel here. Must match or exceed. |
| **Previous lift display** | Users need to know what to beat. Universal expectation. | Low | Workout history | Show last workout's sets inline during logging |
| **Exercise library** | 200-400 exercises minimum; users expect common movements | Medium | Database, search | Hevy: 400+, JEFIT: 1,400+. Start with 200-300 core lifts |
| **Custom exercises** | Users have unique movements, machines, cables | Low | Exercise model | Allow custom name, equipment, muscle targets |
| **Workout templates/routines** | Users follow programs (PPL, 5x5, etc.) | Medium | Template system | Reusable workout structures they can modify |
| **Rest timer** | Auto-start after set completion; 30s-5min configurable | Low | Timer service | Notifications, Lock Screen, optional auto-start |
| **Offline functionality** | Gyms have poor connectivity; concrete walls block signal | Medium | Local-first DB | **Critical.** Sync when back online. |
| **Set type tags** | Warm-up, working, failure, drop sets, supersets | Low | Set model | Standard in Hevy/Strong. Expected for serious lifters. |
| **Basic progress charts** | Weight/volume over time per exercise | Medium | Chart library | Line charts showing progression trends |
| **Personal records tracking** | 1RM, rep PRs auto-detected and celebrated | Medium | PR detection logic | Auto-detect when user beats previous best |
| **Data export** | CSV minimum; users own their data | Low | Export service | **Non-negotiable.** Users leave apps that trap data. |
| **Apple Watch basic support** | View current workout, log sets from wrist | High | watchOS app | Hevy/Strong have excellent Watch apps. Expected. |
| **HealthKit sync** | Write workouts to Apple Health | Medium | HealthKit API | Required for iOS fitness ecosystem integration |
| **Body weight tracking** | Log daily/weekly weigh-ins | Low | Measurement model | Simple but expected for physique tracking |
| **Workout history** | Browse past workouts by date | Low | History UI | Calendar or list view of completed sessions |
| **Notes/comments** | Per-workout and per-exercise notes | Low | String field | Context like "shoulder felt off" or "new PR attempt" |

### Table Stakes Summary

Minimum viable product must include: fast logging, previous lift display, 200+ exercise library, custom exercises, templates, rest timer, offline mode, set type tags, basic charts, PR tracking, CSV export, and body weight logging. Apple Watch and HealthKit can be v1.1 but expected within first months.

---

## Differentiators

Features that set the product apart. These are your competitive moat.

| Feature | Value Proposition | Complexity | Dependencies | Notes |
|---------|-------------------|------------|--------------|-------|
| **User-defined muscle taxonomy** | Users define their own muscle categories (not fixed "shoulders" - but "front delt", "lateral delt", "rear delt") | Medium | Custom muscle model | **Core differentiator.** No competitor offers this. Bodybuilders think in specific muscles, not generic categories. |
| **Weighted set contributions per exercise** | Bench press: chest 1.0, front delt 0.5, triceps 0.3. User-configurable ratios. | High | Volume calculation engine | **Core differentiator.** Research supports fractional volume tracking (RP Strength uses similar concepts). Game-changer for volume tracking accuracy. |
| **Per-muscle volume dashboard** | Weekly totals by user-defined muscle, showing sets hitting target zones (MV/MEV/MAV/MRV) | High | Volume aggregation, user targets | **Core differentiator.** Shows "chest: 18 sets this week" with visual indicators if over/under target. |
| **Gym-specific exercise branches** | Same "Lat Pulldown" exercise, different weight tracking for "Home Gym" vs "Commercial Gym 24hr" | Medium | Gym/location model, exercise variants | **Novel.** Different machines have different weight stacks/feel. Users currently hack this with separate exercises. |
| **Freestyle training mode** | "Check volume, decide what to train" - shows current muscle volumes, suggests undertrained areas | Medium | Volume dashboard, suggestion UI | Enables intuitive training for experienced lifters who don't follow rigid programs |
| **Volume-aware workout suggestions** | "Chest is at 14/18 sets. Add 4 more sets?" during workout creation | Medium | Volume tracking + UX | Bridges gap between planned and actual training |
| **Exercise-muscle contribution editor** | Visual UI to adjust how much an exercise hits each muscle | Medium | Contribution model, UI | Power users can fine-tune; defaults work for most |

### Differentiator Validation

The weighted contribution model is supported by research:
- RP Strength advocates fractional volume counting for compound vs isolation movements
- Meta-analyses show multi-joint exercises contribute less to specific muscles than isolation work
- Studies suggest 0.5x ratio for indirect muscle work is reasonable default

No major competitor (Hevy, Strong, JEFIT, Fitbod, StrengthLog) offers:
1. User-defined muscle taxonomy
2. Configurable per-exercise muscle contribution ratios
3. Gym-specific weight tracking

---

## Nice-to-Have Features

Valuable but not critical for MVP or differentiation.

| Feature | Value | Complexity | When to Build | Notes |
|---------|-------|------------|---------------|-------|
| **Progress photos** | Visual transformation tracking | Medium | Post-MVP | Hevy, MacroFactor do this well. Not core to volume tracking. |
| **Body measurements** | Neck, chest, arms, waist circumferences | Low | Post-MVP | 14+ measurements like Hevy. Complements but not core. |
| **Social features** | Share workouts, follow friends | High | v2+ | Hevy's social feed is popular. High effort, unclear ROI for volume-focused users. |
| **Routine sharing** | Export/import workout templates | Medium | v1.5 | Useful for coaches/influencers sharing programs |
| **AI workout suggestions** | Fitbod-style adaptive programming | Very High | v3+ | Major undertaking. Start with volume-based suggestions first. |
| **Plate calculator** | Show which plates to load for target weight | Low | v1.2 | Strong has this. Nice convenience feature. |
| **1RM calculator** | Estimate max from submaximal sets | Low | v1.1 | Standard formulas (Epley, Brzycki). Expected eventually. |
| **RPE/RIR logging** | Rate perceived exertion per set | Low | v1.2 | Serious lifters want this. Low effort to add. |
| **Muscle heat map** | Visual body diagram of trained muscles | Medium | v1.3 | Hevy/Strong have this. Nice visualization. |
| **Workout streaks/gamification** | Achievement badges, consistency tracking | Medium | v2+ | Polarizing - serious lifters often dislike it. |
| **Video exercise demos** | GIFs/videos showing exercise form | High | v2+ | JEFIT excels here. Large content investment. |
| **Siri shortcuts** | Voice commands to start workouts | Medium | v1.5 | iOS 26 supports workout Siri intents |
| **Widgets** | Home screen workout streak, next workout | Medium | v1.3 | WidgetKit integration for glanceability |
| **Live Activities** | Lock screen workout display during session | Medium | v1.2 | Modern iOS expectation for active sessions |

---

## Anti-Features

Features to explicitly NOT build. Common mistakes in this domain.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| **Calorie counting / nutrition tracking** | Scope creep. Different problem space. Users have MyFitnessPal. Apps that try both do neither well. | Integrate with nutrition apps via HealthKit if needed |
| **Rigid algorithm-set targets** | Studies show users hate unattainable app-generated goals. Destroys motivation. "So my fitness pal says I need negative 700 calories." | Let users set their own volume targets. Suggest, don't mandate. |
| **Complex gamification** | "Another achievement badge" is noise for serious lifters. Feels patronizing. | Simple streaks at most. Focus on actual progress (PRs) as the reward. |
| **Mandatory account creation** | Friction before value. Users leave. Privacy concerns. | Local-first. Optional account for backup/sync only. |
| **Social-first feed** | Hevy's social works for them, but it's not your differentiator. Don't copy. | Focus on solo training experience. Add lightweight sharing later. |
| **AI-everything hype** | "AI-powered workout generation" before fundamentals work wastes resources. | Get manual volume tracking perfect first. AI suggestions later. |
| **Workout content library** | Another 500 generic workout programs is commodity. "Content library = ghost town" | Users bring their own programs. Enable, don't prescribe. |
| **Complex onboarding wizard** | 10-screen setup before first workout = abandoned app. | Minimal onboarding. Let users add detail over time. |
| **Notification spam** | "You haven't worked out in 3 days!" is patronizing and drives uninstalls. | Minimal, user-controlled notifications. Respect autonomy. |
| **Premium-only basics** | Putting table stakes behind paywall (limited workouts, no export) feels exploitative. Strong's 3-workout free limit is controversial. | Generous free tier. Premium for advanced analytics/features. |
| **Multi-device instant sync obsession** | Complexity trap. Most users use one device. | Local-first. Manual backup/restore. Sync is nice-to-have, not MVP. |
| **Full HealthKit bidirectional sync** | Reading from Apple Health adds complexity. Workouts from other apps confuse your data model. | Write-only to HealthKit. Your app is source of truth. |

---

## Feature Dependencies

```
Core Foundation (must build first)
├── Data Model (exercises, sets, workouts, muscles)
├── Local persistence (SwiftData/GRDB)
└── Basic CRUD operations

Table Stakes Layer (build second)
├── Exercise Library → depends on Data Model
├── Workout Logging → depends on Exercise Library
├── Templates → depends on Workout structure
├── Rest Timer → standalone utility
├── History View → depends on Workout data
└── Basic Charts → depends on History data

Differentiator Layer (build third - your moat)
├── Custom Muscle Taxonomy → extends Data Model
├── Weighted Contributions → depends on Muscles + Exercises
├── Volume Dashboard → depends on Contributions + History
├── Gym-specific Branches → extends Exercise model
└── Freestyle Mode → depends on Volume Dashboard

Platform Integration Layer (build fourth)
├── HealthKit Sync → depends on completed Workouts
├── Apple Watch → depends on Workout Logging
├── Widgets/Live Activities → depends on active session state
└── Export → depends on all data models
```

### Critical Path

1. **Data Model + Local Persistence** (week 1-2)
2. **Exercise Library + Workout Logging** (week 3-4)
3. **Templates + History + Rest Timer** (week 5-6)
4. **Custom Muscles + Contributions** (week 7-8) - *differentiators start here*
5. **Volume Dashboard + Charts** (week 9-10)
6. **Apple Watch + HealthKit** (week 11-12)

---

## MVP Recommendation

### MVP (v1.0) - "Volume Tracker That Actually Tracks Volume"

**Table Stakes (must ship):**
1. Workout logging with fast set entry
2. Exercise library (250+ exercises)
3. Custom exercises
4. Workout templates
5. Rest timer with auto-start
6. Offline-first with local storage
7. Previous lift display
8. Set type tags (warm-up, working, failure)
9. Basic history view
10. CSV export
11. Body weight logging

**Core Differentiators (must ship - this is why users choose you):**
1. User-defined muscle taxonomy
2. Weighted set contributions per exercise
3. Per-muscle volume dashboard with weekly totals
4. Gym-specific exercise variants

**Defer to v1.1:**
- Apple Watch app
- HealthKit integration
- Progress charts (beyond volume dashboard)
- PR auto-detection with celebration

**Defer to v1.2+:**
- Progress photos
- Body measurements (beyond weight)
- Muscle heat map visualization
- Social/sharing features
- Siri shortcuts

### Pricing Model Recommendation

**Free Tier (generous):**
- Unlimited workouts
- Full exercise library
- All differentiators (volume tracking)
- CSV export
- Basic history

**Premium Tier ($4.99/month or $39.99/year):**
- Advanced analytics (long-term trends)
- Unlimited workout history (free: 6 months)
- Cloud backup/sync
- Apple Watch app
- Multiple gym profiles

---

## Competitive Positioning Matrix

| Capability | Hevy | Strong | JEFIT | Your App |
|------------|------|--------|-------|----------|
| Fast logging | Good | Excellent | Good | Target: Excellent |
| Exercise library | 400+ | 300+ | 1,400+ | 250+ (MVP) |
| Volume tracking | Sets per muscle (fixed) | Basic | Basic | **Weighted contributions (unique)** |
| Muscle taxonomy | Fixed categories | Fixed | Fixed | **User-defined (unique)** |
| Multi-gym support | None | None | None | **Gym-specific branches (unique)** |
| Freestyle training | None | None | None | **Volume-aware (unique)** |
| Social features | Strong | Minimal | Forums | None (intentional) |
| Free tier | Generous | Limited (3) | Ad-supported | Generous |
| Apple Watch | Excellent | Excellent | Good | v1.1 |
| Offline | Yes | Yes | Yes | Yes (critical) |

---

## Sources

### App Reviews and Comparisons
- [Hevy App - Best Workout Tracker](https://www.hevyapp.com/best-workout-tracker-app/)
- [Strong vs Hevy Comparison 2025](https://gymgod.app/blog/strong-vs-hevy)
- [Best Weightlifting Apps 2025](https://just12reps.com/best-weightlifting-apps-of-2025-compare-strong-fitbod-hevy-jefit-just12reps/)
- [Garage Gym Reviews - Best Workout Apps](https://www.garagegymreviews.com/best-workout-apps)
- [Setgraph - Best App to Log Workouts](https://setgraph.app/ai-blog/best-app-to-log-workout-tested-by-lifters)

### Volume Tracking Research
- [RP Strength - Training Volume Landmarks](https://rpstrength.com/blogs/articles/training-volume-landmarks-muscle-growth)
- [PMC - Set-Volume for Limb Muscles](https://pmc.ncbi.nlm.nih.gov/articles/PMC6681288/)
- [Stronger By Science - Training Volume](https://www.strongerbyscience.com/volume/)
- [Hevy - Sets Per Muscle Group](https://www.hevyapp.com/features/sets-per-muscle-group-per-week/)

### User Pain Points
- [7 Things People Hate in Fitness Apps](https://www.ready4s.com/blog/7-things-people-hate-in-fitness-apps)
- [Study on Fitness App Motivation](https://studyfinds.org/fitness-app-motivation-study-myfitnesspal/)
- [Fitness App Development Mistakes](https://www.resourcifi.com/fitness-app-development-mistakes-avoid/)

### Platform Integration
- [Apple Developer - Health and Fitness](https://developer.apple.com/health-fitness/)
- [WWDC25 - Track Workouts with HealthKit](https://developer.apple.com/videos/play/wwdc2025/322/)
- [HealthKit Tutorial](https://gorillalogic.com/apple-watch-healthkit-developer-tutorial-how-to-build-a-workout-app/)

### Feature References
- [Hevy Exercise Library](https://www.hevyapp.com/features/exercise-library/)
- [Hevy Custom Exercises](https://www.hevyapp.com/features/custom-exercises/)
- [Hevy Rest Timer](https://www.hevyapp.com/features/workout-rest-timer/)
- [Hevy Social Features](https://www.hevyapp.com/features/social-features/)
- [MacroFactor Progress Photos](https://macrofactorapp.com/progress-photos-and-body-measurement-tracker/)
