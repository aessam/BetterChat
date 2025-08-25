import SwiftUI

/// A comprehensive design system for BetterChat theming.
///
/// `ChatDesignTokens` provides a complete set of design tokens that control
/// the visual appearance of the chat interface. It includes colors, spacing,
/// typography, layout parameters, and animation settings.
///
/// ## Usage
///
/// Create a custom theme:
/// ```swift
/// let customTheme = ChatDesignTokens(
///     colors: ChatColors(
///         primary: .purple,
///         accent: .purple
///     ),
///     spacing: ChatSpacing(md: 16, lg: 20)
/// )
/// 
/// // Apply to chat view
/// ModernChatView(dataSource: dataSource)
///     .chatTheme(customTheme)
/// ```
///
/// Use built-in presets:
/// ```swift
/// ModernChatView(dataSource: dataSource)
///     .chatTheme(.dark)    // Purple theme
///     .chatTheme(.green)   // Green theme
///     .chatTheme(.minimal) // Gray theme
/// ```
///
/// - Note: All design tokens have sensible defaults and can be partially customized.
/// - Important: Changes to theme tokens are automatically reflected throughout the UI.
public struct ChatDesignTokens {
    /// Color scheme defining the visual appearance.
    public var colors: ChatColors
    
    /// Spacing values for consistent layout.
    public var spacing: ChatSpacing
    
    /// Typography settings for text rendering.
    public var typography: ChatTypography
    
    /// Layout parameters for component sizing.
    public var layout: ChatLayout
    
    /// Animation settings for smooth transitions.
    public var animation: ChatAnimation
    
    /// Creates a new design token set with the specified values.
    ///
    /// - Parameters:
    ///   - colors: Color scheme to use. Defaults to ``ChatColors/default``.
    ///   - spacing: Spacing values. Defaults to ``ChatSpacing/default``.
    ///   - typography: Typography settings. Defaults to ``ChatTypography/default``.
    ///   - layout: Layout parameters. Defaults to ``ChatLayout/default``.
    ///   - animation: Animation settings. Defaults to ``ChatAnimation/default``.
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
        secondary: Color = UnifiedColors.secondaryBackground,
        background: Color = UnifiedColors.background,
        surface: Color = UnifiedColors.tertiaryBackground,
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
        secondary: UnifiedColors.systemGray5,
        background: UnifiedColors.systemGray6,
        surface: UnifiedColors.systemGray4,
        accent: .purple
    )
    
    public static let minimal = ChatColors(
        primary: UnifiedColors.systemGray,
        accent: UnifiedColors.systemGray
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