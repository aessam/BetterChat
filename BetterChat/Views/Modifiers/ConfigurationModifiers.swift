import SwiftUI

// MARK: - Chainable Configuration API
public extension View {
    func chatColors(_ colors: ChatColors) -> some View {
        environment(\.chatTheme, ChatDesignTokens(
            colors: colors,
            spacing: .default,
            typography: .default,
            layout: .default,
            animation: .default
        ))
    }
    
    // Style chaining for messages
    func messageStyle(
        _ role: BubbleRole,
        shape: BubbleShape = .rounded
    ) -> some View {
        chatBubble(role: role, shape: shape)
    }
    
    // Complete fluent API for chat styling
    func chat(
        theme: ChatThemePreset = .light,
        reactions: Bool = true,
        typing: Bool = false
    ) -> some View {
        self
            .chatTheme(theme)
            .conditionalModifier(reactions) { $0.reactions(enabled: true) }
            .conditionalModifier(typing) { $0.withTypingIndicator() }
    }
}