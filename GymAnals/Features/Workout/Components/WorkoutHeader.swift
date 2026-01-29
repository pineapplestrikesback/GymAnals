//
//  WorkoutHeader.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import Combine
import SwiftUI

/// Sticky header component for active workout view.
/// Displays gym indicator, elapsed duration, total sets completed, and always-visible rest timer.
struct WorkoutHeader: View {
    let startDate: Date
    let totalSets: Int
    let headerTimer: SetTimer?
    let gym: Gym?
    let defaultRestDuration: Double
    let onTimerTap: () -> Void
    let onStartManualTimer: () -> Void

    @State private var elapsedSeconds: Int = 0
    private let updateTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 8) {
            // Gym indicator row
            if let gym = gym {
                HStack(spacing: 6) {
                    Circle()
                        .fill(gym.colorTag.color)
                        .frame(width: 8, height: 8)
                    Text(gym.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }

            HStack {
                // Duration section
                VStack(alignment: .leading, spacing: 2) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formattedDuration)
                        .font(.title3)
                        .monospacedDigit()
                }

                Spacer()

                // Sets section
                VStack(spacing: 2) {
                    Text("Sets")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(totalSets)")
                        .font(.title3)
                }

                Spacer()

                // Timer section (always visible)
                Button {
                    if let timer = headerTimer, !timer.isExpired {
                        onTimerTap()
                    } else {
                        onStartManualTimer()
                    }
                } label: {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Rest")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if let timer = headerTimer, !timer.isExpired {
                            Text(formattedTimerRemaining(timer))
                                .font(.title3)
                                .monospacedDigit()
                                .foregroundStyle(.orange)
                        } else if defaultRestDuration == 0 {
                            Text("Off")
                                .font(.title3)
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        } else {
                            Text("--:--")
                                .font(.title3)
                                .monospacedDigit()
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            .padding(.top, gym == nil ? 8 : 0)
        }
        .background(.regularMaterial)
        .onReceive(updateTimer) { _ in
            updateElapsedTime()
        }
        .onAppear {
            updateElapsedTime()
        }
    }

    /// Formats elapsed duration as H:MM:SS or M:SS
    private var formattedDuration: String {
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    /// Formats timer remaining in M:SS format
    private func formattedTimerRemaining(_ timer: SetTimer) -> String {
        let remaining = timer.remainingSeconds
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func updateElapsedTime() {
        elapsedSeconds = max(0, Int(Date.now.timeIntervalSince(startDate)))
    }
}

#Preview {
    VStack {
        // Preview with no timer, no gym
        WorkoutHeader(
            startDate: Date.now.addingTimeInterval(-3665), // 1 hour, 1 minute, 5 seconds ago
            totalSets: 12,
            headerTimer: nil,
            gym: nil,
            defaultRestDuration: AppConstants.defaultRestDuration,
            onTimerTap: {},
            onStartManualTimer: {}
        )

        // Preview with timer
        WorkoutHeader(
            startDate: Date.now.addingTimeInterval(-125), // 2 minutes, 5 seconds ago
            totalSets: 3,
            headerTimer: SetTimer(setID: UUID(), duration: 90),
            gym: nil,
            defaultRestDuration: AppConstants.defaultRestDuration,
            onTimerTap: {},
            onStartManualTimer: {}
        )
    }
}
