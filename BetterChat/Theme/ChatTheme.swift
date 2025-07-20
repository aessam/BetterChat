import SwiftUI

// MARK: - Design Tokens
public struct ChatDesignTokens {
    public var colors: ChatColors
    public var spacing: ChatSpacing
    public var typography: ChatTypography
    public var layout: ChatLayout
    public var animation: ChatAnimation
    
    public init(
        colors: ChatColors = .default,
        spacing: ChatSpacing = .default,
        typography: ChatTypography = .default,
        layout: ChatLayout = .default,
        animation: ChatAnimation = .default
    ) {
        self.colors = colors
        self.spacing = spacing
        self.typography = typography
        self.layout = layout
        self.animation = animation
    }
}

// MARK: - Color System
public struct ChatColors {
    public var primary: Color
    public var secondary: Color
    public var background: Color
    public var surface: Color
    public var text: Color
    public var textSecondary: Color
    public var accent: Color
    public var error: Color
    public var success: Color
    
    public init(
        primary: Color = .blue,
        secondary: Color = Color(.secondarySystemBackground),
        background: Color = Color(.systemBackground),
        surface: Color = Color(.tertiarySystemBackground),
        text: Color = .primary,
        textSecondary: Color = .secondary,
        accent: Color = .blue,
        error: Color = .red,
        success: Color = .green
    ) {
        self.primary = primary
        self.secondary = secondary
        self.background = background
        self.surface = surface
        self.text = text
        self.textSecondary = textSecondary
        self.accent = accent
        self.error = error
        self.success = success
    }
    
    public static let `default` = ChatColors()
    
    public static let light = ChatColors(
        primary: .orange,
        accent: .orange
    )
    
    public static let dark = ChatColors(
        primary: .purple,
        secondary: Color(.systemGray5),
        background: Color(.systemGray6),
        surface: Color(.systemGray4),
        accent: .purple
    )
    
    public static let minimal = ChatColors(
        primary: Color(.systemGray),
        accent: Color(.systemGray)
    )
}

// MARK: - Spacing System
public struct ChatSpacing {
    public var xs: CGFloat = 4
    public var sm: CGFloat = 8
    public var md: CGFloat = 12
    public var lg: CGFloat = 16
    public var xl: CGFloat = 20
    public var xxl: CGFloat = 24
    
    public static let `default` = ChatSpacing()
}

// MARK: - Typography System
public struct ChatTypography {
    public var body: Font = .body
    public var caption: Font = .caption
    public var headline: Font = .headline
    public var footnote: Font = .footnote
    
    public static let `default` = ChatTypography()
}

// MARK: - Layout System
public struct ChatLayout {
    public var cornerRadius: CGFloat = 18
    public var smallCornerRadius: CGFloat = 8
    public var minInputHeight: CGFloat = 34
    public var maxInputHeight: CGFloat = 100
    public var bubbleMaxWidth: CGFloat = 280
    
    public static let `default` = ChatLayout()
}

// MARK: - Animation System
public struct ChatAnimation {
    public var fast: Double = 0.2
    public var medium: Double = 0.3
    public var slow: Double = 0.5
    
    public static let `default` = ChatAnimation()
}

// MARK: - Environment Keys
private struct ChatDesignTokensKey: EnvironmentKey {
    static let defaultValue = ChatDesignTokens()
}

extension EnvironmentValues {
    public var chatTheme: ChatDesignTokens {
        get { self[ChatDesignTokensKey.self] }
        set { self[ChatDesignTokensKey.self] = newValue }
    }
}

// MARK: - Theme Presets
public extension ChatDesignTokens {
    static let light = ChatDesignTokens(colors: .light)
    
    static let dark = ChatDesignTokens(colors: .dark)
    
    static let minimal = ChatDesignTokens(colors: .minimal)
    
    static let blue = ChatDesignTokens(
        colors: ChatColors(
            primary: .blue,
            accent: .blue
        )
    )
    
    static let green = ChatDesignTokens(
        colors: ChatColors(
            primary: .green,
            accent: .green
        )
    )
}

// MARK: - View Extension for Theme Application
public extension View {
    func chatTheme(_ theme: ChatDesignTokens) -> some View {
        environment(\.chatTheme, theme)
    }
    
    func chatTheme(_ preset: ChatThemePreset) -> some View {
        let theme: ChatDesignTokens
        switch preset {
        case .light: theme = .light
        case .dark: theme = .dark
        case .minimal: theme = .minimal
        case .blue: theme = .blue
        case .green: theme = .green
        }
        return environment(\.chatTheme, theme)
    }
}

// MARK: - Theme Presets Enum
public enum ChatThemePreset {
    case light
    case dark
    case minimal
    case blue
    case green
}