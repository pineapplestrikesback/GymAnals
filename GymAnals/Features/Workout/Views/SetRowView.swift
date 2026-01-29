//
//  SetRowView.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import SwiftUI
import Combine

/// A single set entry row with proportional column layout that adapts to exercise type.
/// Columns rendered depend on the exercise's logFields (e.g., bodyweight shows reps only, duration shows time only).
/// Uses a progress bar below the row for rest timer instead of inline badge.
struct SetRowView: View {
    let setNumber: Int
    let logFields: [LogField]
    @Binding var reps: Int
    @Binding var weight: Double
    @Binding var duration: TimeInterval
    @Binding var distance: Double
    let previousReps: Int?
    let previousWeight: Double?
    let previousDuration: TimeInterval?
    let previousDistance: Double?
    let weightUnit: WeightUnit
    let isConfirmed: Bool
    let onConfirm: () -> Void

    // Timer for progress bar
    let activeTimer: SetTimer?
    let onTimerTap: ((SetTimer) -> Void)?

    @FocusState.Binding var focusedField: SetEntryField?
    let setID: UUID

    // MARK: - Environment

    @Environment(\.colorScheme) private var colorScheme

    // MARK: - State

    @State private var repsText: String = ""
    @State private var weightText: String = ""
    @State private var durationText: String = ""
    @State private var distanceText: String = ""
    @State private var timerProgress: CGFloat = 0
    @State private var showPulse: Bool = false

    private var updateTimer: AnyPublisher<Date, Never> {
        guard activeTimer != nil else { return Empty().eraseToAnyPublisher() }
        return Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .eraseToAnyPublisher()
    }

    // MARK: - Computed Properties

    /// Number of data entry columns (excluding SET, PREVIOUS, checkmark)
    private var dataColumnCount: Int {
        logFields.count
    }

    private var previousText: String {
        var parts: [String] = []

        for field in logFields {
            switch field {
            case .weight:
                if let w = previousWeight {
                    parts.append(SetFormatting.formatWeight(w))
                }
            case .reps:
                if let r = previousReps {
                    parts.append("\(r)")
                }
            case .duration:
                if let d = previousDuration {
                    parts.append(SetFormatting.formatDuration(d))
                }
            case .distance:
                if let d = previousDistance {
                    parts.append(SetFormatting.formatDistance(d))
                }
            }
        }

        if parts.isEmpty { return "-" }
        return parts.joined(separator: " x ")
    }

    // MARK: - Adaptive Colors

    /// Green background for confirmed sets, tuned for visibility in both color schemes.
    private var confirmedBackground: Color {
        colorScheme == .dark
            ? Color.green.opacity(0.25)
            : Color.green.opacity(0.15)
    }

    // MARK: - Column Weights

    /// Proportional column weights for consistent layout
    static let setWeight: CGFloat = 1
    static let previousWeight: CGFloat = 2
    static let dataFieldWeight: CGFloat = 1.5
    static let checkWidth: CGFloat = 40

