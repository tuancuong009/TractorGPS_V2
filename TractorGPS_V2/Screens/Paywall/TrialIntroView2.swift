//
//  TrialIntroView2.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 16/9/25.
//

import SwiftUI
struct TrialIntroView2: View {
    @ObservedObject var appState: AppState
    var body: some View {
        VStack {
            Spacer()
            
            Text("You'll get a\n")
                .font(AppFonts.semiBold(size: 28))
                .foregroundColor(AppTheme.textPrimary)
            +
            Text("reminder ")
                .font(AppFonts.semiBold(size: 28))
                .foregroundColor(AppTheme.textPrimary)
            
                +
            Text("before\n")
                .font(AppFonts.semiBold(size: 28))
                .foregroundColor(AppTheme.paywall)
                +
            Text("your trial ends.")
                .font(AppFonts.semiBold(size: 28))
                .foregroundColor(AppTheme.textPrimary)
            Spacer()
            
            Image("icNotification")
                .resizable()
                .frame(width: 180, height: 180)
                .scaledToFit()
            
            Spacer()
            
            NavigationLink(destination: TrialIntroView3(appState: appState)) {
                HStack {
                    Spacer()
                    Text("Try for Free 🙌🏼")
                        .foregroundColor(.white).multilineTextAlignment(.center)
                        .font(AppFonts.semiBold(size: 20))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.init(hex: "269832"))
                .cornerRadius(12)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .multilineTextAlignment(.center)
        .background(AppTheme.background)
        .toolbar(.hidden, for: .navigationBar)
    }
}
