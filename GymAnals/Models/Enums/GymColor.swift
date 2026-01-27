//
//  GymColor.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import Foundation
import SwiftUI

/// Predefined color palette for gym tags
/// Used for visual identification of different gyms in the UI
enum GymColor: String, CaseIterable, Codable {
    case red
    case orange
    case yellow
    case green
    case blue
    case purple
    case pink
    case gray

    /// Returns the SwiftUI Color for this gym color
    var color: Color {
        switch self {
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .blue: return .blue
        case .purple: return .purple
        case .pink: return .pink
        case .gray: return .gray
        }
    }
}
