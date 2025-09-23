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
    @Environment(\.safeAreaInsets) var safeInsets
    @StateObject private var locationManager = ManagerLocation()
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage(AppStorageKeys.onboardingWorkType) private var onboardingWorkType: String?
    @AppStorage(AppStorageKeys.mapType) private var persistedMapType: String = "Default"
    @AppStorage(AppStorageKeys.unitType) private var persistedUnitType: String = "metric"
    @AppStorage(AppStorageKeys.polygonColorHex) private var polygonColorHex: String = "#00FF00"
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
    )
    @State private var showPaywall = false
    @State private var userTrackingMode: MKUserTrackingMode = .none
    @State private var isNight: Bool = false
    @State private var operationType: OperationType = .harvesting
    @State private var hasRequestedPermissions = false
    @State private var trackWidth = 1
    @State private var showSetTarget = false
    @State private var mapType: MKMapType = .standard
    @State private var focusUser = false
    @State private var points: [CLLocationCoordinate2D] = []
    @Binding var isStart: Bool
    @State private var recordData: RecordData?
    @State private var showNewRecord = false
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                MapViewKit(locationManager: locationManager,
                           region: $region,
                           userTrackingMode: $userTrackingMode,
                           mapType: $mapType)
                .edgesIgnoringSafeArea(.all)
                if isStart{
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            VStack(spacing: 12) {
                                HStack{
                                    Spacer()
                                    GuidanceControlView(locationManager: locationManager,
                                                        mapType: $mapType,
                                                        isNight: $isNight)
                                }
                               
                                
                                ButtonTrackView(locationManager: locationManager,
                                                region: $region,
                                                operationType: $operationType, onStop: {
                                    handeStop()
                                  
                                }).padding(.top, 30)
                            }
                        }
                        .padding(.trailing, 16) // cách mép phải
                        .padding(.bottom, 10)
                    }
                    .frame(maxWidth: .infinity) // ⬅️ full chiều ngang
                       .padding(.bottom, safeInsets.bottom + 20)
                }
                
                
            }.toolbar {
                if isStart{
                    ToolbarItem(placement: .topBarTrailing) {
                        StatusCard(
                            value: formattedSpeed,
                            unit: speedUnitLabel,
                            icon: "toobar_dashboard",
                            color: .green
                        )
                    }
                    
                    ToolbarItem(placement: .topBarLeading) {
                        StatusCard(
                            value: formattedDistance,
                            unit: distanceUnitLabel,
                            icon: "toobar_feel",
                            color: .orange
                        )
                    }
                    
                }
                
                
            }.onAppear {
                operationType = mapWorkTypeToOperation(onboardingWorkType)
                mapType = mapStringToMKMapType(persistedMapType)
                
                locationManager.requestPermission()
                if let location = locationManager.location {
                    region.center = location.coordinate
                }
                
            }.safeAreaInset(edge: .bottom, content: {
                if isStart{
                }
                else{
                    if locationManager.isLocationAuthorized && locationManager.didCheckPermission {
                        PreSettingsView(
                            farmingType: operationType.rawValue.capitalized,
                            trackWidth: "\(trackWidth) ft",
                            onDecrease: {
                                if trackWidth > 1 {   // min = 1
                                    trackWidth -= 1
                                    locationManager.customWidth = Double(trackWidth)
                                }
                            },
                            onIncrease: {
                                if trackWidth < 30 {  // max = 30
                                    trackWidth += 1
                                    locationManager.customWidth = Double(trackWidth)
                                }
                            },
                            onStart: {
                                withAnimation(.easeInOut) {
                                    isStart.toggle()
                                    locationManager.toggleTracking()
                                }
                            },
                            onSetTarget: {
                                showSetTarget = true
                            },
                            operationType: $operationType,
                            locationManager: locationManager
                        )
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut, value: isStart)
                        .onChange(of: operationType) { newType in
                        }
                    }
                   
                }
                
                
                //Toolbar(locationManager: locationManager, region: $region, userTrackingMode: $userTrackingMode, isNight: $isNight, operationType: $operationType, mapType: $mapType)
            })
            .sheet(isPresented: $showSetTarget) {
                SetAreaCoverageView(initialRegion: region,
                                    points: $points,
                                    mapType: $mapType,
                                    focusUser: $focusUser)
            }
            
            .sheet(isPresented: $showNewRecord) {
                if let data = recordData{
                    RecordView(
                        region: data.region,
                        coordinates: data.coordinates,
                        time: data.time,
                        coverArea: data.coverArea,
                        avgSpeed: data.avgSpeed,
                        elevationGain: data.elevationGain, onDone: {
                            handleDone()
                        }
                    )
                }
            }
            .onChange(of: points) { newPoints in
                print("Polygon saved: \(newPoints)")
            }
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
            if !locationManager.isLocationAuthorized && locationManager.didCheckPermission {
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
                        .background(.colorMain)
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
        .onAppear(perform: {
            trackWidth = Int(locationManager.effectiveWidth)
        })
        .onChange(of: operationType) { newType in
            trackWidth = Int(locationManager.effectiveWidth)
            onboardingWorkType = mapOperationToWorkType(newType)
        }
        .onChange(of: onboardingWorkType) { newValue in
            operationType = mapWorkTypeToOperation(newValue)
        }
        .onChange(of: persistedMapType) { newValue in
            mapType = mapStringToMKMapType(newValue)
        }
        .padding(.bottom, !isStart ? safeInsets.bottom + 62 : 0)
    }
    private func mapWorkTypeToOperation(_ workType: String?) -> OperationType {
        switch workType {
        case .some(let v) where v.localizedCaseInsensitiveContains("plowing"):
            return .plowing
        case .some(let v) where v.localizedCaseInsensitiveContains("seeding"):
            return .seeding
        case .some(let v) where v.localizedCaseInsensitiveContains("harvest"):
            return .harvesting
        case .some(let v) where v.localizedCaseInsensitiveContains("fertiliz"):
            return .spraying // closest match for fertilizing
        default:
            return .harvesting
        }
    }
    
    private func mapOperationToWorkType(_ operation: OperationType) -> String {
        switch operation {
        case .plowing:
            return "Field Plowing"
        case .seeding:
            return "Seeding"
        case .harvesting:
            return "Harvesting"
        case .spraying:
            return "Fertilizing"
        }
    }
    func handeStop(){
        let coords = locationManager.trackingSessions.last?.map { $0.coordinate } ?? []
        let duration = locationManager.currentSessionDuration()
        let timeString = formatDuration(duration)

        let areaHa = locationManager.coveredArea / 10_000.0 // m² -> ha
        let avgSpeed = duration > 0 ? (locationManager.totalDistance / duration) * 3.6 : 0 // km/h
        let elevation = locationManager.currentSessionElevationGain()

        recordData = RecordData(
            region: region,
            coordinates: points,
            time: timeString,
            coverArea: String(format: "%.2f ha", areaHa),
            avgSpeed: String(format: "%.2f km/h", avgSpeed),
            elevationGain: String(format: "%.0f m", elevation)
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            showNewRecord = true
        }
    }
    func handleDone() {
        showNewRecord = false
        recordData = nil
        isStart = false
        points.removeAll()
        locationManager.clearAllSessions()
    }
    
    var speedUnitLabel: String { persistedUnitType == "imperial" ? "mph" : "km/h" }
    var distanceUnitLabel: String {
        if persistedUnitType == "imperial" {
            return locationManager.totalDistance >= 1609.34 ? "mi" : "ft"
        } else {
            return locationManager.totalDistance >= 1000 ? "km" : "meter"
        }
    }
    var formattedDistance: String {
        if persistedUnitType == "imperial" {
            if locationManager.totalDistance >= 1609.34 {
                return String(format: "%.2f", locationManager.totalDistance / 1609.34)
            } else {
                return String(format: "%.0f", locationManager.totalDistance * 3.28084)
            }
        } else {
            if locationManager.totalDistance >= 1000 {
                return String(format: "%.2f", locationManager.totalDistance / 1000)
            }
            return String(format: "%.1f", locationManager.totalDistance)
        }
    }
    
    var formattedSpeed: String {
        if persistedUnitType == "imperial" {
            return String(format: "%.1f", locationManager.currentSpeed * 2.236936)
        }
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
    
    func formatDuration(_ seconds: TimeInterval) -> String {
        let intSec = Int(seconds)
        let h = intSec / 3600
        let m = (intSec % 3600) / 60
        let s = intSec % 60
        if h > 0 {
            return String(format: "%02d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%02d:%02d", m, s)
        }
    }

}

// MARK: - Settings Helper
extension ContentView {
    private func mapStringToMKMapType(_ value: String) -> MKMapType {
        switch value {
        case "Satellite": return .satellite
        case "Standard": return .standard
        default: return .standard
        }
    }
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

