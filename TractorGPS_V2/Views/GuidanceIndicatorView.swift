//
//  GuidanceIndicatorView.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 5/9/25.
//

import CoreLocation
import SwiftUI

struct GuidanceIndicatorView: View {
    @ObservedObject var locationManager: ManagerLocation

    var body: some View {
        HStack(spacing: 20) {
            // Left/Right indicator
            Image(systemName: locationManager.shouldTurnLeft ? "arrow.left.circle.fill" : "arrow.right.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(getIndicatorColor())

            // Distance and direction visualization
            VStack {
                Text(String(format: "%.1f m", locationManager.distanceFromLine))
                    .font(.title2)
                    .bold()

                // Visual indicator
                ZStack {
                    Rectangle()
                        .frame(width: 200, height: 4)
                        .foregroundColor(.gray)

                    Rectangle()
                        .frame(width: 4, height: 20)
                        .foregroundColor(.white)
                        .offset(x: getOffsetForDistance())
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(15)
    }

    private func getIndicatorColor() -> Color {
        let distance = locationManager.distanceFromLine
        if distance < 0.2 {
            return .green
        } else if distance < 0.5 {
            return .yellow
        } else {
            return .red
        }
    }

    private func getOffsetForDistance() -> CGFloat {
        let maxOffset: CGFloat = 100
        let scale = min(abs(locationManager.distanceFromLine) / 2.0, 1.0)
        return locationManager.shouldTurnLeft ? -maxOffset * scale : maxOffset * scale
    }
}

enum GuidancePattern: String, CaseIterable {
    case abLine = "A-B Line"
    case curve = "Curved"

    var icon: String {
        switch self {
        case .abLine: return "arrow.left.and.right"
        case .curve: return "curlybraces"
        }
    }
}

struct GuidanceSettingsView: View {
    @ObservedObject var locationManager: ManagerLocation
    @Binding var selectedPattern: GuidancePattern

    var body: some View {
        VStack(spacing: 15) {
            // Pattern Selection
            Picker("Pattern", selection: $selectedPattern) {
                ForEach(GuidancePattern.allCases, id: \.self) { pattern in
                    Label(pattern.rawValue, systemImage: pattern.icon)
                        .tag(pattern)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            // Implement Width Control
            HStack {
                Text("Width:")
                Slider(
                    value: $locationManager.implementWidth,
                    in: 4 ... 30,
                    step: 0.5
                )
                Text("\(Int(locationManager.implementWidth))m")
            }
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(10)
    }
}
