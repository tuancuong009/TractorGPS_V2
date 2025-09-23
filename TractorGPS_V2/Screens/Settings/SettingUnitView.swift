//
//  SettingUnitView.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 18/9/25.
//

import SwiftUI

struct SettingUnitView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage(AppStorageKeys.unitType) private var persistedUnitType: String = "metric"
    @State private var selectedUnit: UnitType = .metric
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 16) {
                
                // Hai lựa chọn đơn vị đo
                HStack(spacing: 16) {
                    UnitCard(
                        type: .metric,
                        title: "Metric",
                        details: [
                            "Working Width and Distance: Meters",
                            "Speed: Km/h",
                            "Area: Hectares"
                        ],
                        icon: "ic_web",
                        isSelected: selectedUnit == .metric
                    ) {
                        selectedUnit = .metric
                    }
                    
                    UnitCard(
                        type: .imperial,
                        title: "Imperial",
                        details: [
                            "Working Width and Distance: Feet",
                            "Speed: mph",
                            "Area: Acres"
                        ],
                        icon: "ic_dashboard",
                        isSelected: selectedUnit == .imperial
                    ) {
                        selectedUnit = .imperial
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Measurement Units")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                selectedUnit = UnitType.from(persistedUnitType)
            }
            .onChange(of: selectedUnit) { newValue in
                persistedUnitType = newValue.persistValue
            }
        }
    }
}

struct UnitCard: View {
    let type: UnitType
    let title: String
    let details: [String]
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                isPressed = true
            }
            // reset về 1.0 sau 0.2s
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                    isPressed = false
                }
            }
            action()
        }) {
            VStack(spacing: 16) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .padding(.top, 12)
                
                VStack(spacing: 8) {
                    Text(title)
                        .font(AppFonts.semiBold(size: 17))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(details, id: \.self) { detail in
                            Text("• \(detail)")
                                .font(AppFonts.regular(size: 13))
                                .foregroundColor(AppTheme.textTertiary)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(.horizontal, 8)
                }
                
                Image(isSelected ? "ticked" : "untick")
                    .padding(.bottom, 12)
            }
            .frame(maxWidth: .infinity)
            .background(AppTheme.surfaceSecondary2)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isSelected ? AppTheme.primary : UITraitCollection.current.userInterfaceStyle == .dark ? Color.clear :  Color.gray.opacity(0.3), lineWidth: 2)
            )
            .scaleEffect(isPressed ? 1.05 : 1.0) // hiệu ứng scale
        }
        .buttonStyle(PlainButtonStyle()) // giữ nguyên UI custom
    }
}


enum UnitType {
    case metric, imperial
}

extension UnitType {
    var persistValue: String { self == .metric ? "metric" : "imperial" }
    static func from(_ value: String) -> UnitType { value == "imperial" ? .imperial : .metric }
}
