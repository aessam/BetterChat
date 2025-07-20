import SwiftUI

// MARK: - Chat Constants
public struct ChatConstants {
    // MARK: - Spacing
    public struct Spacing {
        public static let tiny: CGFloat = 2
        public static let small: CGFloat = 6
        public static let medium: CGFloat = 8
        public static let large: CGFloat = 12
        public static let extraLarge: CGFloat = 16
        public static let huge: CGFloat = 20
        
        // Specific spacing values
        public static let bubblePadding: CGFloat = 12
        public static let inputPadding: CGFloat = 8
        public static let attachmentSpacing: CGFloat = 8
        public static let messageSpacing: CGFloat = 2
        public static let sectionSpacing: CGFloat = 10
    }
    
    // MARK: - Sizes
    public struct Sizes {
        public static let sendButtonSize: CGFloat = 32
        public static let attachmentButtonSize: CGFloat = 34
        public static let attachmentPreviewSize: CGFloat = 60
        public static let reactionIconSize: CGFloat = 30
        public static let removeButtonSize: CGFloat = 20
        public static let statusIconSize: CGFloat = 12
        public static let reactionBadgeSize: CGFloat = 16
        
        // Heights
        public static let minInputHeight: CGFloat = 34
        public static let maxInputHeight: CGFloat = 100
        public static let minBubbleSpacing: CGFloat = 80
    }
    
    // MARK: - Corner Radius
    public struct CornerRadius {
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 12
        public static let large: CGFloat = 17
        public static let extraLarge: CGFloat = 18
        public static let huge: CGFloat = 20
        
        // Specific radius values
        public static let bubble: CGFloat = 18
        public static let input: CGFloat = 17
        public static let attachment: CGFloat = 12
        public static let reactionOverlay: CGFloat = 20
    }
    
    // MARK: - Font Sizes
    public struct FontSizes {
        public static let caption: CGFloat = 11
        public static let footnote: CGFloat = 13
        public static let body: CGFloat = 17
        public static let title: CGFloat = 20
        public static let largeTitle: CGFloat = 24
        
        // Specific font sizes
        public static let messageText: CGFloat = 17
        public static let statusText: CGFloat = 11
        public static let reactionIcon: CGFloat = 30
        public static let reactionBadge: CGFloat = 16
    }
    
    // MARK: - Animation
    public struct Animation {
        public static let short: Double = 0.2
        public static let medium: Double = 0.3
        public static let long: Double = 0.5
        
        // Specific animations
        public static let messageTransition: Double = 0.3
        public static let reactionTransition: Double = 0.2
        public static let sendButtonTransition: Double = 0.2
        public static let keyboardDismiss: Double = 0.25
    }
    
    // MARK: - Shadow
    public struct Shadow {
        public static let small = (radius: CGFloat(2), x: CGFloat(0), y: CGFloat(1))
        public static let medium = (radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
        public static let large = (radius: CGFloat(10), x: CGFloat(0), y: CGFloat(5))
        
        // Specific shadows
        public static let reactionOverlay = (radius: CGFloat(10), x: CGFloat(0), y: CGFloat(5))
        public static let bubble = (radius: CGFloat(2), x: CGFloat(0), y: CGFloat(1))
    }
    
    // MARK: - Line Limits
    public struct LineLimits {
        public static let inputMinLines = 1
        public static let inputMaxLines = 6
        public static let messageMaxLines = 50
    }
    
    // MARK: - Opacity
    public struct Opacity {
        public static let disabled: Double = 0.6
        public static let secondary: Double = 0.7
        public static let overlay: Double = 0.1
        public static let divider: Double = 0.3
    }
    
    // MARK: - Z-Index
    public struct ZIndex {
        public static let `default`: Double = 0
        public static let overlay: Double = 1
        public static let modal: Double = 10
        public static let toast: Double = 100
    }
    
    // MARK: - Default Reactions
    public struct Reactions {
        public static let defaultEmojis = ["❤️", "👍", "😂", "😮", "😢", "🔥"]
        public static let removeSymbol = "✕"
    }
    
    // MARK: - System Names
    public struct SystemNames {
        public static let sendButton = "arrow.up.circle.fill"
        public static let attachmentButton = "plus"
        public static let removeAttachment = "xmark.circle.fill"
        public static let failedStatus = "exclamationmark.circle.fill"
        public static let sendingStatus = "ellipsis"
    }
    
    // MARK: - Placeholders
    public struct Placeholders {
        public static let messageInput = "iMessage"
        public static let searchPlaceholder = "Search messages..."
    }
}