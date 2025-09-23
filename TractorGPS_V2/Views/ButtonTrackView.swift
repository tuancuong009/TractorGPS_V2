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
    var onStop: () -> Void
    var body: some View {
        
        HStack(spacing: 12) {
            // Resume / Pause button
            if locationManager.isTracking{
                Color.clear.frame(width: 38, height: 76)
            }
            Button(action: {
                locationManager.toggleTracking()
                if locationManager.isTracking {
                    zoomToUser()
                }
            }) {
                
                HStack {
                    Image(systemName: !locationManager.isTracking ? "play.fill" : "pause.fill") .font(AppFonts.semiBold(size: 20))
                        .foregroundColor(.white)
                    Text(!locationManager.isTracking ? "Resume" : "Pause")
                        .foregroundColor(.white)
                        .font(AppFonts.semiBold(size: 20))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 76)
                .background(!locationManager.isTracking ? Color.init(hex: "00B846") : Color.init(hex: "0088FF"))
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
                
            }.overlay( // Viền
                Capsule()
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
            )
            
            // Stop button
            if !locationManager.isTracking{
                Button(action: {
                    print("Stop tapped")
                    onStop()
                }) {
                    Image("btn_stop")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                        .frame(width: 76, height: 76)
                        .background(Color.red)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
                }.overlay( // Viền
                    Capsule()
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
                )
            }
            else{
                Color.clear.frame(width: 38, height: 76)
            }
          
        }
        .frame(maxWidth: .infinity)
        
        
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
