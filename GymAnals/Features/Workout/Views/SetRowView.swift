//
//  SetRowView.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import SwiftUI
import Combine

/// A single set entry row with proportional column layout: SET | PREVIOUS | WEIGHT | REPS | checkmark.
/// Uses a progress bar below the row for rest timer instead of inline badge.
struct SetRowView: View {
    let setNumber: Int
    @Binding var reps: Int
    @Binding var weight: Double
    let previousReps: Int?
    let previousWeight: Double?
    let weightUnit: WeightUnit
    let isConfirmed: Bool
    let onConfirm: () -> Void

    // Timer for progress bar
    let activeTimer: SetTimer?
    let onTimerTap: ((SetTimer) -> Void)?

    @FocusState.Binding var focusedField: SetEntryField?
    let setID: UUID

    // MARK: - State

    @State private var repsText: String = ""
    @State private var weightText: String = ""
    @State private var timerProgress: CGFloat = 0
    @State private var showPulse: Bool = false

    private var updateTimer: AnyPublisher<Date, Never> {
        guard activeTimer != nil else { return Empty().eraseToAnyPublisher() }
        return Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .eraseToAnyPublisher()
    }

    // MARK: - Computed Properties

    private var previousText: String {
        if let w = previousWeight, let r = previousReps {
            return "\(formatWeight(w)) x \(r)"
        } else if let w = previousWeight {
            return "\(formatWeight(w))"
        } else if let r = previousReps {
            return "\(r) reps"
        }
        return "-"
    }

    // MARK: - Column Weights

    /// Proportional column weights for consistent layout
    static let setWeight: CGFloat = 1
    static let previousWeight: CGFloat = 2
    static let kgWeight: CGFloat = 1.5
    static let repsWeight: CGFloat = 1.5
    static let checkWidth: CGFloat = 40

    var body: some View {
        VStack(spacing: 0) {
            // Main row with proportional columns
            GeometryReader { geo in
                let totalWeight = Self.setWeight + Self.previousWeight + Self.kgWeight + Self.repsWeight
                let availableWidth = geo.size.width - Self.checkWidth
                let unitWidth = availableWidth / totalWeight

                HStack(spacing: 0) {
                    // SET column
                    Text("\(setNumber)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .frame(width: unitWidth * Self.setWeight, alignment: .center)

                    // PREVIOUS column
                    Text(previousText)
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                        .frame(width: unitWidth * Self.previousWeight, alignment: .center)

                    // WEIGHT column
                    TextField("", text: $weightText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .frame(width: min(50, unitWidth * Self.kgWeight - 4))
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                        .focused($focusedField, equals: .weight(setID: setID))
                        .onChange(of: weightText) { _, newValue in
                            if let value = Double(newValue) {
                                weight = max(0, min(999, value))
                            }
                        }
                        .onSubmit {
                            if let value = Double(weightText) {
                                weight = max(0, min(999, value))
                            }
                            weightText = formatWeight(weight)
                        }
                        .frame(width: unitWidth * Self.kgWeight, alignment: .center)

                    // REPS column
                    TextField("", text: $repsText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(width: min(50, unitWidth * Self.repsWeight - 4))
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                        .focused($focusedField, equals: .reps(setID: setID))
                        .onChange(of: repsText) { _, newValue in
                            if let value = Int(newValue) {
                                reps = max(0, min(999, value))
                            }
                        }
                        .onSubmit {
                            if let value = Int(repsText) {
                                reps = max(0, min(999, value))
                            }
                            repsText = "\(reps)"
                        }
                        .frame(width: unitWidth * Self.repsWeight, alignment: .center)

                    // Confirm checkmark
                    Button {
                        onConfirm()
                    } label: {
                        Image(systemName: isConfirmed ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundStyle(isConfirmed ? .green : .secondary)
                    }
                    .buttonStyle(.plain)
                    .frame(width: Self.checkWidth, alignment: .center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 44)
            .padding(.horizontal, 8)
        }
        .padding(.vertical, 3)
        .overlay(alignment: .bottom) {
            // Timer progress bar — overlaid at the bottom, never changes row height
            if let timer = activeTimer, !timer.isExpired {
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.orange)
                        .frame(width: geo.size.width * timerProgress, height: 2)
                        .animation(.linear(duration: 0.1), value: timerProgress)
                }
                .frame(height: 2)
                .padding(.horizontal, 8)
            }
        }
        .background(
            showPulse
                ? Color.orange.opacity(0.15)
                : isConfirmed
                    ? Color.green.opacity(0.08)
                    : Color.clear
        )
        .animation(.easeInOut(duration: 0.3), value: showPulse)
        .animation(.easeInOut(duration: 0.25), value: isConfirmed)
        .onAppear {
            repsText = "\(reps)"
            weightText = formatWeight(weight)
            updateTimerProgress()
        }
        .onChange(of: reps) { _, newValue in
            repsText = "\(newValue)"
        }
        .onChange(of: weight) { _, newValue in
            // Preserve trailing "." while user is mid-typing a decimal
            if !weightText.hasSuffix(".") {
                weightText = formatWeight(newValue)
            }
        }
        .onReceive(updateTimer) { _ in
            updateTimerProgress()
        }
    }

    // MARK: - Timer Progress

    private func updateTimerProgress() {
        if let timer = activeTimer, !timer.isExpired {
            timerProgress = CGFloat(timer.progress)
            showPulse = false
        } else if let timer = activeTimer, timer.isExpired, timerProgress > 0 {
            // Timer just expired — trigger pulse
            timerProgress = 0
            triggerPulse()
        }
    }

    private func triggerPulse() {
        showPulse = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            showPulse = false
        }
    }

    // MARK: - Helper

    private func formatWeight(_ weight: Double) -> String {
        if weight.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", weight)
        }
        return String(format: "%.1f", weight)
    }
}

#Preview {
    @Previewable @State var reps1 = 8
    @Previewable @State var weight1 = 100.0
    @Previewable @State var reps2 = 10
    @Previewable @State var weight2 = 50.0
    @Previewable @FocusState var focus: SetEntryField?

    let setID1 = UUID()
    let setID2 = UUID()

    VStack(spacing: 0) {
        SetRowView(
            setNumber: 1,
            reps: $reps1,
            weight: $weight1,
            previousReps: 8,
            previousWeight: 95.0,
            weightUnit: .kilograms,
            isConfirmed: true,
            onConfirm: { print("Toggled set 1") },
            activeTimer: SetTimer(setID: setID1, duration: 90),
            onTimerTap: { _ in print("Timer tapped") },
            focusedField: $focus,
            setID: setID1
        )

        Divider()

        SetRowView(
            setNumber: 2,
            reps: $reps2,
            weight: $weight2,
            previousReps: nil,
            previousWeight: nil,
            weightUnit: .pounds,
            isConfirmed: false,
            onConfirm: { print("Toggled set 2") },
            activeTimer: nil,
            onTimerTap: nil,
            focusedField: $focus,
            setID: setID2
        )
    }
    .padding()
}
