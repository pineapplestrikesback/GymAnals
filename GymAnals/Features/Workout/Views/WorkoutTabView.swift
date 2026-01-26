//
//  WorkoutTabView.swift
//  GymAnals
//
//  Created by opera_user on 26/01/2026.
//

import SwiftUI

struct WorkoutTabView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
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
                    .padding(.top)

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
        }
    }
}

#Preview {
    WorkoutTabView()
}
