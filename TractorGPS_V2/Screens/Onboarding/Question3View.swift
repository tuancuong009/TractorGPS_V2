//
//  Question3View.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 15/9/25.
//

import SwiftUI

struct Question3View: View {
    var onNext: () -> Void
    @EnvironmentObject var vm: SetupFlowViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage(AppStorageKeys.unitType) private var persistedUnitType: String = "metric"
    @State private var selected: String? = "Metric"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 5){
                Text("Question").font(AppFonts.regular(size: 15)).foregroundColor(AppTheme.textTertiary)
                Text("3/3").font(AppFonts.regular(size: 15)).foregroundColor(AppTheme.primary)
                Spacer()
            }
            .padding(.top, 20)
            
            Text("Select your preferred measurement units:")
                .font(AppFonts.bold(size: 28))
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(2)
            
            VStack(spacing: 16) {
                OptionRow(
                    title: "Metric",
                    subtitle: "(meters, km/h, hectares)",
                    icon: "ic_web",
                    isSelected: selected == "Metric"
                ) {
                    selected = "Metric"
                }
                
                OptionRow(
                    title: "Imperial",
                    subtitle: "(feet, mph, acres)",
                    icon: "ic_dashboard",
                    isSelected: selected == "Imperial"
                ) {
                    selected = "Imperial"
                }
            }
            
            Spacer()
            
            Button(action: {
                vm.question3 = selected
                // Persist to shared unitType key so Settings reflects immediately
                if selected == "Imperial" {
                    persistedUnitType = "imperial"
                } else if selected == "Metric" {
                    persistedUnitType = "metric"
                }
                onNext()
            }) {
                Text("Next")
                    .font(AppFonts.medium(size: 20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.primary)
                    .cornerRadius(10)
                    .transition(.opacity)
                    .padding(.bottom, 2)
            }
            .disabled(selected == nil)
        }
        .padding(20)
        .background(AppTheme.backgroundQuestion.ignoresSafeArea())
        .themeAware()
    }
}

struct OptionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            // bounce animation
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                scale = 1.05
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
            
            action()
        }) {
            HStack(spacing: 12) {
                Image(icon)
                    .frame(width: 44, height: 44)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppFonts.semiBold(size: 17))
                        .foregroundColor(AppTheme.textPrimary)
                    Text(subtitle)
                        .font(AppFonts.regular(size: 13))
                        .foregroundColor(AppTheme.textTertiary)
                }
                Spacer()
                
                Image(isSelected ? "ticked" : "untick")
            }
            .padding()
            .background(AppTheme.surfaceBox)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? AppTheme.primary : Color.clear, lineWidth: 2)
            )
            .scaleEffect(scale)
            .zIndex(isSelected ? 1 : 0)
        }
        .buttonStyle(.plain)
        .padding(.vertical, 2) // chừa chỗ cho scale
    }
}
