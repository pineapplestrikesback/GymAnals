//
//  GymAnalsTests.swift
//  GymAnalsTests
//
//  Created by opera_user on 26/01/2026.
//

import Foundation
import Testing
@testable import GymAnals

struct GymAnalsTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    @Test func setTimerResetCreatesNewEndTime() async throws {
        let timer = SetTimer(setID: UUID(), duration: 90)
        let updated = timer.reset(remainingSeconds: 45)
        #expect(updated.remainingSeconds >= 44)
        #expect(updated.remainingSeconds <= 45)
        #expect(Int(updated.duration) == 45)
    }

    @Test func setTimerAdjustEndTimeMovesRemaining() async throws {
        let timer = SetTimer(setID: UUID(), duration: 90)
        let updated = timer.adjustedEndTime(by: -15)
        #expect(updated.remainingSeconds <= timer.remainingSeconds - 14)
    }

}
