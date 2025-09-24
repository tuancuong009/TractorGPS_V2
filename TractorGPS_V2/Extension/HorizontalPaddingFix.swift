//
//  HorizontalPaddingFix.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 24/9/25.
//

import SwiftUI
struct HorizontalPaddingFix: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 18, *) {
            content // iOS 18 trở lên: không padding
        } else {
            content.padding(.horizontal, 20) // iOS 17 trở xuống
        }
    }
}
