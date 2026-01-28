//
//  SetTimerBadge.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import SwiftUI
import Combine

/// A countdown badge displaying remaining time for a per-set rest timer.
/// Updates every second using Timer.publish for accurate countdown.
struct SetTimerBadge: View {
    let timer: SetTimer
    let onTap: () -> Void

    @State private var remainingSeconds: Int = 0

    private let updateTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Button {
            onTap()
        } label: {
            Text(formatTime(remainingSeconds))
                .font(.caption.monospacedDigit())
                .foregroundStyle(.orange)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.orange.opacity(0.2), in: Capsule())
        }
        .buttonStyle(.plain)
        .onAppear {
            remainingSeconds = timer.remainingSeconds
        }
        .onReceive(updateTimer) { _ in
            remainingSeconds = timer.remainingSeconds
        }
    }

    // MARK: - Private Methods

    /// Formats seconds as "M:SS" (e.g., "2:00", "1:45", "0:30")
    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

#Preview {
    VStack(spacing: 20) {
        // Active timer
        SetTimerBadge(
            timer: SetTimer(setID: UUID(), duration: 120),
            onTap: { print("Tapped") }
        )

        // Short timer
        SetTimerBadge(
            timer: SetTimer(setID: UUID(), duration: 30),
            onTap: { print("Tapped") }
        )
    }
    .padding()
}
