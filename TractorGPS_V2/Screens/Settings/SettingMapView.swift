//
//  SettingMapView.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 18/9/25.
//

import SwiftUI

struct SettingMapView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var locationManager: ManagerLocation
    // Persisted settings
    @AppStorage(AppStorageKeys.polygonColorHex) private var polygonColorHex: String = "#22642E"
    @AppStorage(AppStorageKeys.mapType) private var persistedMapType: String = "Default"
    
    @State private var polygonColor: Color = .green
    @State private var mapType: String = "Default"
    @State private var trackWidth = 1
    
    var body: some View {
        Form {
            Section(header: Text("GENERAL")) {
                // Polygon Color Picker
                HStack {
                    Text("Polygon Color").font(AppFonts.regular(size: 17)).foregroundColor(AppTheme.textPrimary)
                    Spacer()
                    ColorPicker("", selection: $polygonColor, supportsOpacity: false)
                        .labelsHidden()
                        .frame(width: 40, height: 40)
                }
                
                // Map Type Picker
                HStack(spacing: 20){
                    HStack(spacing: 20){
                        Text("Map Type").font(AppFonts.regular(size: 17)).foregroundColor(AppTheme.textPrimary)
                    }
                    Spacer()
                    Menu {
                        Button(action: { mapType = "Standard" }) {
                            HStack{
                                Text("Standard").font(AppFonts.regular(size: 17))
                                Spacer()
                                if mapType == "Standard" { Image("tick2") }
                            }
                        }
                        Button(action: { mapType = "Satellite" }) {
                            HStack{
                                Text("Satellite").font(AppFonts.regular(size: 17))
                                Spacer()
                                if mapType == "Satellite" { Image("tick2") }
                            }
                        }
                        
                    } label: {
                        HStack{
                            Text(mapType).font(AppFonts.regular(size: 17)).foregroundColor(AppTheme.textTertiary)
                            Image("dropdown") .foregroundColor(AppTheme.primary)
                        }
                    }
                }
            }
            
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image("icTracking")
                            Text("Track Width")
                                .font(AppFonts.regular(size: 17))
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                        }
                        HStack {
                            Text("\(trackWidth) ft")
                                .font(AppFonts.regular(size: 15))
                                .foregroundColor(AppTheme.primary)
                            Spacer()
                        }
                    }

                    Spacer()

                    HStack(spacing: 0) {
                        ScaleButton(icon: "Decrement") {
                            if trackWidth > 1 {
                                trackWidth -= 1
                                locationManager.customWidth = Double(trackWidth)
                            }
                        }
                        Divider().frame(height: 36).padding(.vertical, 5)
                        ScaleButton(icon: "Increment") {
                            if trackWidth < 30 {
                                trackWidth += 1
                                locationManager.customWidth = Double(trackWidth)
                            }
                        }
                    }
                    .background(AppTheme.border.opacity(0.08))
                    .clipShape(Capsule())
                }
            }
          
        }
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Settings")
                    }
                    .font(AppFonts.regular(size: 17))
                    .foregroundColor(AppTheme.primary)
                }
            }
        })
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: {
            // Load from persisted values
            mapType = persistedMapType
            trackWidth = Int(locationManager.effectiveWidth)
            polygonColor = Color(hex: polygonColorHex)
        })
        .onChange(of: mapType) { newValue in
            persistedMapType = newValue
        }
        
        .onChange(of: polygonColor) { newValue in
            if let cgColor = newValue.cgColor,
               let hex = cgColor.toHexString() {
                print("🎨 Polygon color hex: \(hex)")
                polygonColorHex = hex
            }
        }
        .navigationTitle("Map")
        .navigationBarTitleDisplayMode(.inline)
        
    }
}
struct ScaleButton: View {
    let icon: String
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
            action()
        }) {
            Image(icon)
                .foregroundColor(AppTheme.textPrimary)
                .frame(width: 46, height: 46)
                .scaleEffect(isPressed ? 1.2 : 1.0) // 👈 hiệu ứng nhấn
        }
        .buttonStyle(.plain) // tránh bị Section override
    }
}
