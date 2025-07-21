# Theming Guide

Master the BetterChat theming system to create beautiful, custom chat interfaces.

## Overview

BetterChat's theming system is built around design tokens that provide comprehensive control over the visual appearance of your chat interface. The system is designed to be both powerful and easy to use, with sensible defaults and built-in accessibility support.

## Design Token Architecture

The theming system is organized into five main categories:

1. **Colors** - Primary, secondary, accent, and semantic colors
2. **Spacing** - Consistent spacing values for layout
3. **Typography** - Font sizes and styles
4. **Layout** - Component dimensions and constraints
5. **Animation** - Timing and easing for smooth transitions

## Built-in Themes

BetterChat includes five carefully crafted themes:

### Light Theme (Orange)
```swift
.chatTheme(.light)
```
- **Primary Color**: Orange
- **Best For**: Energetic, friendly conversations
- **Accessibility**: High contrast, light mode optimized

### Dark Theme (Purple)
```swift
.chatTheme(.dark)
```
- **Primary Color**: Purple
- **Best For**: Evening use, reduced eye strain
- **Accessibility**: Dark mode optimized, OLED friendly

### Blue Theme (Classic)
```swift
.chatTheme(.blue)
```
- **Primary Color**: Blue
- **Best For**: Professional, trustworthy appearance
- **Accessibility**: High contrast, universally readable

### Green Theme (Nature)
```swift
.chatTheme(.green)
```
- **Primary Color**: Green
- **Best For**: Calming, nature-inspired interfaces
- **Accessibility**: Suitable for most color vision types

### Minimal Theme (Gray)
```swift
.chatTheme(.minimal)
```
- **Primary Color**: Gray
- **Best For**: Clean, distraction-free interfaces
- **Accessibility**: Maximum focus on content

## Creating Custom Themes

### Basic Color Customization

```swift
let customTheme = ChatDesignTokens(
    colors: ChatColors(
        primary: .purple,
        accent: .purple,
        background: Color(.systemBackground),
        surface: Color(.secondarySystemBackground)
    )
)

ModernChatView(dataSource: dataSource)
    .chatTheme(customTheme)
```

### Advanced Theme Creation

```swift
let brandTheme = ChatDesignTokens(
    colors: ChatColors(
        primary: Color("BrandPrimary"),
        secondary: Color("BrandSecondary"),
        background: Color("BrandBackground"),
        surface: Color("BrandSurface"),
        text: Color("BrandText"),
        textSecondary: Color("BrandTextSecondary"),
        accent: Color("BrandAccent"),
        error: Color("BrandError"),
        success: Color("BrandSuccess")
    ),
    spacing: ChatSpacing(
        xs: 2, sm: 6, md: 12, lg: 18, xl: 24, xxl: 30
    ),
    layout: ChatLayout(
        cornerRadius: 16,
        bubbleMaxWidth: 300,
        minInputHeight: 40
    ),
    animation: ChatAnimation(
        fast: 0.15,
        medium: 0.25,
        slow: 0.4
    )
)
```

## Dynamic Theme Switching

### Real-time Theme Changes

```swift
struct ChatView: View {
    @State private var selectedTheme: ChatThemePreset = .blue
    @StateObject private var dataSource = DemoDataSource()
    
    var body: some View {
        VStack {
            ThemeSelector(selectedTheme: $selectedTheme)
            
            ModernChatView(dataSource: dataSource)
                .chatTheme(selectedTheme)
                .animation(.easeInOut(duration: 0.3), value: selectedTheme)
        }
    }
}

struct ThemeSelector: View {
    @Binding var selectedTheme: ChatThemePreset
    
    var body: some View {
        HStack {
            ForEach([.light, .dark, .blue, .green, .minimal], id: \.self) { theme in
                Button(themeName(for: theme)) {
                    withAnimation {
                        selectedTheme = theme
                    }
                }
                .buttonStyle(ThemeButtonStyle(
                    isSelected: selectedTheme == theme,
                    themeColor: themeColor(for: theme)
                ))
            }
        }
    }
}
```

### Persistent Theme Storage

```swift
class ThemeManager: ObservableObject {
    @Published var currentTheme: ChatThemePreset {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
        }
    }
    
    init() {
        let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme")
        self.currentTheme = ChatThemePreset(rawValue: savedTheme) ?? .blue
    }
}
```

## Accessibility Considerations

### Color Contrast

Ensure your custom themes meet accessibility standards:

```swift
let accessibleTheme = ChatDesignTokens(
    colors: ChatColors(
        // Use colors with at least 4.5:1 contrast ratio
        primary: Color(red: 0.0, green: 0.3, blue: 0.7), // WCAG AA compliant
        background: .white,
        text: .black // High contrast for readability
    )
)
```

### System Preference Support

```swift
struct AdaptiveThemeView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var adaptiveTheme: ChatDesignTokens {
        switch colorScheme {
        case .dark:
            return .dark
        case .light:
            return .light
        @unknown default:
            return .blue
        }
    }
    
    var body: some View {
        ModernChatView(dataSource: dataSource)
            .chatTheme(adaptiveTheme)
    }
}
```

### Dynamic Type Support

```swift
let accessibleTypography = ChatTypography(
    body: .body,
    caption: .caption,
    headline: .headline,
    footnote: .footnote
)

// Fonts automatically scale with user's text size preferences
```

## Brand Integration

### Using Brand Colors

