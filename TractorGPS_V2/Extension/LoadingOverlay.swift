//
//  LoadingOverlay.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 19/9/25.
//


import SwiftUI

struct LoadingOverlay: View {
    var text: String = "Restoring Purchase..."
    
    var body: some View {
        ZStack {
            // Background mờ
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2) // phóng to vòng xoay
                
                Text(text)
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .padding(40)
            .background(Color.black.opacity(0.6))
            .cornerRadius(16)
        }
    }
}

