# Codebase Structure

**Analysis Date:** 2026-01-26

## Directory Layout

```
GymAnals/
├── GymAnals/                           # Main app target
│   ├── GymAnalsApp.swift               # Application entry point
│   ├── ContentView.swift                # Root view
│   └── Assets.xcassets/                 # Application resources
│       ├── AppIcon.appiconset/
│       └── AccentColor.colorset/
├── GymAnalsTests/                      # Unit tests target
│   └── GymAnalsTests.swift              # Test suite
├── GymAnalsUITests/                    # UI tests target
│   ├── GymAnalsUITests.swift            # UI test cases
│   └── GymAnalsUITestsLaunchTests.swift # Launch performance tests
└── GymAnals.xcodeproj/                 # Xcode project file
    ├── project.pbxproj                  # Project configuration
    └── project.xcworkspace/             # Workspace configuration
```

## Directory Purposes

**GymAnals/:**
- Purpose: Main application source code
- Contains: SwiftUI views, app delegate, application logic
- Key files: `GymAnalsApp.swift` (entry point), `ContentView.swift` (root view)

**GymAnals/Assets.xcassets/:**
- Purpose: Application resources and assets
- Contains: Image sets, color sets, app icons
- Key files: `AppIcon.appiconset/` (application icon), `AccentColor.colorset/` (accent color)

**GymAnalsTests/:**
- Purpose: Unit tests and functional tests
- Contains: Test cases for app logic
- Key files: `GymAnalsTests.swift` (test suite using Swift Testing framework)

**GymAnalsUITests/:**
- Purpose: User interface integration and acceptance tests
- Contains: UI test cases using XCTest
- Key files: `GymAnalsUITests.swift` (UI interactions), `GymAnalsUITestsLaunchTests.swift` (launch performance)

**GymAnals.xcodeproj/:**
- Purpose: Xcode project configuration
- Contains: Project settings, build targets, scheme definitions
- Key files: `project.pbxproj` (project file), `project.xcworkspace/` (workspace)

## Key File Locations

**Entry Points:**
- `GymAnals/GymAnalsApp.swift`: @main App struct that initializes the application and creates the main window

**UI Views:**
- `GymAnals/ContentView.swift`: Root view displayed when app launches

**Resources:**
- `GymAnals/Assets.xcassets/`: All image assets, colors, and icons

**Test Files:**
- `GymAnalsTests/GymAnalsTests.swift`: Unit tests (Swift Testing framework)
- `GymAnalsUITests/GymAnalsUITests.swift`: UI tests (XCTest)
- `GymAnalsUITests/GymAnalsUITestsLaunchTests.swift`: Launch performance tests

## Naming Conventions

**Files:**
- App entry point: `[AppName]App.swift` (e.g., `GymAnalsApp.swift`)
- View files: `[ViewName]View.swift` (e.g., `ContentView.swift`)
- Test files: `[TargetName]Tests.swift` (e.g., `GymAnalsTests.swift`)
- UI test files: `[TargetName]UITests.swift` (e.g., `GymAnalsUITests.swift`)

**Swift Identifiers:**
- Structs: PascalCase (e.g., `ContentView`, `GymAnalsApp`)
- Properties: camelCase (e.g., `body`)
- Functions: camelCase (e.g., `setUpWithError()`)

**Directories:**
- Target groups: `[TargetName]/` (e.g., `GymAnals/`, `GymAnalsTests/`)
- Asset catalogs: `.xcassets` suffix (e.g., `Assets.xcassets/`)
- Xcode projects: `.xcodeproj` suffix (e.g., `GymAnals.xcodeproj/`)

## Where to Add New Code

**New SwiftUI View:**
- Location: `GymAnals/` directory
- File pattern: `[ViewName]View.swift`
- Import: `import SwiftUI`
- Structure: Create struct conforming to `View` protocol with `var body: some View`

**New View Model:**
- Location: `GymAnals/` directory
- File pattern: `[ModelName]ViewModel.swift`
- Pattern: Use `@Observable` macro or `ObservableObject` for state management

**New Test:**
- Unit Test: `GymAnalsTests/GymAnalsTests.swift`
  - Use `@Test` macro (Swift Testing framework)
  - Use `@testable import GymAnals` to access internal APIs
- UI Test: `GymAnalsUITests/GymAnalsUITests.swift`
  - Use `XCTestCase` subclass
  - Use XCUIApplication and XCUIElement for interaction

**New Asset:**
- Location: `GymAnals/Assets.xcassets/`
- Add via Xcode Asset Catalog interface
- Reference in code: `Image("assetName")`

## Special Directories

**Assets.xcassets/:**
- Purpose: Central repository for app resources
- Generated: No, manually managed via Xcode
- Committed: Yes

**GymAnals.xcodeproj/:**
- Purpose: Xcode project metadata and configuration
- Generated: Partially (xcuserdata is generated)
- Committed: Yes (except xcuserdata and DerivedData)

**GymAnals.xcodeproj/project.xcworkspace/:**
- Purpose: Workspace configuration
- Generated: By Xcode
- Committed: xcshareddata only (xcuserdata excluded)

---

*Structure analysis: 2026-01-26*
