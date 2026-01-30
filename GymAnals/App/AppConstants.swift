//
//  AppConstants.swift
//  GymAnals
//
//  Created by opera_user on 26/01/2026.
//

import Foundation

enum AppConstants {
    static let appName = "GymAnals"

    // Rest timer defaults
    static let defaultRestDuration: TimeInterval = 120  // 2 minutes

    // Weight increments for stepper controls
    static let weightIncrementKg: Double = 1.0
    static let weightIncrementLbs: Double = 2.5  // Matches standard plate availability

    // Workout set value bounds
    enum SetLimits {
        static let maxWeight: Double = 999
        static let maxReps: Int = 999
        static let maxDuration: TimeInterval = 86400  // 24 hours
        static let maxDistance: Double = 9999
    }
}
