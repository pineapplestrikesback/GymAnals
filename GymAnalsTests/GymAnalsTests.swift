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
        #expect(updated.remainingSeconds >= timer.remainingSeconds - 16)
        #expect(updated.remainingSeconds <= timer.remainingSeconds - 14)
    }

    @MainActor
    @Test func setTimerManagerUpdatesRemainingSeconds() async throws {
        let timerLong = SetTimer(setID: UUID(), duration: 100)
        let timerShort = SetTimer(setID: UUID(), duration: 10)
        let manager = SetTimerManager()
        manager.activeTimers = [timerLong, timerShort]

        let updated = manager.updateTimer(timerShort, remainingSeconds: 5)

        #expect(updated == true)
        let updatedTimer = manager.activeTimers.first(where: { $0.id == timerShort.id })
        #expect(updatedTimer != nil)
        #expect(updatedTimer!.remainingSeconds >= 4)
        #expect(updatedTimer!.remainingSeconds <= 5)
    }

    @MainActor
    @Test func setTimerManagerSkipsTimerWhenRemainingIsZero() async throws {
        let timer = SetTimer(setID: UUID(), duration: 10)
        let manager = SetTimerManager()
        manager.activeTimers = [timer]

        let updated = manager.updateTimer(timer, remainingSeconds: 0)

        #expect(updated == false)
        #expect(manager.activeTimers.isEmpty == true)
    }

}
