//
//  Dimensions.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import Foundation

/// Embedded struct for exercise variation dimensions
/// Uses empty strings instead of nil to avoid SwiftData optional decoding issues
struct Dimensions: Codable, Hashable {
    var angle: String = ""           // flat, incline_15, incline_30, incline_45, decline, etc.
    var gripWidth: String = ""       // narrow, standard, wide
    var gripOrientation: String = "" // pronated, supinated, neutral
    var stance: String = ""          // varies by movement (standing, seated, etc.)
    var laterality: String = ""      // bilateral, unilateral

    /// Check if all dimensions are empty (no variation specified)
    var isEmpty: Bool {
        angle.isEmpty && gripWidth.isEmpty && gripOrientation.isEmpty &&
        stance.isEmpty && laterality.isEmpty
    }

    /// Initialize with optional values (converts nil to empty string)
    init(
        angle: String? = nil,
        gripWidth: String? = nil,
        gripOrientation: String? = nil,
        stance: String? = nil,
        laterality: String? = nil
    ) {
        self.angle = angle ?? ""
        self.gripWidth = gripWidth ?? ""
        self.gripOrientation = gripOrientation ?? ""
        self.stance = stance ?? ""
        self.laterality = laterality ?? ""
    }
}
