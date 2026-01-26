//
//  ContentView.swift
//  GymAnals
//
//  Created by opera_user on 26/01/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: Tab = .workout

    var body: some View {
        TabView(selection: $selectedTab) {
            WorkoutTabView()
                .tabItem {
                    Label(Tab.workout.title, systemImage: Tab.workout.icon)
                }
                .tag(Tab.workout)

            DashboardTabView()
                .tabItem {
                    Label(Tab.dashboard.title, systemImage: Tab.dashboard.icon)
                }
                .tag(Tab.dashboard)

            SettingsTabView()
                .tabItem {
                    Label(Tab.settings.title, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(PersistenceController.preview)
}
