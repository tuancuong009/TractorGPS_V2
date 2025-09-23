//
//  LoadingSetupView.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 15/9/25.
//

import SwiftUI
struct LoadingSetupView: View {
    var onNext: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("We’re setting everything up for you...")
                .font(AppFonts.bold(size: 22)).foregroundColor(AppTheme.textPrimary).multilineTextAlignment(.center)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.primary))
                .scaleEffect(1.5)
            Spacer()
        }.background(AppTheme.backgroundQuestion.ignoresSafeArea())
        .themeAware()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                onNext()
            }
        }
        .padding()
    }
}
