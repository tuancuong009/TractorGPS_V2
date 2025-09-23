//
//  TractorGPS_V2App.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 5/9/25.
//

import SwiftUI

@main
struct TractorGPS_V2App: App {
    @StateObject private var vm = SetupFlowViewModel()
    @AppStorage(AppStorageKeys.hasCompletedSetup) private var hasCompletedSetup = false
    @StateObject private var appState = AppState()
    @StateObject private var themeManager = ThemeManager()
    
    init() {
      
        print("👉 hasCompletedSetup at launch:", UserDefaults.standard.bool(forKey: AppStorageKeys.hasCompletedSetup))
    }
    var body: some Scene {
        WindowGroup {
            if hasCompletedSetup {
                if appState.hasAccess {
                    MainAppView()
                        .environmentObject(vm)
                        .environmentObject(themeManager)
                } else {
                    TrialIntroView1(appState: appState) .environmentObject(vm)
                      .environmentObject(themeManager)
//                    MainAppView()
//                        .environmentObject(vm)
//                        .environmentObject(themeManager)
                }
                
            }
            else{
                AppView()
                    .environmentObject(vm)
                    .environmentObject(themeManager)
            }
            
        }
    }
}
