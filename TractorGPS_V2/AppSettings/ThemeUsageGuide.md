# Theme System Usage Guide

## Overview
The app now supports both light and dark themes with a centralized theme management system. This guide explains how to use the new theme system throughout the app.

## Theme Manager
The `ThemeManager` class handles theme switching and is available as an environment object throughout the app.

### Key Features:
- Automatic system appearance detection
- Smooth theme transitions
- Centralized theme state management

## Color System
All colors are now defined in the `AppTheme` struct and automatically adapt to light/dark modes.

### Available Color Categories:

#### Background Colors
- `AppTheme.background` - Main background color
- `AppTheme.backgroundSecondary` - Secondary background
- `AppTheme.backgroundTertiary` - Tertiary background

#### Text Colors
- `AppTheme.textPrimary` - Primary text color
- `AppTheme.textSecondary` - Secondary text color
- `AppTheme.textTertiary` - Tertiary text color

#### Surface Colors
- `AppTheme.surface` - Main surface color
- `AppTheme.surfaceSecondary` - Secondary surface
- `AppTheme.surfaceTertiary` - Tertiary surface

#### Status Colors
- `AppTheme.success` - Success states
- `AppTheme.warning` - Warning states
- `AppTheme.error` - Error states
- `AppTheme.info` - Information states

#### Operation Type Colors
- `AppTheme.harvesting` - Harvesting operations
- `AppTheme.plowing` - Plowing operations
- `AppTheme.seeding` - Seeding operations
- `AppTheme.spraying` - Spraying operations
- `AppTheme.other` - Other operations

## Usage Examples

### Basic Text Styling
```swift
Text("Hello World")
    .foregroundColor(AppTheme.textPrimary)
    .background(AppTheme.background)
```

### Button Styling
```swift
Button("Action") {
    // Action
}
.foregroundColor(.white)
.background(AppTheme.primary)
```

### Theme-Aware Views
```swift
struct MyView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack {
            // Your content
        }
        .background(AppTheme.background)
        .themeAware() // Apply theme-aware modifier
    }
}
```

### Theme Toggle
```swift
Button(action: {
    themeManager.toggleTheme()
}) {
    Image(systemName: themeManager.isDarkMode ? "sun.max.fill" : "moon.fill")
}
```

## Migration Guide

### Replacing Hardcoded Colors
Replace hardcoded colors with theme-aware colors:

**Before:**
```swift
.foregroundColor(.black)
.background(Color.white)
```

**After:**
```swift
.foregroundColor(AppTheme.textPrimary)
.background(AppTheme.surface)
```

### Replacing Hex Colors
Replace hex color usage with theme colors:

**Before:**
```swift
.foregroundColor(Color.init(hex: "3C3C43"))
.background(Color.init(hex: "F7F6F2"))
```

**After:**
```swift
.foregroundColor(AppTheme.textSecondary)
.background(AppTheme.background)
```

## Best Practices

1. **Always use theme colors** instead of hardcoded colors
2. **Apply `.themeAware()` modifier** to views that need theme support
3. **Use semantic color names** (textPrimary, background, etc.) instead of specific colors
4. **Test both light and dark modes** during development
5. **Use the theme toggle** in the toolbar to test theme switching

## Color Assets
All colors are defined in the Assets.xcassets/Colors folder with both light and dark variants. The system automatically selects the appropriate variant based on the current theme.

## Theme Toggle Location
The theme toggle button is located in the toolbar (top-right corner) and allows users to switch between light and dark modes.
