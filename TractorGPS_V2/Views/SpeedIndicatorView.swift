//
//  SpeedIndicatorView.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 5/9/25.
//

import CoreLocation
import MapKit
import SwiftUI

struct SpeedIndicatorView: View {
    let speed: Double
    
    var formattedSpeed: String {
        let kph = speed * 3.6
        return String(format: "%.1f km/h", kph)
    }
    
    var body: some View {
        Text(formattedSpeed)
            .font(.system(.title2, design: .monospaced))
            .padding()
            .background(Color.black.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

struct StatsView: View {
    let distance: Double
    let area: Double
    
    var formattedDistance: String {
        if distance >= 1000 {
            return String(format: "%.2f km", distance / 1000)
        }
        return String(format: "%.0f m", distance)
    }
    
    var formattedArea: String {
        let hectares = area / 10000
        if hectares >= 1 {
            return String(format: "%.2f ha", hectares)
        }
        return String(format: "%.0f m²", area)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading) {
                Text("Distance")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(formattedDistance)
                    .font(.system(.body, design: .monospaced))
            }
            
            VStack(alignment: .leading) {
                Text("Area")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(formattedArea)
                    .font(.system(.body, design: .monospaced))
            }
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .foregroundColor(.white)
        .cornerRadius(10)
    }
}
