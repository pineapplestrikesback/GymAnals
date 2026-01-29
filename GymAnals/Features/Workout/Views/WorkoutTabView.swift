//
//  WorkoutTabView.swift
//  GymAnals
//
//  Created by opera_user on 26/01/2026.
//

import SwiftUI
import SwiftData

struct WorkoutTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: GymSelectionViewModel?
    @State private var showingGymSelector = false
    @State private var showingGymManagement = false

    // Active workout state
    @State private var activeWorkoutViewModel: ActiveWorkoutViewModel?
    @State private var timerManager = SetTimerManager()
    @State private var showingActiveWorkout = false
    @State private var hasActiveWorkout = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Gym selector header
                    HStack {
                        Spacer()
                        GymSelectorHeader(
                            gym: viewModel?.selectedGym,
                            onTap: { showingGymSelector = true },
                            isDisabled: hasActiveWorkout
                        )
                        Spacer()
                    }
                    .padding(.top, 8)

                    // Start or Resume Workout button
                    Button {
                        startOrResumeWorkout()
                    } label: {
                        Label(
                            hasActiveWorkout ? "Resume Workout" : "Start Workout",
                            systemImage: hasActiveWorkout ? "play.fill" : "plus.circle.fill"
                        )
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(hasActiveWorkout ? Color.green : Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // Placeholder for recent workouts
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Workouts")
                            .font(.headline)
                            .padding(.horizontal)

                        Text("No workouts yet. Start your first workout!")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    }

                    Spacer()
                }
            }
            .navigationTitle("Workout")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if viewModel == nil {
                    viewModel = GymSelectionViewModel(modelContext: modelContext)
                }
                checkForActiveWorkout()
            }
            .onChange(of: showingActiveWorkout) { _, isShowing in
                if !isShowing {
                    // Clean up when returning from active workout
                    activeWorkoutViewModel = nil
                    checkForActiveWorkout()
                }
            }
            .navigationDestination(isPresented: $showingActiveWorkout) {
                if let vm = activeWorkoutViewModel {
                    ActiveWorkoutView(viewModel: vm, timerManager: timerManager)
                }
            }
            .sheet(isPresented: $showingGymSelector) {
                GymSelectorSheet(
                    selectedGym: Binding(
                        get: { viewModel?.selectedGym },
                        set: { viewModel?.selectedGym = $0 }
                    ),
                    onManageGyms: {
                        // Delay to prevent sheet transition conflicts
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showingGymManagement = true
                        }
                    }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingGymManagement) {
                NavigationStack {
                    GymManagementView()
                }
                .presentationDetents([.large])
            }
        }
    }

    // MARK: - Private Methods

    private func checkForActiveWorkout() {
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.isActive == true }
        )
        hasActiveWorkout = (try? modelContext.fetchCount(descriptor)) ?? 0 > 0
    }

    private func startOrResumeWorkout() {
        let vm = ActiveWorkoutViewModel(modelContext: modelContext)
        activeWorkoutViewModel = vm

        if !hasActiveWorkout {
            // Start new workout at selected gym
            vm.startWorkout(at: viewModel?.selectedGym)
        }
        // If resuming, ActiveWorkoutViewModel already loaded the active workout in init

        showingActiveWorkout = true
    }
}

#Preview {
    WorkoutTabView()
        .modelContainer(PersistenceController.preview)
}
