# Coding Conventions

**Analysis Date:** 2026-01-26

## Naming Patterns

**Files:**
- PascalCase for all Swift files (e.g., `GymAnalsApp.swift`, `ContentView.swift`)
- Descriptive names reflecting the primary type or view name
- Structure and class names match file names

**Functions:**
- camelCase for function names
- Test functions use `test` prefix followed by descriptive name (e.g., `testExample()`, `testLaunch()`)

**Variables:**
- camelCase for local variables and properties
- Descriptive names that indicate purpose

**Types:**
- PascalCase for struct, class, and protocol names
- View types end with "View" suffix (e.g., `ContentView`)
- App entry point uses PascalCase with "App" suffix (e.g., `GymAnalsApp`)

## Code Style

**Formatting:**
- Default Xcode formatting with 4-space indentation
- SwiftUI syntax using trailing closures and method chaining

**Linting:**
- No explicit linting configuration detected
- Xcode default Swift compiler warnings and diagnostics

## Import Organization

**Order:**
1. Framework imports at top of file (e.g., `import SwiftUI`, `import XCTest`, `import Testing`)
2. Test-specific imports follow (e.g., `@testable import GymAnals`)

**Path Aliases:**
- Not applicable (Swift imports directly reference framework/module names)

## Error Handling

**Patterns:**
- Explicit error throwing with `throws` keyword for test functions
- Test methods marked `async throws` for async operations
- SetUp/tearDown methods use `throws` for error handling during initialization
- `continueAfterFailure = false` used in UI tests to halt immediately on failure

## Logging

**Framework:** Not detected - standard output not used in current codebase

**Patterns:**
- No logging framework currently implemented
- Minimal logging requirements for initial implementation

## Comments

**When to Comment:**
- File headers included with filename, project name, creator, and date
- Inline comments provided by Xcode templates for guidance (setup/teardown)
- Comments are minimal and template-generated

**JSDoc/TSDoc:**
- Not applicable (Swift uses different documentation approach)
- No documentation comments (///) currently present

## Function Design

**Size:** Small, focused functions (current implementation shows very short functions)

**Parameters:** Minimal parameters; composition through properties and SwiftUI modifiers preferred

**Return Values:** Explicit return types for all functions and computed properties

## Module Design

**Exports:**
- `@main` attribute for app entry point (line 10, `GymAnalsApp.swift`)
- SwiftUI views are struct-based and exported implicitly
- `@testable import` used to access internal app code in tests

**Barrel Files:** Not applicable (Swift doesn't use barrel exports)

## View Structure

**SwiftUI Pattern:**
- Views conform to `View` protocol
- Body property returns `some View` type
- View composition through modifiers and nested views
- `#Preview` macro used for preview compilation (line 22-24, `ContentView.swift`)

## Testing Decorators

**Unit Tests:**
- `@Test` attribute for test functions in newer Testing framework (GymAnalsTests.swift)
- `@testable` import for accessing internal code

**UI Tests:**
- `XCTestCase` subclass pattern for UI tests
- `@MainActor` attribute for main thread execution (lines 25, 34, GymAnalsUITests.swift)
- `setUpWithError()` and `tearDownWithError()` for initialization

---

*Convention analysis: 2026-01-26*
