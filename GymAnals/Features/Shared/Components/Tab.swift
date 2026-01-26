//
//  Tab.swift
//  GymAnals
//
//  Created by opera_user on 26/01/2026.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case workout
    case dashboard
    case settings

    var title: String {
        switch self {
        case .workout: return "Workout"
        case .dashboard: return "Dashboard"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .workout: return "figure.strengthtraining.traditional"
        case .dashboard: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }
}
