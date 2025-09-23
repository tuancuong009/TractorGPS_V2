//
//  WelcomeView.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 15/9/25.
//

import SwiftUI
struct WelcomeView: View {
    @StateObject private var safariManager = SafariManager.shared
    var body: some View {
        NavigationStack() {
            ZStack{
                AppTheme.background.ignoresSafeArea()
                VStack {
                    Spacer()
                    
                    // Title + subtitle
                    VStack(alignment: .leading, spacing: 8) {
                        Text("FieldTrac")
                            .font(AppFonts.bold(size: 34))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("Maximize your farm's efficiency with precision GPS navigation.")
                            .font(AppFonts.regular(size: 17))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    
                    // Image mockup
                    ZStack {
                        Image("car")
                            .resizable()
                            .scaledToFit()
                        
                        
                    }
                    .padding(.vertical, 20)
                    
                    Spacer()
                    
                    NavigationLink(destination: ReasonsView()) {
                        Text("Get Started")
                            .font(AppFonts.medium(size: 20))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.primary)
                            .cornerRadius(10)
                            .transition(.opacity)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 12)
                        
                    }
                    // Terms & Privacy clickable
                    VStack {
                        Text("By clicking \"Get Started\" you agree to FieldTrac's")
                            .font(AppFonts.regular(size: 14))
                            .foregroundColor(AppTheme.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: 4) {
                            LinkText(title: "Terms of Service", url: AppSettings.TERMS)
                            Text("and")
                                .foregroundColor(AppTheme.textPrimary)
                            LinkText(title: "Privacy Policy", url: AppSettings.PRIVACY)
                        }
                        .font(AppFonts.regular(size: 14))
                        .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(item: $safariManager.safariURL) { safariURL in
            SafariView(url: safariURL.url)
        }
        
    }
}

