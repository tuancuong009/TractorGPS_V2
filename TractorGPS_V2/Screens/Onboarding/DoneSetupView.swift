//
//  DoneSetupView.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 15/9/25.
//

import SwiftUI

struct DoneSetupView: View {
    @AppStorage(AppStorageKeys.hasCompletedSetup) private var hasCompletedSetup = false
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            Image("bgDoneSetup").resizable().ignoresSafeArea()
            VStack(alignment: .center, spacing: 10) {
                Image("donesetup")
                Text("You’re all set!")
                    .font(AppFonts.bold(size: 28)).foregroundColor(AppTheme.textPrimary)
                Text("Maximize your farm’s efficiency with\nprecision GPS navigation.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .font(AppFonts.regular(size: 15))
                    .foregroundColor(AppTheme.textTertiary)
                Spacer()
                
                Button(action: {
                    hasCompletedSetup = true
                    print("✅ Saved:", hasCompletedSetup)
                }) {
                    Text("Get Started")
                        .font(AppFonts.medium(size: 20))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.primary)
                        .cornerRadius(10)
                        .transition(.opacity)
                        .padding(.bottom, 2)
                }.padding(.horizontal, 20)
            }.padding(.horizontal, 20)
        }
        .themeAware()
        .onAppear {
           
        }
    }
}
