//
//  ThemeManager.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 15/9/25.
//

import SwiftUI

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = false
    @AppStorage(AppStorageKeys.themeMode) var themeMode: String = "System" // System | Light | Dark
    
    init() {
        // Initialize from persisted preference
        applyThemeMode(themeMode)
    }
    
    func toggleTheme() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isDarkMode.toggle()
            themeMode = isDarkMode ? "Dark" : "Light"
        }
    }
    
    func setTheme(_ isDark: Bool) {
        withAnimation(.easeInOut(duration: 0.3)) {
            isDarkMode = isDark
            themeMode = isDark ? "Dark" : "Light"
        }
    }
    
    func setThemeMode(_ mode: String) {
        withAnimation(.easeInOut(duration: 0.25)) {
            themeMode = mode
            applyThemeMode(mode)
        }
    }
    
    private func applyThemeMode(_ mode: String) {
        switch mode {
        case "Light":
            isDarkMode = false
        case "Dark":
            isDarkMode = true
        default:
            // Follow system
            isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
        }
    }
}

// MARK: - Theme Colors
struct AppTheme {
    // Primary Colors
    static let primary = Color("ColorMain")
    static let primaryDark = Color("ColorMainDark")
    
    // Background Colors
    static let background = Color("Background")
    static let backgroundQuestion = Color("BackgroundQuestion")
    static let backgroundSecondary = Color("BackgroundSecondary")
    static let backgroundTertiary = Color("BackgroundTertiary")
    
    // Text Colors
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    static let textTertiary = Color("TextTertiary")
    
    // Surface Colors
    static let surface = Color("Surface")
    static let surfaceSecondary = Color("SurfaceSecondary")
    static let surfaceSecondary2 = Color("SurfaceSecondary2")
    static let surfaceTertiary = Color("SurfaceTertiary")
    
    // Border Colors
    static let border = Color("Border")
    static let borderSecondary = Color("BorderSecondary")
    
    // Status Colors
    static let success = Color("Success")
    static let warning = Color("Warning")
    static let error = Color("Error")
    static let info = Color("Info")
    
    // Operation Type Colors
    static let harvesting = Color("Harvesting")
    static let plowing = Color("Plowing")
    static let seeding = Color("Seeding")
    static let spraying = Color("Spraying")
    static let other = Color("Other")
    
    // Shadow Colors
    static let shadow = Color("Shadow")
    static let shadowLight = Color("ShadowLight")
    static let paywall = Color("Paywall")
}

// MARK: - Dynamic Color Extension
extension Color {
    static func dynamic(light: Color, dark: Color) -> Color {
        return Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}

// MARK: - Theme-aware View Modifier
struct ThemeAware: ViewModifier {
    @EnvironmentObject var themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        Group {
            if themeManager.themeMode == "System" {
                content
            } else {
                content.preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
            }
        }
    }
}

extension View {
    func themeAware() -> some View {
        self.modifier(ThemeAware())
    }
    
    // Safe theme-aware modifier that doesn't require environment object
    func safeThemeAware() -> some View {
        self
    }
}