    var body: some View {
        VStack(spacing: 0) {
            // Main row with proportional columns
            GeometryReader { geo in
                let totalDataWeight = CGFloat(dataColumnCount) * Self.dataFieldWeight
                let totalWeight = Self.setWeight + Self.previousWeight + totalDataWeight
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

                    // Dynamic data columns based on logFields
                    ForEach(logFields, id: \.self) { field in
                        dataField(for: field, unitWidth: unitWidth)
                    }

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
            // Timer progress bar -- overlaid at the bottom, never changes row height
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
                    ? confirmedBackground
                    : Color.clear
        )
        .animation(.easeInOut(duration: 0.3), value: showPulse)
        .animation(.easeInOut(duration: 0.25), value: isConfirmed)
        .onAppear {
            syncTextFromValues()
            updateTimerProgress()
        }
        .onChange(of: reps) { _, newValue in
            repsText = "\(newValue)"
        }
        .onChange(of: weight) { _, newValue in
            // Preserve trailing "." while user is mid-typing a decimal
            if !weightText.hasSuffix(".") {
                weightText = SetFormatting.formatWeight(newValue)
            }
        }
        .onChange(of: duration) { _, newValue in
            durationText = SetFormatting.formatDurationForEdit(newValue)
        }
        .onChange(of: distance) { _, newValue in
            if !distanceText.hasSuffix(".") {
                distanceText = SetFormatting.formatDistance(newValue)
            }
        }
        .onChange(of: focusedField) { oldValue, newValue in
            handleFocusChange(oldValue: oldValue, newValue: newValue)
        }
        .onReceive(updateTimer) { _ in
            updateTimerProgress()
        }
    }

    // MARK: - Dynamic Data Field

    @ViewBuilder
    private func dataField(for field: LogField, unitWidth: CGFloat) -> some View {
        switch field {
        case .weight:
            TextField("", text: $weightText)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .frame(width: min(50, unitWidth * Self.dataFieldWeight - 4))
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .cornerRadius(6)
                .focused($focusedField, equals: .weight(setID: setID))
                .onChange(of: weightText) { _, newValue in
                    if let value = Double(newValue) {
                        weight = SetFormatting.clampWeight(value)
                    }
                }
                .onSubmit {
                    if let value = Double(weightText) {
                        weight = SetFormatting.clampWeight(value)
                    }
                    weightText = SetFormatting.formatWeight(weight)
                }
                .frame(width: unitWidth * Self.dataFieldWeight, alignment: .center)

        case .reps:
            TextField("", text: $repsText)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(width: min(50, unitWidth * Self.dataFieldWeight - 4))
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .cornerRadius(6)
                .focused($focusedField, equals: .reps(setID: setID))
                .onChange(of: repsText) { _, newValue in
                    if let value = Int(newValue) {
                        reps = SetFormatting.clampReps(value)
                    }
                }
                .onSubmit {
                    if let value = Int(repsText) {
                        reps = SetFormatting.clampReps(value)
                    }
                    repsText = "\(reps)"
                }
                .frame(width: unitWidth * Self.dataFieldWeight, alignment: .center)

        case .duration:
            TextField("", text: $durationText)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(width: min(50, unitWidth * Self.dataFieldWeight - 4))
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .cornerRadius(6)
                .focused($focusedField, equals: .duration(setID: setID))
                .onChange(of: durationText) { _, newValue in
                    if let value = Double(newValue) {
                        duration = SetFormatting.clampDuration(value)
                    }
                }
                .onSubmit {
                    if let value = Double(durationText) {
                        duration = SetFormatting.clampDuration(value)
                    }
                    durationText = SetFormatting.formatDurationForEdit(duration)
                }
                .frame(width: unitWidth * Self.dataFieldWeight, alignment: .center)

        case .distance:
            TextField("", text: $distanceText)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .frame(width: min(50, unitWidth * Self.dataFieldWeight - 4))
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .cornerRadius(6)
                .focused($focusedField, equals: .distance(setID: setID))
                .onChange(of: distanceText) { _, newValue in
                    if let value = Double(newValue) {
                        distance = SetFormatting.clampDistance(value)
                    }
                }
                .onSubmit {
                    if let value = Double(distanceText) {
                        distance = SetFormatting.clampDistance(value)
                    }
                    distanceText = SetFormatting.formatDistance(distance)
                }
                .frame(width: unitWidth * Self.dataFieldWeight, alignment: .center)
        }
    }

    // MARK: - Focus Handling

    private func handleFocusChange(oldValue: SetEntryField?, newValue: SetEntryField?) {
        // Weight field gained focus -- clear for fresh input
        if newValue == .weight(setID: setID) {
            weightText = ""
        }
        // Weight field lost focus -- restore formatted value
        if oldValue == .weight(setID: setID) && newValue != .weight(setID: setID) {
            weightText = SetFormatting.formatWeight(weight)
        }
        // Reps field gained focus -- clear for fresh input
        if newValue == .reps(setID: setID) {
            repsText = ""
        }
        // Reps field lost focus -- restore formatted value
        if oldValue == .reps(setID: setID) && newValue != .reps(setID: setID) {
            repsText = "\(reps)"
        }
        // Duration field gained focus -- clear for fresh input
        if newValue == .duration(setID: setID) {
            durationText = ""
        }
        // Duration field lost focus -- restore formatted value
        if oldValue == .duration(setID: setID) && newValue != .duration(setID: setID) {
            durationText = SetFormatting.formatDurationForEdit(duration)
        }
        // Distance field gained focus -- clear for fresh input
        if newValue == .distance(setID: setID) {
            distanceText = ""
        }
        // Distance field lost focus -- restore formatted value
        if oldValue == .distance(setID: setID) && newValue != .distance(setID: setID) {
            distanceText = SetFormatting.formatDistance(distance)
        }
    }

    // MARK: - Timer Progress

    private func updateTimerProgress() {
        if let timer = activeTimer, !timer.isExpired {
            timerProgress = CGFloat(timer.progress)
            showPulse = false
        } else if let timer = activeTimer, timer.isExpired, timerProgress > 0 {
            // Timer just expired -- trigger pulse
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

    // MARK: - Helpers

    private func syncTextFromValues() {
        repsText = "\(reps)"
        weightText = SetFormatting.formatWeight(weight)
        durationText = SetFormatting.formatDurationForEdit(duration)
        distanceText = SetFormatting.formatDistance(distance)
    }
}

#Preview {
    @Previewable @State var reps1 = 8
    @Previewable @State var weight1 = 100.0
    @Previewable @State var duration1: TimeInterval = 0
    @Previewable @State var distance1 = 0.0
    @Previewable @State var reps2 = 10
    @Previewable @State var weight2 = 0.0
    @Previewable @State var duration2: TimeInterval = 0
    @Previewable @State var distance2 = 0.0
    @Previewable @State var reps3 = 0
    @Previewable @State var weight3 = 0.0
    @Previewable @State var duration3: TimeInterval = 60
    @Previewable @State var distance3 = 0.0
    @Previewable @FocusState var focus: SetEntryField?

    let setID1 = UUID()
    let setID2 = UUID()
    let setID3 = UUID()

    VStack(spacing: 0) {
        Text("Weight & Reps").font(.caption).padding(.top, 8)
        SetRowView(
            setNumber: 1,
            logFields: [.weight, .reps],
            reps: $reps1,
            weight: $weight1,
            duration: $duration1,
            distance: $distance1,
            previousReps: 8,
            previousWeight: 95.0,
            previousDuration: nil,
            previousDistance: nil,
            weightUnit: .kilograms,
            isConfirmed: true,
            onConfirm: { print("Toggled set 1") },
            activeTimer: nil,
            onTimerTap: nil,
            focusedField: $focus,
            setID: setID1
        )

        Divider()

        Text("Bodyweight Reps Only").font(.caption).padding(.top, 8)
        SetRowView(
            setNumber: 1,
            logFields: [.reps],
            reps: $reps2,
            weight: $weight2,
            duration: $duration2,
            distance: $distance2,
            previousReps: 12,
            previousWeight: nil,
            previousDuration: nil,
            previousDistance: nil,
            weightUnit: .kilograms,
            isConfirmed: false,
            onConfirm: { print("Toggled set 2") },
            activeTimer: nil,
            onTimerTap: nil,
            focusedField: $focus,
            setID: setID2
        )

        Divider()

        Text("Duration Only").font(.caption).padding(.top, 8)
        SetRowView(
            setNumber: 1,
            logFields: [.duration],
            reps: $reps3,
            weight: $weight3,
            duration: $duration3,
            distance: $distance3,
            previousReps: nil,
            previousWeight: nil,
            previousDuration: 45,
            previousDistance: nil,
            weightUnit: .kilograms,
            isConfirmed: false,
            onConfirm: { print("Toggled set 3") },
            activeTimer: nil,
            onTimerTap: nil,
            focusedField: $focus,
            setID: setID3
        )
    }
    .padding()
}
