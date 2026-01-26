//
//  DashboardTabView.swift
//  GymAnals
//
//  Created by opera_user on 26/01/2026.
//

import SwiftUI
import SwiftData

struct DashboardTabView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Placeholder for weekly summary chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("This Week")
                            .font(.headline)

                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.secondary.opacity(0.1))
                            .frame(height: 200)
                            .overlay {
                                Text("No data yet")
                                    .foregroundStyle(.secondary)
                            }
                    }
                    .padding(.horizontal)

                    // Navigation buttons placeholder
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        DashboardButton(title: "Exercises", icon: "dumbbell.fill")
                        DashboardButton(title: "Gyms", icon: "building.2.fill")
                        DashboardButton(title: "Muscles", icon: "figure.arms.open")
                        DashboardButton(title: "Progress", icon: "chart.line.uptrend.xyaxis")
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct DashboardButton: View {
    let title: String
    let icon: String

    var body: some View {
        Button(action: {}) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DashboardTabView()
        .modelContainer(PersistenceController.preview)
}
