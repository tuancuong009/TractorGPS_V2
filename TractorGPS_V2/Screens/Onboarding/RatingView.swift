//
//  RatingView.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 15/9/25.
//

import SwiftUI
import StoreKit
struct RatingView: View {
    var onNext: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 24) {
            Image("imgRate").padding(.top, 20)
            Image("title_helpus")
            Text("Your early support makes a big difference. A simple rating helps us grow faster and reach more people like you.")
                .font(AppFonts.regular(size: 20)).multilineTextAlignment(.center).foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal)
            
            Spacer()
            
            Button(action:
                   
                    onNext
            ) {
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
        }
        .onAppear(perform: {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        })
        .padding(20)
        .background(AppTheme.backgroundQuestion.ignoresSafeArea())
        .themeAware()
    }
}