```swift
extension Color {
    static let brandPrimary = Color("BrandPrimary")
    static let brandSecondary = Color("BrandSecondary")
    static let brandAccent = Color("BrandAccent")
}

let brandTheme = ChatDesignTokens(
    colors: ChatColors(
        primary: .brandPrimary,
        accent: .brandAccent,
        // Use semantic system colors for better integration
        background: Color(.systemBackground),
        surface: Color(.secondarySystemBackground),
        text: Color(.label),
        textSecondary: Color(.secondaryLabel)
    )
)
```

### Corporate Theme Example

```swift
let corporateTheme = ChatDesignTokens(
    colors: ChatColors(
        primary: Color(red: 0.0, green: 0.2, blue: 0.4), // Corporate blue
        secondary: Color(red: 0.95, green: 0.95, blue: 0.97),
        background: .white,
        surface: Color(red: 0.98, green: 0.98, blue: 0.99),
        text: Color(red: 0.1, green: 0.1, blue: 0.1),
        textSecondary: Color(red: 0.4, green: 0.4, blue: 0.4),
        accent: Color(red: 0.0, green: 0.6, blue: 0.8),
        error: Color(red: 0.8, green: 0.0, blue: 0.0),
        success: Color(red: 0.0, green: 0.6, blue: 0.0)
    ),
    spacing: ChatSpacing(
        xs: 4, sm: 8, md: 16, lg: 24, xl: 32, xxl: 40
    ),
    layout: ChatLayout(
        cornerRadius: 8, // More conservative rounding
        bubbleMaxWidth: 400, // Wider for desktop use
        minInputHeight: 44 // Touch-friendly sizing
    )
)
```

## Advanced Customization

### Custom View Modifiers

```swift
struct BrandBubbleModifier: ViewModifier {
    let role: BubbleRole
    
    func body(content: Content) -> some View {
        content
            .chatBubble(role: role, shape: .rounded)
            .overlay(
                // Add brand-specific elements
                brandWatermark,
                alignment: .bottomTrailing
            )
    }
    
    private var brandWatermark: some View {
        Image("BrandMark")
            .resizable()
            .frame(width: 12, height: 12)
            .opacity(0.3)
            .padding(4)
    }
}

extension View {
    func brandBubble(role: BubbleRole) -> some View {
        modifier(BrandBubbleModifier(role: role))
    }
}
```

### Theme-aware Components

```swift
struct ThemedHeader: View {
    @Environment(\.chatTheme) private var theme
    
    var body: some View {
        HStack {
            Image(systemName: "message.circle")
                .foregroundColor(theme.colors.accent)
            
            Text("Chat")
                .font(theme.typography.headline)
                .foregroundColor(theme.colors.text)
            
            Spacer()
        }
        .padding(theme.spacing.md)
        .background(theme.colors.surface)
    }
}
```

## Performance Considerations

### Efficient Theme Updates

```swift
// ✅ Good: Animate theme changes smoothly
withAnimation(.easeInOut(duration: theme.animation.medium)) {
    selectedTheme = newTheme
}

// ❌ Avoid: Frequent theme changes without animation
selectedTheme = newTheme // Can cause jarring transitions
```

### Memory Management

```swift
// ✅ Good: Use static theme definitions
static let companyTheme = ChatDesignTokens(...)

// ❌ Avoid: Creating themes repeatedly
func makeTheme() -> ChatDesignTokens {
    return ChatDesignTokens(...) // Creates new instance each time
}
```

## Testing Themes

### Preview Different Themes

```swift
#Preview("Light Theme") {
    ModernChatView(dataSource: DemoDataSource())
        .chatTheme(.light)
}

#Preview("Dark Theme") {
    ModernChatView(dataSource: DemoDataSource())
        .chatTheme(.dark)
        .preferredColorScheme(.dark)
}

#Preview("Custom Theme") {
    ModernChatView(dataSource: DemoDataSource())
        .chatTheme(customBrandTheme)
}
```

### Accessibility Testing

```swift
#Preview("Large Text") {
    ModernChatView(dataSource: DemoDataSource())
        .chatTheme(.blue)
        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}

#Preview("High Contrast") {
    ModernChatView(dataSource: DemoDataSource())
        .chatTheme(highContrastTheme)
        .environment(\.accessibilityReduceTransparency, true)
}
```

## Best Practices

1. **Start with Built-ins**: Use existing themes as a foundation
2. **Test Accessibility**: Ensure proper contrast and Dynamic Type support
3. **Be Consistent**: Use theme tokens throughout your app
4. **Performance First**: Avoid creating themes in view bodies
5. **User Choice**: Allow users to select their preferred theme
6. **System Integration**: Respect system appearance preferences

## Common Pitfalls

### Hard-coded Colors
```swift
// ❌ Avoid
Text("Message")
    .foregroundColor(.blue) // Hard-coded color

// ✅ Better
Text("Message")
    .foregroundColor(theme.colors.accent) // Theme-aware
```

### Inconsistent Spacing
```swift
// ❌ Avoid
VStack(spacing: 8) { ... } // Magic number

// ✅ Better
VStack(spacing: theme.spacing.sm) { ... } // Consistent spacing
```

### Theme Creation in Views
```swift
// ❌ Avoid
var body: some View {
    let customTheme = ChatDesignTokens(...) // Created on every render
    ModernChatView(dataSource: dataSource)
        .chatTheme(customTheme)
}

// ✅ Better
static let customTheme = ChatDesignTokens(...) // Created once

var body: some View {
    ModernChatView(dataSource: dataSource)
        .chatTheme(Self.customTheme)
}
```