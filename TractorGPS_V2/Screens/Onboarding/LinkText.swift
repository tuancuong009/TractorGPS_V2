//
//  LinkText.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 19/9/25.
//
import SwiftUI

struct LinkText: View {
    let title: String
    let url: String
    @StateObject private var safariManager = SafariManager.shared
    @State private var isPressed = false
    
    var body: some View {
        Text(title)
            .foregroundColor(isPressed ? AppTheme.primary.opacity(0.5) : AppTheme.primary)
            .onTapGesture {
                safariManager.open(url)
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        withAnimation(.easeIn(duration: 0.1)) {
                            isPressed = true
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.easeOut(duration: 0.1)) {
                            isPressed = false
                        }
                    }
            ).sheet(item: $safariManager.safariURL) { safariURL in
                SafariView(url: safariURL.url)
            }
    }
}
