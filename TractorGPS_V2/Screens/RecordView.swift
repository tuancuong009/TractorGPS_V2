//
//  RecordView.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 17/9/25.
//


import SwiftUI
import MapKit

import SwiftUI
import MapKit

struct RecordView: View {
    @StateObject private var locationManager = ManagerLocation()
    @State var region: MKCoordinateRegion
    
    var coordinates: [CLLocationCoordinate2D]
    var time: String
    var coverArea: String
    var avgSpeed: String
    var elevationGain: String
    var date: Date = Date() 
    var onDone: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    var body: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(AppTheme.border.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            Text("New Record")
                .font(AppFonts.semiBold(size: 17))
                .foregroundColor(AppTheme.textPrimary)
            Divider()
            
            // Map với Polygon
            PolygonMap(region: .constant(region), coordinates: coordinates)
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("New Record Added")
                    .font(AppFonts.semiBold(size: 20))
                    .foregroundColor(AppTheme.textPrimary)
                Text(date.formatted(date: .abbreviated, time: .shortened))
                    .font(AppFonts.regular(size: 15))
                    .foregroundColor(AppTheme.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatCard(icon: "􀐰", title: "Time", value: time, color: Color.init(hex: "FF9F0A"))
                StatCard(icon: "􀑀", title: "Cover Area", value: coverArea, color: AppTheme.primary)
                StatCard(icon: "􀍾", title: "Avg Speed", value: avgSpeed, color: Color.init(hex: "5E5CE6"))
                StatCard(icon: "􀎫", title: "Elevation Gain", value: elevationGain, color: Color.init(hex: "0A84FF"))
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                // Save to Core Data
                print("RecordView - Saving coordinates count: \(coordinates.count)")
                PersistenceController.shared.saveRecord(
                    date: date,
                    time: time,
                    coverArea: coverArea,
                    avgSpeed: avgSpeed,
                    elevationGain: elevationGain,
                    fieldName: locationManager.currentOperation.rawValue,
                    coordinates: coordinates
                )
                onDone()
            }) {
                Text("Done")
                    .font(AppFonts.medium(size: 17))
                    .foregroundColor(AppTheme.primary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .padding(.vertical, 6)
                    .background(AppTheme.surfaceSecondary)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .onAppear {
            if coordinates.count > 0{
                region = makeRegion(from: coordinates)
            }
            print("POINTS--->",region)
        }
        .themeAware()
    }
    
    private func makeRegion(from coords: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        guard !coords.isEmpty else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
        
        var minLat = coords.first!.latitude
        var maxLat = coords.first!.latitude
        var minLon = coords.first!.longitude
        var maxLon = coords.first!.longitude
        
        for c in coords {
            minLat = min(minLat, c.latitude)
            maxLat = max(maxLat, c.latitude)
            minLon = min(minLon, c.longitude)
            maxLon = max(maxLon, c.longitude)
        }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let latDelta = max(0.001, (maxLat - minLat) * 1.5)
        let lonDelta = max(0.001, (maxLon - minLon) * 1.5)
        
        return MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        )
    }
}


// View Map với polygon





struct StatCard: View {
    var icon: String
    var title: String
    var value: String
    var color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(icon).foregroundColor(color).font(AppFonts.regular(size: 13))
                Text(title)
                    .font(AppFonts.regular(size: 13))
                    .foregroundColor(AppTheme.textTertiary)
                Spacer()
            }
            
            Text(value)
                .font(AppFonts.semiBold(size: 17)).foregroundColor(AppTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(AppTheme.surfaceSecondary)
        .cornerRadius(12)
    }
}

