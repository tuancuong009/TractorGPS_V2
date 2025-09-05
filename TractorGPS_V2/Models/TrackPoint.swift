//
//  TrackPoint.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 5/9/25.
//

import CoreLocation
import Foundation
import SwiftUI

// MARK: - Equipment Models

struct TrackPoint: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let timestamp: Date
    let operationType: OperationType
    let implementWidth: Double
}

enum OperationType: String, CaseIterable {
    case harvesting = "Harvesting"
    case plowing = "Plowing"
    case seeding = "Seeding"
    case spraying = "Spraying"

    var color: UIColor {
        switch self {
        case .harvesting: return .green
        case .plowing: return .brown
        case .seeding: return .blue
        case .spraying: return .red
        }
    }

    var defaultWidth: Double {
        switch self {
        case .harvesting: return 10.0
        // case .harvesting: return 12.0
        case .plowing: return 4.5
        case .seeding: return 6.0
        case .spraying: return 18.0
        }
    }

    var icon: String {
        switch self {
        case .harvesting: return "leaf.fill"
        case .plowing: return "triangle.fill"
        case .seeding: return "circle.grid.cross.fill"
        case .spraying: return "drop.fill"
        }
    }
}
