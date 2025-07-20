import SwiftUI

// MARK: - Chat Bubble Style
public struct ChatBubbleStyle: ViewModifier {
    @Environment(\.chatTheme) private var theme
    
    let role: BubbleRole
    let shape: BubbleShape
    
    public func body(content: Content) -> some View {
        content
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .font(theme.typography.body)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
    
    private var backgroundColor: Color {
        switch role {
        case .user: return theme.colors.primary
        case .assistant: return theme.colors.secondary
        case .system: return theme.colors.surface
        }
    }
    
    private var textColor: Color {
        switch role {
        case .user: return .white
        case .assistant, .system: return theme.colors.text
        }
    }
    
    private var cornerRadius: CGFloat {
        switch shape {
        case .rounded:
            return theme.layout.cornerRadius
        case .minimal:
            return theme.layout.smallCornerRadius
        case .pill:
            return 50 // Large radius for pill shape
        }
    }
}

public enum BubbleRole {
    case user
    case assistant
    case system
}

public enum BubbleShape {
    case rounded
    case minimal
    case pill
}

// MARK: - View Extensions
public extension View {
    // MARK: - Bubble Styling
    func chatBubble(
        role: BubbleRole,
        shape: BubbleShape = .rounded
    ) -> some View {
        modifier(ChatBubbleStyle(role: role, shape: shape))
    }
    
    // Message bubble variants
    func userBubble(shape: BubbleShape = .rounded) -> some View {
        chatBubble(role: .user, shape: shape)
    }
    
    func assistantBubble(shape: BubbleShape = .rounded) -> some View {
        chatBubble(role: .assistant, shape: shape)
    }
    
    func systemBubble(shape: BubbleShape = .minimal) -> some View {
        chatBubble(role: .system, shape: shape)
    }
}