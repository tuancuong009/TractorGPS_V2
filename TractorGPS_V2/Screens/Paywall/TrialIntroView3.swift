//
//  TrialIntroView3.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 16/9/25.
//
import SwiftUI

struct TrialIntroView3: View {
    @ObservedObject var appState: AppState
    @State private var showToast = false
    var body: some View {
        ScrollView(showsIndicators: false){
            VStack(spacing: 20) {
                
                HStack {
                    Button("Restore") {}
                        .foregroundColor(Color.init(hex: "7B7B7B")).font(AppFonts.medium(size: 12))
                        .padding(.vertical,8).padding(.horizontal,12).background(AppTheme.surfaceTertiary).clipShape(Capsule())
                    Spacer()
                    Menu {
                        Button {
                            print("Need Help tapped")
                        } label: {
                            Label("Need Help?", image: "message")
                        }
                        
                        Divider() // ngăn cách
                        
                        Button("Privacy Policy") {
                            print("Privacy Policy tapped")
                        }
                        
                        Button("Terms of Service") {
                            print("Terms of Service tapped")
                        }
                        
                    } label: {
                        Image(systemName: "ellipsis").frame(width: 36, height: 36)
                            .foregroundColor(Color.init(hex: "7B7B7B")).background(AppTheme.surfaceTertiary).clipShape(Capsule())
                    }
                    
                   
                }
                .padding(.horizontal)
                
                Spacer()
                
                Image("icPaywall")
                    .resizable()
                    .scaledToFit()
                    .padding(.bottom, 10)
                
                Text("3 Days for Free")
                    .font(AppFonts.bold(size: 28))
                    .foregroundColor(AppTheme.paywall)
                
                Text("Then 49.99$ / Year\n(billed annually after trial)")
                    .font(AppFonts.medium(size: 15))
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppTheme.textPrimary)
                    .minimumScaleFactor(0.5)
                Image("rate_paywall")
                
                HStack(spacing: 30) {
                    VStack {
                        Image("icFuel")
                        Text("Fuel\nSaved").font(AppFonts.medium(size: 14))
                            .multilineTextAlignment(.center).minimumScaleFactor(0.5)
                    }
                    
                    Divider().foregroundColor(Color.init(hex: "D9D9D9")).frame(height: 44)
                    VStack {
                        Image("icInput")
                        Text("Inputs\nOptimized").minimumScaleFactor(0.5)
                            .multilineTextAlignment(.center)
                            .font(AppFonts.medium(size: 14))
                    }
                    Divider().foregroundColor(Color.init(hex: "D9D9D9")).frame(height: 44)
                    VStack {
                        Image("icPrice")
                        Text("Bigger\nMargins").minimumScaleFactor(0.5)
                            .multilineTextAlignment(.center)
                            .font(AppFonts.medium(size: 14))
                    }
                }
                .padding(.top, 8)
                
              
                
                Spacer()
                
                HStack{
                    Image("icProtect")
                    Text("No Payment Now. Secured by Apple").minimumScaleFactor(0.5)
                        .font(AppFonts.medium(size: 15))
                        .foregroundColor(AppTheme.textPrimary)
                }
                Button(action: {
                    appState.hasAccess = true
                }) {
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
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
            }
            
        }
        .toast(isShowing: $showToast,
                       message: "Purchase Canceled",
                       systemImage: "xmark.circle.fill",
                       backgroundColor: .red)
        .background(AppTheme.background)
        .toolbar(.hidden, for: .navigationBar)
    }
}
