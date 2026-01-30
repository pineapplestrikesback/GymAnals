//
//  SetFormatting.swift
//  GymAnals
//
//  Created on 29/01/2026.
//

import Foundation

/// Shared formatting utilities for workout set values.
/// Extracted from SetRowView so formatting logic is reusable and testable.
enum SetFormatting {

    /// Format weight for display, omitting decimal when whole number.
    static func formatWeight(_ weight: Double) -> String {
        if weight.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", weight)
        }
        return String(format: "%.1f", weight)
    }

    /// Format duration as seconds for text field editing.
    static func formatDurationForEdit(_ seconds: TimeInterval) -> String {
        if seconds == 0 { return "0" }
        return String(format: "%.0f", seconds)
    }

    /// Format duration for display (e.g., "2m30s").
    static func formatDuration(_ seconds: TimeInterval) -> String {
        if seconds == 0 { return "0s" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        if mins > 0 && secs > 0 {
            return "\(mins)m\(secs)s"
        } else if mins > 0 {
            return "\(mins)m"
        }
        return "\(secs)s"
    }

    /// Format distance for display, omitting decimals when whole number.
    static func formatDistance(_ distance: Double) -> String {
        if distance.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", distance)
        }
        return String(format: "%.2f", distance)
    }

    /// Clamp a weight value to valid bounds.
    static func clampWeight(_ value: Double) -> Double {
        max(0, min(AppConstants.SetLimits.maxWeight, value))
    }

    /// Clamp a reps value to valid bounds.
    static func clampReps(_ value: Int) -> Int {
        max(0, min(AppConstants.SetLimits.maxReps, value))
    }

    /// Clamp a duration value to valid bounds.
    static func clampDuration(_ value: Double) -> Double {
        max(0, min(AppConstants.SetLimits.maxDuration, value))
    }

    /// Clamp a distance value to valid bounds.
    static func clampDistance(_ value: Double) -> Double {
        max(0, min(AppConstants.SetLimits.maxDistance, value))
    }
}
