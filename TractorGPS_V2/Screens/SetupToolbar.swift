//
//  SetupToolbar.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 15/9/25.
//


import SwiftUI

struct SetupToolbar: View {
    var title: String = "Setup"
    var progress: Double // 0.0 -> 1.0
    var onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(AppFonts.regular(size: 17))
                    .foregroundColor(AppTheme.primary)
                }
                
                Spacer()
                
                Text(title)
                    .font(AppFonts.semiBold(size: 17))
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                // giữ chỗ để cân đối
                Color.clear.frame(width: 60, height: 1)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 20)
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .colorMain))
                .padding(.horizontal)
        }
        .background(Color.clear)
    }
}
