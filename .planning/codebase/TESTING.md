# Testing Patterns

**Analysis Date:** 2026-01-26

## Test Framework

**Runner:**
- XCTest framework for UI tests (imported in `GymAnalsUITests/GymAnalsUITests.swift` and `GymAnalsUITests/GymAnalsUITestsLaunchTests.swift`)
- Swift Testing framework for unit tests (imported in `GymAnalsTests/GymAnalsTests.swift` - newer Apple testing approach)
- Config: Xcode project configuration in `GymAnals.xcodeproj/project.pbxproj`

**Assertion Library:**
- `XCTAssert` family for XCTest assertions
- `#expect()` macro for Swift Testing assertions

**Run Commands:**
```bash
xcodebuild test -scheme GymAnals -destination 'generic/platform=iOS'      # Run all tests
xcodebuild test -scheme GymAnals -enableCodeCoverage YES                  # Test with coverage
```

## Test File Organization

**Location:**
- Separate targets: `GymAnalsTests` for unit tests, `GymAnalsUITests` for UI tests
- Files located in separate directories: `/GymAnalsTests/` and `/GymAnalsUITests/`

**Naming:**
- Test files: `GymAnalsTests.swift` for unit tests
- UI test files: `GymAnalsUITests.swift` and `GymAnalsUITestsLaunchTests.swift`
- Pattern: AppName + "Tests" suffix

**Structure:**
```
GymAnalsTests/
├── GymAnalsTests.swift                    # Unit tests (Swift Testing)

GymAnalsUITests/
├── GymAnalsUITests.swift                  # Main UI tests (XCTest)
└── GymAnalsUITestsLaunchTests.swift       # Launch performance tests (XCTest)
```

## Test Structure

**Unit Test Suite (Swift Testing Framework):**
```swift
struct GymAnalsTests {
    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
}
```
Location: `GymAnalsTests/GymAnalsTests.swift` (lines 11-17)

**UI Test Suite (XCTest Framework):**
```swift
final class GymAnalsUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Cleanup after tests
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
        // Use XCTAssert and related functions to verify results
    }
}
```
Location: `GymAnalsUITests/GymAnalsUITests.swift` (lines 10-42)

**Patterns:**
- Setup: `setUpWithError()` called before each test method (line 12)
- Teardown: `tearDownWithError()` called after each test method (line 21)
- Assertion pattern: `XCTAssert` variants for UI test validation
- Main thread annotation: `@MainActor` for UI operations (line 25, 34)
- Async support: `async throws` for asynchronous test execution

## Mocking

**Framework:** Not currently used - no mocking framework detected

**Patterns:**
- Direct app testing without mocks (XCUIApplication used for actual app interaction)
- `@testable import GymAnals` provides internal access for testing

**What to Mock:**
- External API calls (when added)
- Network requests
- Database operations

**What NOT to Mock:**
- SwiftUI views (use live previews or direct testing)
- Core app logic (test integration)
- UI interactions (use XCTest UI automation)

## Fixtures and Factories

**Test Data:**
- No fixtures currently implemented
- Template-generated empty test methods serve as placeholders

**Location:**
- Would be created within test target as needed
- Could be placed in shared fixtures directory within test target

## Coverage

**Requirements:** Not enforced - no coverage configuration detected

**View Coverage:**
```bash
xcodebuild test -scheme GymAnals -enableCodeCoverage YES -destination 'generic/platform=iOS'
# Open derived data to inspect coverage reports
```

## Test Types

**Unit Tests:**
- Location: `GymAnalsTests/GymAnalsTests.swift`
- Framework: Swift Testing (newer framework using `@Test` macro)
- Scope: App logic testing independent of UI
- Approach: Direct struct testing, async/await support

**UI Tests:**
- Location: `GymAnalsUITests/GymAnalsUITests.swift` and `GymAnalsUITestsLaunchTests.swift`
- Framework: XCTest with XCUITest for user interaction simulation
- Scope: UI workflow validation, user interaction testing
- Approach: Launch app, interact with UI elements, verify state

**E2E Tests:**
- Covered by UI tests launching full application
- Launch performance testing included (line 35-40, `GymAnalsUITests.swift`)

## Common Patterns

**Async Testing:**
```swift
@Test func example() async throws {
    // Async test using Swift Testing framework
}
```
Location: `GymAnalsTests/GymAnalsTests.swift` (line 13)

**UI Test Launch:**
```swift
@MainActor
func testExample() throws {
    let app = XCUIApplication()
    app.launch()
    // Perform UI interactions and assertions
}
```
Location: `GymAnalsUITests/GymAnalsUITests.swift` (lines 25-32)

**Performance Measurement:**
```swift
@MainActor
func testLaunchPerformance() throws {
    measure(metrics: [XCTApplicationLaunchMetric()]) {
        XCUIApplication().launch()
    }
}
```
Location: `GymAnalsUITests/GymAnalsUITests.swift` (lines 35-40)

**Launch Screenshot Capture:**
```swift
@MainActor
func testLaunch() throws {
    let app = XCUIApplication()
    app.launch()

    let attachment = XCTAttachment(screenshot: app.screenshot())
    attachment.name = "Launch Screen"
    attachment.lifetime = .keepAlways
    add(attachment)
}
```
Location: `GymAnalsUITests/GymAnalsUITestsLaunchTests.swift` (lines 21-32)

---

*Testing analysis: 2026-01-26*
