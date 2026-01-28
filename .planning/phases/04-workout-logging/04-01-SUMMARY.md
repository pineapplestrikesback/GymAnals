---
phase: 04
plan: 01
subsystem: workout-logging
tags: [timer, notification, swiftdata, background-persistence]
requires:
  - phases: [01, 02, 03]
provides:
  - SetTimer struct with Date-based endTime for background persistence
  - SetTimerManager for managing multiple independent per-set timers
  - RestTimerNotificationService for local notification scheduling
  - Per-exercise rest duration and auto-start timer settings
affects:
  - 04-02 through 04-05 (workout UI will consume timer infrastructure)
tech-stack:
  added: [UserNotifications]
  patterns: [Date-based timer persistence, singleton notification service]
key-files:
  created:
    - GymAnals/Features/Workout/Models/SetTimer.swift
    - GymAnals/Features/Workout/ViewModels/SetTimerManager.swift
    - GymAnals/Services/Notifications/RestTimerNotificationService.swift
  modified:
    - GymAnals/App/AppConstants.swift
    - GymAnals/Models/Core/Exercise.swift
decisions:
  - Timer endTime stored as Date for background persistence (iOS suspends timers)
  - Only header timer (most recent) triggers notifications to avoid notification spam
  - 2.5 lbs weight increment matches standard plate availability (research-backed)
metrics:
  duration: 6 min
  completed: 2026-01-28
---

# Phase 4 Plan 01: Timer Infrastructure Summary

Timer infrastructure for per-set rest timers with Date-based background persistence and local notification scheduling.

## What Was Built

### SetTimer Struct
Lightweight value type storing timer state:
- `endTime: Date` - Survives app backgrounding (iOS suspends countdown timers)
- `remainingSeconds: Int` - Computed from endTime vs Date.now
- `isExpired: Bool` - Computed for cleanup
- `extended(by:)` - Returns new timer with extended end time

### SetTimerManager
Observable manager for multiple independent timers:
- `activeTimers: [SetTimer]` - All running per-set timers
- `headerTimer: SetTimer?` - Most recent timer (highest endTime), shown in UI header
- `startTimer(for:duration:)` - Creates timer, schedules notification for header only
- `skipTimer(_:)` - Removes timer, cancels notification if it was header
- `extendTimer(_:by:)` - Extends existing timer
- `removeExpiredTimers()` - Cleanup on foreground return

### RestTimerNotificationService
Singleton handling local notifications:
- `requestPermission()` - Async authorization request
- `scheduleRestTimerNotification(id:after:)` - Time-interval triggered notification
- `cancelNotification(id:)` - Cancel specific notification
- `cancelAllRestTimerNotifications()` - Bulk cancel

### Model Updates
- `Exercise.restDuration: TimeInterval = 120` - Per-exercise rest time
- `Exercise.autoStartTimer: Bool = true` - Auto-start on set completion
- `AppConstants.defaultRestDuration = 120` (2 minutes)
- `AppConstants.weightIncrementKg = 1.0`
- `AppConstants.weightIncrementLbs = 2.5` (matches standard plates)

## Key Implementation Decisions

1. **Date-based endTime over countdown seconds**: iOS suspends timers when app is backgrounded. Storing end time as Date means `remainingSeconds` is always accurate on foreground return.

2. **Header timer concept**: Only the most recent timer (highest endTime) triggers notifications. Prevents notification spam during supersets with multiple running timers.

3. **Lightweight struct over SwiftData model**: SetTimer doesn't need persistence across app restarts - timers reset on app termination is acceptable UX per research.

4. **2.5 lbs increment**: Research indicates 1.25 lbs plates are rare in gyms. Standard smallest plates are 2.5 lbs.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Fixed untracked ActiveWorkoutViewModel.swift**
- **Found during:** Final verification
- **Issue:** Pre-existing untracked file missing `import SwiftUI` causing build failure
- **Fix:** Added missing import statement
- **Files modified:** GymAnals/Features/Workout/ViewModels/ActiveWorkoutViewModel.swift
- **Commit:** Included in prior 04-02 commit (file was previously committed separately)

## Commits

| Hash | Type | Description |
|------|------|-------------|
| ce63fc2 | feat | Timer infrastructure and notification service |
| a78743e | feat | Rest timer constants and per-exercise settings |

## Verification Results

- Build succeeds with all timer infrastructure
- SetTimer.endTime is Date type (background persistence)
- SetTimerManager calls notificationService.schedule on timer start
- SetTimerManager calls notificationService.cancel on timer skip
- Exercise.restDuration defaults to 120

## Next Phase Readiness

Ready for 04-02 (Workout Session UI):
- Timer infrastructure ready for UI consumption
- SetTimerManager can be injected into workout views
- Per-exercise rest duration available from Exercise model

---

*Completed: 2026-01-28*
*Duration: 6 minutes*
