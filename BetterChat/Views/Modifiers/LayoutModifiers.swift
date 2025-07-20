import SwiftUI

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

// MARK: - View Extensions
public extension View {
    // MARK: - Container Styling
    func chatContainer(variant: ContainerVariant = .standard) -> some View {
        modifier(ChatContainerStyle(variant: variant))
    }
    
    // Reaction support
    func reactions(enabled: Bool = true) -> ChatReactionView<Self> {
        ChatReactionView(content: self, isEnabled: enabled)
    }
    
    // Typing indicator support
    func withTypingIndicator(isVisible: Bool = false) -> ChatTypingView<Self> {
        ChatTypingView(content: self, isVisible: isVisible)
    }
    
    // Status indicators
    func messageStatus(failed: Bool = false) -> some View {
        font(.caption2)
            .foregroundColor(failed ? Color.red : Color.secondary)
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