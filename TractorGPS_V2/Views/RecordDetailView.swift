//
//  RecordDetailView.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 18/9/25.
//

import SwiftUI
import MapKit

struct RecordDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let record: SavedRecord
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack{
                    Text("Your Record")
                        .font(AppFonts.bold(size: 34))
                        .foregroundColor(AppTheme.textPrimary)
                    Spacer()
                }.padding(.horizontal)
               
                PolygonMap(region: .constant(region), coordinates: record.coordinates)
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Record Added")
                        .font(AppFonts.semiBold(size: 20))
                        .foregroundColor(AppTheme.textPrimary)
                    Text(record.date.formatted(date: .abbreviated, time: .shortened))
                        .font(AppFonts.regular(size: 15))
                        .foregroundColor(AppTheme.textTertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    StatCard(icon: "􀐰", title: "Time", value: record.time, color: Color.init(hex: "FF9F0A"))
                    StatCard(icon: "􀑀", title: "Cover Area", value: record.coverArea, color: AppTheme.primary)
                    StatCard(icon: "􀍾", title: "Avg Speed", value: record.avgSpeed, color: Color.init(hex: "5E5CE6"))
                    StatCard(icon: "􀎫", title: "Elevation Gain", value: record.elevationGain, color: Color.init(hex: "0A84FF"))
                }
                .padding(.horizontal)
                
                Spacer(minLength: 20)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .onAppear {
            region = makeRegion(from: record.coordinates)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("History")
                    }
                    .font(AppFonts.regular(size: 17))
                    .foregroundColor(AppTheme.primary)
                }
            }
        }
        .themeAware()
    }
    
    /// Tạo region bao hết polygon
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
