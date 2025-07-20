import SwiftUI

// MARK: - Chat Input Style
public struct ChatInputStyle: ViewModifier {
    @Environment(\.chatTheme) private var theme
    
    let variant: InputVariant
    
    public func body(content: Content) -> some View {
        content
            .textFieldStyle(.plain)
            .font(theme.typography.body)
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
            .lineLimit(1...6)
            .frame(minHeight: theme.layout.minInputHeight)
            .background(backgroundView)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch variant {
        case .standard:
            RoundedRectangle(cornerRadius: theme.layout.cornerRadius)
                .fill(theme.colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.layout.cornerRadius)
                        .stroke(theme.colors.secondary, lineWidth: 0.5)
                )
        case .minimal:
            RoundedRectangle(cornerRadius: theme.layout.smallCornerRadius)
                .fill(theme.colors.surface)
        case .floating:
            RoundedRectangle(cornerRadius: theme.layout.cornerRadius)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 4)
        }
    }
}

public enum InputVariant {
    case standard
    case minimal
    case floating
}

// MARK: - View Extensions
public extension View {
    // MARK: - Input Styling
    func chatInput(variant: InputVariant = .standard) -> some View {
        modifier(ChatInputStyle(variant: variant))
    }
    
    // Input style chaining
    func inputStyle(_ variant: InputVariant = .standard) -> some View {
        chatInput(variant: variant)
    }
}