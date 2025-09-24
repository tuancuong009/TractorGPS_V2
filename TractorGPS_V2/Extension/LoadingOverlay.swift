//
//  LoadingOverlay 2.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 24/9/25.
//


import SwiftUI

struct LoadingOverlay: View {
    let message: String
    @Binding var isShowing: Bool

    var body: some View {
        if isShowing {
            ZStack {
                // 1) Nền blur/visual effect (fills whole screen)
                // Use material for adaptive blur that respects Dark/Light
                Rectangle()
                    .foregroundStyle(.ultraThinMaterial) // thích ứng Dark/Light
                    .ignoresSafeArea()
                    .transition(.opacity)

                // 2) Dim layer so content behind is darker for emphasis
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .transition(.opacity)

                // 3) Content box
                VStack(spacing: 14) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.3)
                        // Tint adapts automatically in iOS 15+: use primary color
                        .tint(Color.primary)

                    Text(message)
                        .font(AppFonts.regular(size: 17))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                }
                .padding(20)
//                .background {
//                    // Small frosted rounded rectangle to contain spinner + text
//                    RoundedRectangle(cornerRadius: 14, style: .continuous)
//                        .foregroundStyle(.regularMaterial) // slightly stronger material
//                }
//                .overlay(
//                    RoundedRectangle(cornerRadius: 14, style: .continuous)
//                        .stroke(Color.primary.opacity(0.06), lineWidth: 0.5)
//                )
                .padding(.horizontal, 40)
                .shadow(color: Color.black.opacity(0.25), radius: 20, x: 0, y: 8)
                .transition(.scale)
            }
            .animation(.easeInOut(duration: 0.2), value: isShowing)
        }
    }
}
