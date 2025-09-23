//
//  SafeAreaInsetsKey.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 15/9/25.
//

import SwiftUI
struct SafeAreaInsetsKey: EnvironmentKey {
    static let defaultValue: EdgeInsets = EdgeInsets()
}

extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        get { self[SafeAreaInsetsKey.self] }
        set { self[SafeAreaInsetsKey.self] = newValue }
    }
}

struct SafeAreaInsetsReader: ViewModifier {
    @State private var insets: EdgeInsets = EdgeInsets()
    
    func body(content: Content) -> some View {
        GeometryReader { proxy in
            content
                .environment(\.safeAreaInsets, proxy.safeAreaInsets)
        }
    }
}

extension View {
    func injectSafeAreaInsets() -> some View {
        self.modifier(SafeAreaInsetsReader())
    }
}
