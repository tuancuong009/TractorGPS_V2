//
//  AppView.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 15/9/25.
//

import SwiftUI
struct AppView: View {
    //@State private var showWelcome = false
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationStack{
//            if showWelcome {
//                WelcomeView()
//                    .transition(.move(edge: .trailing))
//            } else {
//                SplashScreen {
//                    withAnimation {
//                        showWelcome = true
//                    }
//                }
//            }
            WelcomeView()
                .transition(.move(edge: .trailing))
        }
        .themeAware()
    }
}
