//
//  TimerControlsPopover.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import Combine
import SwiftUI

/// Popover view for controlling an active rest timer.
/// Provides skip and extend (+30s, +1m) actions.
struct TimerControlsPopover: View {
    let timer: SetTimer
    let onSkip: () -> Void
    let onExtend30s: () -> Void
    let onExtend1m: () -> Void

    @State private var remainingSeconds: Int = 0
    private let updateTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 16) {
            // Current remaining time display
            Text(formattedRemaining)
                .font(.title)
                .monospacedDigit()
                .frame(maxWidth: .infinity, alignment: .center)

            Divider()

            // Action buttons
            HStack(spacing: 12) {
                // Skip button
                Button {
                    onSkip()
                } label: {
                    Text("Skip")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.red)

                // +30s button
                Button {
                    onExtend30s()
                } label: {
                    Text("+30s")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                // +1m button
                Button {
                    onExtend1m()
                } label: {
                    Text("+1m")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(width: 280)
        .onReceive(updateTimer) { _ in
            remainingSeconds = timer.remainingSeconds
        }
        .onAppear {
            remainingSeconds = timer.remainingSeconds
        }
    }

    private var formattedRemaining: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    TimerControlsPopover(
        timer: SetTimer(setID: UUID(), duration: 90),
        onSkip: { print("Skip") },
        onExtend30s: { print("+30s") },
        onExtend1m: { print("+1m") }
    )
}
