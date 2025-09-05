//
//  LiveActivityPreview.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 5/9/25.
//

import SwiftUI

struct LiveActivityPreview: View {
    @State private var distanceFromLine: Double = 2.1
    @State private var heading: Double = 156.0
    @State private var shouldTurnLeft: Bool = true
    @State private var coveredArea: Double = 4.33
    @State private var speed: Double = 15.6
    @State private var isTracking: Bool = true
    @State private var isCentered: Bool = false

    var body: some View {
        ZStack {
            Color.black

            VStack(spacing: 20) {
                HStack {
                    StatView(
                        value: String(format: "%.1f", coveredArea),
                        unit: "ac",
                        label: "AREA",
                        color: .orange
                    )

                    Spacer()

                    VStack {
                        HeadingArcView(
                            heading: heading,
                            isTracking: isTracking,
                            distanceFromLine: isCentered ? 0.05 : distanceFromLine,
                            shouldTurnLeft: shouldTurnLeft
                        )
                        .frame(height: 90)

                        HStack {
                            Circle()
                                .fill(isTracking ? Color.green : Color.red)
                                .frame(width: 8, height: 8)
                            Text(isTracking ? "Tracking" : "Paused")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.gray)
                        }
                    }

                    Spacer()

                    StatView(
                        value: String(format: "%.1f", speed),
                        unit: "km/h",
                        label: "SPEED",
                        color: .green
                    )
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .frame(height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 20))

        // Preview controls
        VStack {
            Toggle("Centered", isOn: $isCentered)
            Toggle("Should Turn Left", isOn: $shouldTurnLeft)
            Toggle("Tracking", isOn: $isTracking)
            Slider(value: $distanceFromLine, in: 0 ... 4)
            Slider(value: $speed, in: 0 ... 30)
            Slider(value: $coveredArea, in: 0 ... 10)
        }
        .padding()
    }
}

struct HeadingArcView: View {
    let heading: Double
    let isTracking: Bool
    let distanceFromLine: Double
    let shouldTurnLeft: Bool

    private var isLinedUp: Bool {
        abs(distanceFromLine) < 0.2
    }

    var body: some View {
        ZStack {
            // Guidance Information
            VStack(spacing: 4) {
                // Dynamic indicator - changes based on alignment
                if isLinedUp {
                    Circle()
                        .fill(.green)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(.green, lineWidth: 2)
                                .scaleEffect(1.3)
                                .opacity(0.5)
                        )
                        .overlay(
                            Circle()
                                .stroke(.green, lineWidth: 2)
                                .scaleEffect(1.6)
                                .opacity(0.3)
                        )
                        .scaleEffect(1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                                   value: isLinedUp)
                } else {
                    Image(systemName: shouldTurnLeft ? "arrow.left" : "arrow.right")
                        .font(.system(size: 24))
                        .foregroundStyle(getIndicatorColor())
                }

                // Distance from line (primary focus)
                Text(abs(distanceFromLine) < 0.1 ? "CENTERED" : String(format: "%.1f m", abs(distanceFromLine)))
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundStyle(abs(distanceFromLine) < 0.1 ? .green : .white)
            }
        }
    }

    private func getIndicatorColor() -> Color {
        if abs(distanceFromLine) < 0.2 {
            return .green // On track
        } else if abs(distanceFromLine) < 0.5 {
            return .yellow // Slight deviation
        } else {
            return .red // Significant deviation
        }
    }
}

struct StatView: View {
    let value: String
    let unit: String
    let label: String
    let color: Color

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)

            Text(unit)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.gray)

            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.gray)
        }
    }
}
