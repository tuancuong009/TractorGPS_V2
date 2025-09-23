//
//  DoubleExtension.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 5/9/25.
//

import Foundation

extension Double {
    func toAcres() -> Double {
        // Convert square meters to acres
        // 1 square meter = 0.000247105 acres
        return self * 0.000247105
    }

    func toHectares() -> Double {
        // Convert square meters to hectares
        // 1 square meter = 0.0001 hectares
        return self * 0.0001
    }
    
    var feetToMeters: Double { self * 0.3048 }
    var metersToFeet: Double { self / 0.3048 }
}
