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

// MARK: - Chat Container Style
public struct ChatContainerStyle: ViewModifier {
    @Environment(\.chatTheme) private var theme
    
    let variant: ContainerVariant
    
    public func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .scrollDismissesKeyboard(.interactively)
    }
    
    private var backgroundColor: Color {
        switch variant {
        case .standard: return theme.colors.background
        case .elevated: return theme.colors.surface
        }
    }
}

public enum ContainerVariant {
    case standard
    case elevated
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
    
    // MARK: - Input Styling
    func chatInput(variant: InputVariant = .standard) -> some View {
        modifier(ChatInputStyle(variant: variant))
    }
    
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
    
    // MARK: - Container Styling
    func chatContainer(variant: ContainerVariant = .standard) -> some View {
        modifier(ChatContainerStyle(variant: variant))
    }
}

// MARK: - Specialized Convenience Extensions
public extension View {
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
    
    // Interactive element variants
    func sendButton(isEnabled: Bool = true) -> some View {
        chatInteractive(isEnabled: isEnabled, variant: .primary)
    }
    
    func attachmentButton(isEnabled: Bool = true) -> some View {
        chatInteractive(isEnabled: isEnabled, variant: .secondary)
    }
    
    func reactionButton(isPressed: Bool = false) -> some View {
        chatInteractive(isPressed: isPressed, variant: .secondary)
    }
    
    // Status indicators
    func messageStatus(failed: Bool = false) -> some View {
        font(.caption2)
            .foregroundColor(failed ? Color.red : Color.secondary)
    }
}

// MARK: - Chainable Configuration API
public extension View {
    // Note: chatTheme is defined in ChatTheme.swift
    
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
    
    // Input style chaining
    func inputStyle(_ variant: InputVariant = .standard) -> some View {
        chatInput(variant: variant)
    }
    
    // Reaction support
    func reactions(enabled: Bool = true) -> ChatReactionView<Self> {
        ChatReactionView(content: self, isEnabled: enabled)
    }
    
    // Typing indicator support
    func withTypingIndicator(isVisible: Bool = false) -> ChatTypingView<Self> {
        ChatTypingView(content: self, isVisible: isVisible)
    }
}

// MARK: - Reaction Container
public struct ChatReactionView<Content: View>: View {
    let content: Content
    let isEnabled: Bool
    @State private var selectedReactions: Set<String>
    @Environment(\.chatTheme) private var theme
    
    init(content: Content, isEnabled: Bool, selectedReactions: Set<String> = []) {
        self.content = content
        self.isEnabled = isEnabled
        self._selectedReactions = State(initialValue: selectedReactions)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            content
            
            if isEnabled && !selectedReactions.isEmpty {
                HStack(spacing: theme.spacing.xs) {
                    ForEach(Array(selectedReactions), id: \.self) { reaction in
                        Text(reaction)
                            .font(.caption)
                            .padding(.horizontal, theme.spacing.sm)
                            .padding(.vertical, theme.spacing.xs)
                            .background(
                                Capsule()
                                    .fill(theme.colors.surface)
                                    .overlay(
                                        Capsule()
                                            .stroke(theme.colors.accent, lineWidth: 1)
                                    )
                            )
                            .onTapGesture {
                                selectedReactions.remove(reaction)
                            }
                    }
                }
            }
        }
    }
    
    public func addReaction(_ reaction: String) -> ChatReactionView {
        ChatReactionView(
            content: content,
            isEnabled: isEnabled,
            selectedReactions: selectedReactions.union([reaction])
        )
    }
}

// MARK: - Typing Indicator Container
public struct ChatTypingView<Content: View>: View {
    let content: Content
    let isVisible: Bool
    @Environment(\.chatTheme) private var theme
    
    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            content
            
            if isVisible {
                HStack {
                    TypingIndicatorDots()
                    Spacer()
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: theme.animation.medium), value: isVisible)
    }
}

// MARK: - Typing Indicator Dots
struct TypingIndicatorDots: View {
    @Environment(\.chatTheme) private var theme
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: theme.spacing.xs) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(theme.colors.textSecondary)
                    .frame(width: 6, height: 6)
                    .offset(y: animationOffset)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: animationOffset
                    )
            }
        }
        .onAppear {
            animationOffset = -4
        }
    }
}

// MARK: - Fluent Configuration Extensions
public extension View {
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

// MARK: - Conditional Modifier Helper
extension View {
    @ViewBuilder
    func conditionalModifier<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}