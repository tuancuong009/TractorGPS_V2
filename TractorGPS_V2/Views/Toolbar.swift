//
//  Toolbar.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 5/9/25.
//

import CoreLocation
import Foundation
import MapKit
import SwiftUI

struct Toolbar: View {
    @ObservedObject var locationManager: ManagerLocation
    @Binding var region: MKCoordinateRegion
    @State private var showingWidthPicker = false
    @Binding var userTrackingMode: MKUserTrackingMode // Add this
    @Binding var isNight: Bool
    @Binding var operationType: OperationType
    @Binding var mapType: MKMapType
    @EnvironmentObject var themeManager: ThemeManager
    
    var locationButtonImage: String {
        switch userTrackingMode {
        case .none:
            return "location"
        case .follow:
            return "location.fill"
        case .followWithHeading:
            return "location.north.line.fill"
        @unknown default:
            return "location"
        }
    }
    
    var body: some View {
        VStack(spacing: 2) {
            HStack {
                Spacer()
                VStack {
                    // Map Type Toggle Button
                    Button {
                        withAnimation(.easeInOut) {
                            mapType = mapType == .standard ? .satellite : .standard
                        }
                    } label: {
                        Image(systemName: mapType == .standard ? "map" : "map.fill")
                            .padding()
                            .foregroundStyle(mapType == .standard ? AppTheme.primary : AppTheme.textPrimary)
                            .background(mapType == .standard ? AppTheme.surface : AppTheme.surfaceSecondary)
                            .clipShape(Circle())
                    }
                    
                    Button {
                        withAnimation(.easeInOut) {
                            themeManager.toggleTheme()
                        }
                    } label: {
                        Image(systemName: themeManager.isDarkMode ? "sun.max.fill" : "moon.fill")
                            .padding()
                            .foregroundStyle(themeManager.isDarkMode ? .black : .white)
                            .background(themeManager.isDarkMode ? AppTheme.surface : AppTheme.primary)
                            .clipShape(Circle())
                    }
                }
            }.padding(.horizontal)
            HStack {
                Button(action: centerOnUser) {
                    Image(systemName: "location.fill")
                        .padding()
                        .background(AppTheme.primary)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }.tint(.white)
                
                Menu {
                    ForEach(OperationType.allCases, id: \.self) { type in
                        Button(action: { locationManager.currentOperation = type
                            operationType = type
                        }) {
                            Label(type.rawValue, systemImage: type.icon)
                        }
                    }
                } label: {
                    Image(systemName: locationManager.currentOperation.icon)
                        .padding()
                        .background(AppTheme.surface)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                
                Spacer()
                
                Button(action: { showingWidthPicker.toggle() }) {
                    Image(systemName: "ruler")
                        .padding()
                        .background(AppTheme.surface)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                
                Button(action: { locationManager.clearCurrentSession() }) {
                    Image(systemName: "trash")
                        .padding()
                        .background(AppTheme.error)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }.tint(.white)
            }
            .padding()
            
            if showingWidthPicker {
                HStack {
                    Text("Width: ")
                    Slider(
                        value: Binding(
                            get: { locationManager.customWidth ?? locationManager.currentOperation.defaultWidth },
                            set: { locationManager.customWidth = $0 }
                        ),
                        in: 1 ... 30,
                        step: 0.5
                    )
                    Text(String(format: "%.1fm", locationManager.effectiveWidth))
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(.infinity)
                .shadow(radius: 4)
                .padding(.horizontal)
                .safeAreaPadding(.bottom, 18)
            }
        }.safeAreaPadding(.bottom, 10)
    }
    
    private func centerOnUser() {
        guard let location = locationManager.location else { return }
        
        switch userTrackingMode {
        case .none:
            userTrackingMode = .followWithHeading
            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
            )
            
        case .follow:
            userTrackingMode = .followWithHeading
            
        case .followWithHeading:
            userTrackingMode = .none
            
        @unknown default:
            userTrackingMode = .none
        }
    }
}
