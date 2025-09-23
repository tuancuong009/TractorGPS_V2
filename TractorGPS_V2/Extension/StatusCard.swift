//
//  StatusCard.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 17/9/25.
//

import SwiftUI
struct StatusCard: View {
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5){
            HStack{
                Image(icon)
                Text(value).textCase(.uppercase)
                    .font(AppFonts.semiBold(size: 22)).foregroundColor(.white)
            }
            VStack() {
                Text(unit).textCase(.uppercase)
                    .font(AppFonts.medium(size: 15)).foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(12)
        .frame(minWidth: 140)
        .padding(.vertical, 10)
        .background(
            ZStack {
                    // Blur glass effect
                VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    
                    // Nền đen mờ
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.black.opacity(0.3))
                    
                    // Viền gradient
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.6),
                                    .white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
        )
        .padding(.top, 50)
    }
}
