# Technology Stack

**Analysis Date:** 2026-01-26

## Languages

**Primary:**
- Swift 5.0 - Main application language for iOS app

## Runtime

**Environment:**
- iOS 26.2 (deployment target)
- iPad and iPhone (TARGETED_DEVICE_FAMILY = "1,2")

**Build System:**
- Xcode 26.2
- Apple Swift compiler (integrated with Xcode)

## Frameworks

**Core UI:**
- SwiftUI - Declarative UI framework for building user interfaces

**Testing:**
- Testing (Swift Testing framework) - Unit test framework for main app (`GymAnalsTests`)
- XCTest - UI testing framework for app testing (`GymAnalsUITests`)

**Build/Dev:**
- Xcode 26.2 - IDE and build environment

## Key Dependencies

**System Frameworks Only:**
- All functionality uses built-in Apple frameworks (SwiftUI, Testing, XCTest)
- No external third-party dependencies
- No CocoaPods or Swift Package Manager dependencies

## Configuration

**Environment:**
- Bundle Identifier: `jtomasz.GymAnals`
- IPHONEOS_DEPLOYMENT_TARGET: 26.2
- SWIFT_VERSION: 5.0
- LOCALIZATION_PREFERS_STRING_CATALOGS: YES
- Approachable concurrency: YES (SWIFT_APPROACHABLE_CONCURRENCY enabled)

**Build:**
- Project configuration file: `/Users/opera_user/repo/GymAnals/GymAnals.xcodeproj/project.pbxproj`
- No external build configuration files (no .xcconfig files detected)

## Platform Requirements

**Development:**
- Xcode 26.2 or later
- Swift 5.0 compatible compiler
- macOS development machine

**Production:**
- iOS 26.2 or later
- iPad or iPhone device

---

*Stack analysis: 2026-01-26*
