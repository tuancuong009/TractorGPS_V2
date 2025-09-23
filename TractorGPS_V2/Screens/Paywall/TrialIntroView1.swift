//
//  TrialIntroView1.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 16/9/25.
//


import SwiftUI
struct TrialIntroView1: View {
    @ObservedObject var appState: AppState
    var body: some View {
        NavigationStack{
            VStack {
                Spacer()
                
                Text("We offer\n")
                    .font(AppFonts.semiBold(size: 28))
                    .foregroundColor(AppTheme.textPrimary)
                    +
                Text("3 Days Free\n")
                    .font(AppFonts.semiBold(size: 28))
                    .foregroundColor(AppTheme.paywall)
                    +
                Text("so everyone can\nfarm with FieldTrac")
                    .font(AppFonts.semiBold(size: 28))
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                NavigationLink(destination: TrialIntroView2(appState: appState)) {
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
        }
        
    }
}




