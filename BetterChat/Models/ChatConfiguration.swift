import SwiftUI

public struct ChatConfiguration {
    public var bubbleStyle: BubbleStyle
    public var inputStyle: InputStyle
    public var generalStyle: GeneralStyle
    
    public init(
        bubbleStyle: BubbleStyle = .init(),
        inputStyle: InputStyle = .init(),
        generalStyle: GeneralStyle = .init()
    ) {
        self.bubbleStyle = bubbleStyle
        self.inputStyle = inputStyle
        self.generalStyle = generalStyle
    }
    
    // MARK: - Convenience Builders
    public static func standard() -> ChatConfiguration {
        return ChatConfiguration()
    }
    
    public static func minimal() -> ChatConfiguration {
        return ChatConfiguration(
            bubbleStyle: .minimal(),
            inputStyle: .minimal(),
            generalStyle: .minimal()
        )
    }
    
    public static func themed(_ theme: ChatTheme) -> ChatConfiguration {
        return ChatConfiguration(
            bubbleStyle: .themed(theme),
            inputStyle: .themed(theme),
            generalStyle: .themed(theme)
        )
    }
    
    // MARK: - Fluent API
    public func bubbleStyle(_ style: BubbleStyle) -> ChatConfiguration {
        var config = self
        config.bubbleStyle = style
        return config
    }
    
    public func inputStyle(_ style: InputStyle) -> ChatConfiguration {
        var config = self
        config.inputStyle = style
        return config
    }
    
    public func generalStyle(_ style: GeneralStyle) -> ChatConfiguration {
        var config = self
        config.generalStyle = style
        return config
    }
}

// MARK: - Chat Themes
public enum ChatTheme {
    case light
    case dark
    case blue
    case green
    case purple
    case minimal
    
    var colors: (primary: Color, secondary: Color, background: Color, text: Color) {
        switch self {
        case .light:
            return (.blue, Color(.systemGray5), Color(.systemBackground), .primary)
        case .dark:
            return (.blue, Color(.systemGray4), Color(.systemBackground), .primary)
        case .blue:
            return (.blue, Color(.systemBlue).opacity(0.1), Color(.systemBackground), .primary)
        case .green:
            return (.green, Color(.systemGreen).opacity(0.1), Color(.systemBackground), .primary)
        case .purple:
            return (.purple, Color(.systemPurple).opacity(0.1), Color(.systemBackground), .primary)
        case .minimal:
            return (Color(.systemGray), Color(.systemGray6), Color(.systemBackground), .primary)
        }
    }
}

public struct BubbleStyle {
    public var currentUserColor: Color
    public var otherUserColor: Color
    public var textColor: Color
    public var font: Font
    public var cornerRadius: CGFloat
    public var padding: EdgeInsets
    
    public init(
        currentUserColor: Color = .blue,
        otherUserColor: Color = Color(.systemGray5),
        textColor: Color = .primary,
        font: Font = .body,
        cornerRadius: CGFloat = ChatConstants.CornerRadius.bubble,
        padding: EdgeInsets = EdgeInsets(
            top: ChatConstants.Spacing.inputPadding,
            leading: ChatConstants.Spacing.bubblePadding,
            bottom: ChatConstants.Spacing.inputPadding,
            trailing: ChatConstants.Spacing.bubblePadding
        )
    ) {
        self.currentUserColor = currentUserColor
        self.otherUserColor = otherUserColor
        self.textColor = textColor
        self.font = font
        self.cornerRadius = cornerRadius
        self.padding = padding
    }
    
    // MARK: - Convenience Builders
    public static func minimal() -> BubbleStyle {
        return BubbleStyle(
            currentUserColor: Color(.systemGray),
            otherUserColor: Color(.systemGray6),
            cornerRadius: ChatConstants.CornerRadius.medium
        )
    }
    
    public static func themed(_ theme: ChatTheme) -> BubbleStyle {
        let colors = theme.colors
        return BubbleStyle(
            currentUserColor: colors.primary,
            otherUserColor: colors.secondary,
            textColor: colors.text
        )
    }
}

public struct InputStyle {
    public var backgroundColor: Color
    public var textColor: Color
    public var font: Font
    public var minHeight: CGFloat
    public var maxHeight: CGFloat
    public var cornerRadius: CGFloat
    
    public init(
        backgroundColor: Color = Color(.tertiarySystemBackground),
        textColor: Color = .primary,
        font: Font = .body,
        minHeight: CGFloat = ChatConstants.Sizes.minInputHeight,
        maxHeight: CGFloat = ChatConstants.Sizes.maxInputHeight,
        cornerRadius: CGFloat = ChatConstants.CornerRadius.input
    ) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.font = font
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.cornerRadius = cornerRadius
    }
    
    // MARK: - Convenience Builders
    public static func minimal() -> InputStyle {
        return InputStyle(
            backgroundColor: Color(.systemGray6),
            cornerRadius: ChatConstants.CornerRadius.medium
        )
    }
    
    public static func themed(_ theme: ChatTheme) -> InputStyle {
        let colors = theme.colors
        return InputStyle(
            backgroundColor: colors.secondary,
            textColor: colors.text
        )
    }
}

public struct GeneralStyle {
    public var backgroundColor: Color
    public var animationDuration: Double
    public var showTimestamps: Bool
    public var timestampFormat: DateFormatter
    
    public init(
        backgroundColor: Color = Color(.systemBackground),
        animationDuration: Double = ChatConstants.Animation.messageTransition,
        showTimestamps: Bool = true,
        timestampFormat: DateFormatter = {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter
        }()
    ) {
        self.backgroundColor = backgroundColor
        self.animationDuration = animationDuration
        self.showTimestamps = showTimestamps
        self.timestampFormat = timestampFormat
    }
    
    // MARK: - Convenience Builders
    public static func minimal() -> GeneralStyle {
        return GeneralStyle(
            animationDuration: ChatConstants.Animation.short,
            showTimestamps: false
        )
    }
    
    public static func themed(_ theme: ChatTheme) -> GeneralStyle {
        let colors = theme.colors
        return GeneralStyle(
            backgroundColor: colors.background
        )
    }
}