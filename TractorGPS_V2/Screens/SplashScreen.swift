//
//  SplashScreen.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 15/9/25.
//

import SwiftUI
struct SplashScreen: View {
    var onFinish: () -> Void
    var body: some View {
        ZStack {
            Image("splash").resizable().ignoresSafeArea()
            VStack {
                Image("logo_small")
                    .resizable()
                    .frame(width: 130, height: 130)
                Text("FieldTrac")
                    .font(AppFonts.bold(size: 40))
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                onFinish()
            }
        }
    }
}
