//
//  ContentView.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 5/9/25.
//

import CoreLocation
import MapKit
import StoreKit
import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = ManagerLocation()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
    )
    @State private var showPaywall = false
    @State private var userTrackingMode: MKUserTrackingMode = .none
    @State private var isNight: Bool = false
    @State private var operationType: OperationType = .harvesting
    @State private var mapType: MKMapType = .standard
    @State private var hasRequestedPermissions = false

    var body: some View {
        NavigationStack {
            ZStack {
                MapViewKit(locationManager: locationManager,
                           region: $region,
                           userTrackingMode: $userTrackingMode,
                           mapType: $mapType)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    GuidanceControlView(locationManager: locationManager)

                    Spacer()

                    // Track Button
                    ButtonTrackView(locationManager: locationManager, region: $region, operationType: $operationType)
                        .offset(y: 130)
                }
            }.toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    StatusCard(
                        value: formattedSpeed,
                        unit: "km/h",
                        icon: "speedometer",
                        color: .green
                    )
                }

                ToolbarItem(placement: .topBarLeading) {
                    StatusCard(
                        value: formattedDistance,
                        unit: locationManager.totalDistance >= 1000 ? "km" : "meter",
                        icon: "map",
                        color: .orange
                    )
                }

            }.onAppear {
                locationManager.requestPermission()
                if let location = locationManager.location {
                    region.center = location.coordinate
                }

            }.safeAreaInset(edge: .bottom, content: {
                Toolbar(locationManager: locationManager, region: $region, userTrackingMode: $userTrackingMode, isNight: $isNight, operationType: $operationType, mapType: $mapType)
            })
            .onReceive(locationManager.$location) { newLocation in
                if let location = newLocation {
                    region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
                    )
                }
            }
        }.overlay {
            if isNight {
                Color.red.opacity(0.1).ignoresSafeArea()
                    .saturation(5)
                    .allowsHitTesting(false)
            }
            // Location disabled overlay
            if !locationManager.isLocationAuthorized {
                VStack(spacing: 12) {
                    Text("Location is disabled")
                        .font(.headline)
                        .foregroundColor(.white)
                    Button(action: openAppSettings) {
                        HStack {
                            Image(systemName: "gear")
                            Text("Open Settings")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.blue.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding(16)
                .background(Color.black.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .padding()
            }
        }
    }

    var formattedDistance: String {
        if locationManager.totalDistance >= 1000 {
            return String(format: "%.2f", locationManager.totalDistance / 1000)
        }
        return String(format: "%.1f", locationManager.totalDistance)
    }

    var formattedSpeed: String {
        return String(format: "%.1f", locationManager.currentSpeed * 3.6)
    }

    // Zoom in function
    private func zoomIn() {
        region.span.latitudeDelta /= 2
        region.span.longitudeDelta /= 2
    }

    // Zoom out function
    private func zoomOut() {
        region.span.latitudeDelta *= 2
        region.span.longitudeDelta *= 2
    }
}

// MARK: - Settings Helper
extension ContentView {
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

struct StatusCard: View {
    let value: String
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(color.opacity(0.2))
                )

            // Value and Unit
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(unit)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(8)
        .frame(minWidth: 120)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.8))
                .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        )
    }
}
