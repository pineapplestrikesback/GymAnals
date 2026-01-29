//
//  TimerControlsSheet.swift
//  GymAnals
//
//  Created on 29/01/2026.
//

import SwiftUI
import Combine

/// Bottom sheet for controlling an active rest timer and editing the global default.
struct TimerControlsSheet: View {
    enum Mode {
        case currentTimer
        case defaultTimer
    }

    let timer: SetTimer
    let onSkip: () -> Void
    let onAdjustTimer: (_ deltaSeconds: Int) -> Void
    let onDismiss: () -> Void

    @State private var mode: Mode = .currentTimer
    @State private var isPickerVisible = false
    @State private var showDisableConfirmation = false
    @State private var pickerMinutes: Int = 0
    @State private var pickerSeconds: Int = 0

    @AppStorage("defaultRestDuration") private var defaultRestDuration: Double = AppConstants.defaultRestDuration
    @State private var draftDefaultSeconds: Int = 0

    @State private var remainingSeconds: Int = 0
    private let updateTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State private var detentSelection: PresentationDetent = .height(170)

    var body: some View {
        VStack(spacing: 12) {
            Button {
                togglePicker()
            } label: {
                Text(formattedTime(displayedSeconds))
                    .font(.title2)
                    .monospacedDigit()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .buttonStyle(.plain)

            if isPickerVisible {
                pickerView
                    .transition(.opacity)
            }

            Divider()

            HStack(spacing: 12) {
                if mode == .currentTimer {
                    Button {
                        onSkip()
                        onDismiss()
                    } label: {
                        Text("Skip")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }

                Button {
                    adjustBy(-15)
                } label: {
                    Text("-15s")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    adjustBy(15)
                } label: {
                    Text("+15s")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            if mode == .currentTimer {
                Button("Edit default") {
                    switchToDefaultMode()
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
            } else {
                Button("Change default") {
                    commitDefaultChange()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 4)
            }
        }
        .padding()
        .presentationDetents([.height(170), .medium], selection: $detentSelection)
        .presentationDragIndicator(.visible)
        .onAppear {
            remainingSeconds = timer.remainingSeconds
            let defaultSeconds = Int(defaultRestDuration)
            draftDefaultSeconds = defaultSeconds
            setPicker(from: displayedSeconds)
        }
        .onReceive(updateTimer) { _ in
            remainingSeconds = timer.remainingSeconds
            if mode == .currentTimer && !isPickerVisible {
                setPicker(from: remainingSeconds)
            }
            stopTimerIfExpired()
        }
        .alert("Do you want to disable the timer?", isPresented: $showDisableConfirmation) {
            Button("Yes") {
                defaultRestDuration = 0
                draftDefaultSeconds = 0
                onDismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Future rest timers will not start automatically.")
        }
    }

    private var displayedSeconds: Int {
        switch mode {
        case .currentTimer:
            return remainingSeconds
        case .defaultTimer:
            return draftDefaultSeconds
        }
    }

    private var pickerView: some View {
        HStack(spacing: 0) {
            Picker("Minutes", selection: $pickerMinutes) {
                ForEach(0..<21, id: \.self) { minute in
                    Text("\(minute)m").tag(minute)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)

            Picker("Seconds", selection: $pickerSeconds) {
                ForEach(Array(stride(from: 0, through: 45, by: 15)), id: \ .self) { second in
                    Text(String(format: "%02ds", second)).tag(second)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .onChange(of: pickerMinutes) { _, _ in
            handlePickerChange()
        }
        .onChange(of: pickerSeconds) { _, _ in
            handlePickerChange()
        }
    }

    private func togglePicker() {
        isPickerVisible.toggle()
        detentSelection = isPickerVisible ? .medium : .height(170)
        setPicker(from: displayedSeconds)
    }

    private func setPicker(from totalSeconds: Int) {
        let clamped = max(0, totalSeconds)
        pickerMinutes = clamped / 60
        pickerSeconds = clamped % 60
    }

    private func handlePickerChange() {
        let totalSeconds = (pickerMinutes * 60) + pickerSeconds
        let clampedSeconds = max(0, totalSeconds)
        setPicker(from: clampedSeconds)
        applyNewValue(clampedSeconds)
    }

    private func adjustBy(_ delta: Int) {
        let newValue = max(0, displayedSeconds + delta)
        setPicker(from: newValue)
        applyNewValue(newValue)
    }

    private func applyNewValue(_ seconds: Int) {
        switch mode {
        case .currentTimer:
            let delta = seconds - remainingSeconds
            if seconds <= 0 {
                onSkip()
                onDismiss()
            } else {
                onAdjustTimer(delta)
            }
        case .defaultTimer:
            draftDefaultSeconds = max(0, seconds)
        }
    }

    private func switchToDefaultMode() {
        mode = .defaultTimer
        isPickerVisible = false
        detentSelection = .height(170)
        draftDefaultSeconds = Int(defaultRestDuration)
        setPicker(from: draftDefaultSeconds)
    }

    private func commitDefaultChange() {
        if draftDefaultSeconds == 0 {
            showDisableConfirmation = true
        } else {
            defaultRestDuration = Double(draftDefaultSeconds)
            onDismiss()
        }
    }

    private func stopTimerIfExpired() {
        if mode == .currentTimer && remainingSeconds <= 0 {
            onSkip()
            onDismiss()
        }
    }

    private func formattedTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    TimerControlsSheet(
        timer: SetTimer(setID: UUID(), duration: 90),
        onSkip: {},
        onAdjustTimer: { _ in },
        onDismiss: {}
    )
}

