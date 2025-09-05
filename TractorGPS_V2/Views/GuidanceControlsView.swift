//
//  GuidanceControlsView.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 5/9/25.
//

import CoreLocation
import SwiftUI

struct GuidanceControlView: View {
    @ObservedObject var locationManager: ManagerLocation

    var body: some View {
        VStack {
            // AB Line Controls
            HStack(spacing: 20) {
                // Point A Button
                Button(action: {
                    locationManager.setPointA()
                }) {
                    ZStack {
                        Circle()
                            .fill(locationManager.pointA == nil ? Color.blue : Color.green)
                            .frame(width: 50, height: 50)
                        if !locationManager.isSettingPointA {
                            Text("A")
                                .foregroundColor(.white)
                                .font(.title2)
                                .bold()
                        } else {
                            ProgressView()
                        }
                    }
                }

                // Point B Button
                Button(action: {
                    locationManager.setPointB()
                }) {
                    ZStack {
                        Circle()
                            .fill(locationManager.pointB == nil ? Color.blue : Color.green)
                            .opacity(locationManager.pointA == nil ? 0.5 : 1.0)
                            .frame(width: 50, height: 50)

                        if !locationManager.isSettingPointB {
                            Text("B")
                                .foregroundColor(.white)
                                .font(.title2)
                                .bold()
                        } else {
                            ProgressView()
                        }
                    }
                }
                .disabled(locationManager.pointA == nil)
            }

            // Guidance Information
            if locationManager.pointA != nil && locationManager.pointB != nil {
                HStack {
                    Image(systemName: locationManager.shouldTurnLeft ? "arrow.left" : "arrow.right")
                        .font(.title2)
                    Text(String(format: "%.1f m", locationManager.distanceFromLine))
                        .font(.title3)
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
}
