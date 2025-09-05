//
//  ButtonTrackView.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 5/9/25.
//

import MapKit
import SwiftUI

struct ButtonTrackView: View {
    @ObservedObject var locationManager: ManagerLocation
    @Binding var region: MKCoordinateRegion

    var formattedAcres: String {
        let acres = locationManager.coveredArea.toAcres()
        return String(format: "%.2f", acres)
    }

    @Binding var operationType: OperationType

    var body: some View {
        VStack(spacing: 5) {
            // Status Text
            Text(locationManager.isTracking ? "TRACKING" : "READY")
                .font(.system(.caption, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(locationManager.isTracking ? .green : .white)

            // Main Track Button
            Button(action: {
                locationManager.toggleTracking()
                if locationManager.isTracking {
                    zoomToUser()
                }
            }) {
                ZStack {
                    // Outer circle
                    Circle()
                        .fill(Color.black.opacity(0.7))
                        .frame(width: 55, height: 55)

                    // Inner circle with glow
                    Circle()
                        .fill(locationManager.isTracking ? Color.red : Color.green)
                        .frame(width: 55, height: 55)
                        .shadow(color: locationManager.isTracking ? .red : .green, radius: 10)

                    // Icon
                    Image(systemName: locationManager.isTracking ? "stop.fill" : "play.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                        .offset(x: locationManager.isTracking ? 0 : 2.5)
                }
            }

            // Acres Counter
            VStack(spacing: 2) {
                Text(formattedAcres)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("acres \(operationType)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }
            .padding(.vertical, 8)
            // .frame(maxWidth: 200)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.3))
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.6))
                .shadow(radius: 10)
        )
    }

    private func zoomToUser() {
        if let location = locationManager.location {
            withAnimation {
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.0005, // Smaller number = closer zoom
                        longitudeDelta: 0.0005
                    )
                )
            }
        }
    }
}
