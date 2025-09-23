//
//  AppStorageKeys.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 15/9/25.
//


enum AppStorageKeys {
    static let hasCompletedSetup = "hasCompletedSetup"
    // Settings
    static let mapType = "settings.mapType"              // "Default" | "Satellite" | "Hybrid"
    static let trackWidth = "settings.trackWidth"        // Int (feet or meters depending on unit)
    static let polygonColorHex = "settings.polygonColor" // Hex string, e.g. #00FF00
    static let unitType = "settings.unitType"            // "metric" | "imperial"
    static let themeMode = "settings.themeMode"          // "System" | "Light" | "Dark"
    
    // Onboarding persisted answers
    static let onboardingWorkType = "onboarding.workType"      // e.g. "Field Plowing"
    static let onboardingFieldSize = "onboarding.fieldSize"    // e.g. "Small (<10 acres)"
}
