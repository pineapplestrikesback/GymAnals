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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Gym selector header
                    HStack {
                        Spacer()
                        GymSelectorHeader(gym: viewModel?.selectedGym) {
                            showingGymSelector = true
                        }
                        Spacer()
                    }
                    .padding(.top, 8)

                    // Placeholder for "Start Workout" button
                    Button(action: {}) {
                        Label("Start Workout", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
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
            }
            .sheet(isPresented: $showingGymSelector) {
                GymSelectorSheet(
                    selectedGym: Binding(
                        get: { viewModel?.selectedGym },
                        set: { viewModel?.selectedGym = $0 }
                    ),
                    onManageGyms: {
                        showingGymManagement = true
                    }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
    }
}

#Preview {
    WorkoutTabView()
        .modelContainer(PersistenceController.preview)
}
