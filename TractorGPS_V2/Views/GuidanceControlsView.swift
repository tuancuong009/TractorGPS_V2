//
//  GuidanceControlsView.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 5/9/25.
//

import CoreLocation
import SwiftUI
import MapKit
struct GuidanceControlView: View {
    @ObservedObject var locationManager: ManagerLocation
    @Binding var mapType: MKMapType
    @Binding var isNight: Bool
    @AppStorage(AppStorageKeys.mapType) private var persistedMapType: String = "Default"
    var body: some View {
        VStack {
            // AB Line Controls
            VStack(spacing: 20){
                Button(action: {
                    locationManager.setPointA()
                }) {
                    Button(action: {
                        locationManager.setPointA()
                    }) {
                        ZStack {
                            // Glass effect background
                            VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark)
                                .clipShape(Circle())
                            
                            Circle()
                                .fill(Color.black.opacity(0.3))
                            
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.6),
                                            .white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                            
                            if !locationManager.isSettingPointA {
                                Image("texta")
                            } else {
                                ProgressView()
                            }
                        }
                        .frame(width: 64, height: 64)
                        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                    }

                }

                // Point B Button
                Button(action: {
                    locationManager.setPointB()
                }) {
                    ZStack {
                        // Glass effect background
                        VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark)
                            .clipShape(Circle())
                        
                        Circle()
                            .fill(Color.black.opacity(0.3)).opacity(locationManager.pointA == nil ? 0.5 : 1.0)
                        
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.6),
                                        .white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                        
                        if !locationManager.isSettingPointB {
                            Image("textb")
                        } else {
                            ProgressView()
                        }
                    }
                    .frame(width: 64, height: 64)
                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(locationManager.pointA == nil)
                // MAP
                Button(action: {
                    withAnimation(.easeInOut) {
                        mapType = mapType == .standard ? .satellite : .standard
                    }
                }) {
                    ZStack {
                        // Glass effect background
                        VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark)
                            .clipShape(Circle())
                        
                        Circle()
                            .fill(Color.black.opacity(0.3))
                        
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.6),
                                        .white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                        
                        Image("mapType")
                    }
                    .frame(width: 64, height: 64)
                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                Button(action: {
                    withAnimation(.easeInOut) {
                        withAnimation(.easeInOut) {
                            isNight.toggle()
                        }
                    }
                }) {
                    ZStack {
                        
                        Circle()
                            .fill(Color.black.opacity(1))
                        
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.6),
                                        .white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                        
                        Image("icNight")
                    }
                    .frame(width: 64, height: 64)
                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
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
        }.onChange(of: mapType) { newValue in
            if newValue == .standard{
                persistedMapType = "Standard"
            }
            else{
                persistedMapType = "Satellite"
            }
        }
    }
}
