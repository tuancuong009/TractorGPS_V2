//
//  AppState.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 16/9/25.
//


import SwiftUI

class AppState: ObservableObject {
    @Published var hasAccess: Bool
    
    init() {
        self.hasAccess = UserDefaults.isPremium
    }
}
