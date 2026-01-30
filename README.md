# GymAnals

A native iOS workout tracker with precise per-muscle volume tracking.

## What It Does

Unlike fitness apps that use crude "primary/secondary" muscle classifications, GymAnals lets you define weighted muscle contributions per exercise (e.g., bench press: chest 1.0, front delt 0.5, triceps 0.3). This enables accurate weekly volume tracking to inform training decisions.

**Key features:**
- 200+ pre-populated exercises with weighted muscle contributions
- 31-muscle taxonomy (granular: anterior/lateral/posterior delt, upper/lower chest, etc.)
- Custom exercise creation with muscle weight editor
- Multiple gym support with gym-specific weight tracking
- Workout logging with fast set entry (planned)
- Volume dashboard by muscle group (planned)

## Tech Stack

- Swift 6 / SwiftUI
- iOS 17+ deployment target
- SwiftData for local persistence
- No external dependencies

## Building

```bash
# Build
xcodebuild -scheme GymAnals -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests
xcodebuild test -scheme GymAnals -destination 'platform=iOS Simulator,name=iPhone 16'
```

Or open `GymAnals.xcodeproj` in Xcode and press Cmd+R.

## Project Structure

```
GymAnals/
├── App/                 # App entry point, constants
├── Features/            # Feature modules (MVVM)
│   ├── ExerciseLibrary/ # Browse, search, create exercises
│   ├── Workout/         # Gym selection, workout logging
│   ├── Dashboard/       # Volume analytics (planned)
│   └── Settings/        # App settings
├── Models/
│   ├── Core/            # SwiftData models
│   └── Enums/           # Muscle, MuscleGroup, ExerciseType, etc.
├── Services/
│   ├── Persistence/     # SwiftData container
│   └── Seed/            # First-launch data seeding
└── Resources/           # Seed data JSON
```

## Development Status

See `.planning/ROADMAP.md` for detailed progress. Current status:
- Phase 1: Foundation ✓
- Phase 2: Exercise Library ✓
- Phase 3: Gyms ✓
- Phase 4: Workout Logging (next)
- Phase 5: Analytics (planned)
