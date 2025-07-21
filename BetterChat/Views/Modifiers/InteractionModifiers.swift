import SwiftUI

// MARK: - Chat Interactive Style
public struct ChatInteractiveStyle: ViewModifier {
    @Environment(\.chatTheme) private var theme
    
    let isEnabled: Bool
    let isPressed: Bool
    let variant: InteractiveVariant
    
    public func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.6)
            .foregroundColor(foregroundColor)
            .animation(.easeInOut(duration: theme.animation.fast), value: isPressed)
            .animation(.easeInOut(duration: theme.animation.fast), value: isEnabled)
    }
    
    private var foregroundColor: Color {
        guard isEnabled else { return theme.colors.textSecondary }
        
        switch variant {
        case .primary: return theme.colors.accent
        case .secondary: return theme.colors.textSecondary
        case .destructive: return theme.colors.error
        case .success: return theme.colors.success
        }
    }
}

public enum InteractiveVariant {
    case primary
    case secondary
    case destructive
    case success
}

// MARK: - View Extensions
public extension View {
    // MARK: - Interactive Styling
    func chatInteractive(
        isEnabled: Bool = true,
        isPressed: Bool = false,
        variant: InteractiveVariant = .primary
    ) -> some View {
        modifier(ChatInteractiveStyle(
            isEnabled: isEnabled,
            isPressed: isPressed,
            variant: variant
        ))
    }
    
    // Interactive element variants
    func sendButton(isEnabled: Bool = true) -> some View {
        chatInteractive(isEnabled: isEnabled, variant: .primary)
    }
    
    func attachmentButton(isEnabled: Bool = true) -> some View {
        chatInteractive(isEnabled: isEnabled, variant: .secondary)
    }
    
}