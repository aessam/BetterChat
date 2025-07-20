import SwiftUI

// MARK: - Chat Layout Preference Keys

// Preference for tracking message bubble widths
struct MessageBubbleWidthPreference: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// Preference for tracking input area height
struct InputAreaHeightPreference: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// Preference for tracking scroll position
struct ScrollPositionPreference: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// Preference for tracking keyboard height
struct KeyboardHeightPreference: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// Preference for tracking message content size
struct MessageContentSizePreference: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        let next = nextValue()
        value = CGSize(
            width: max(value.width, next.width),
            height: max(value.height, next.height)
        )
    }
}

// MARK: - Layout Preference Modifiers

extension View {
    // Report message bubble width for responsive layout
    func reportMessageBubbleWidth() -> some View {
        background(
            GeometryReader { geometry in
                Color.clear
                    .preference(
                        key: MessageBubbleWidthPreference.self,
                        value: geometry.size.width
                    )
            }
        )
    }
    
    // Report input area height for keyboard avoidance
    func reportInputAreaHeight() -> some View {
        background(
            GeometryReader { geometry in
                Color.clear
                    .preference(
                        key: InputAreaHeightPreference.self,
                        value: geometry.size.height
                    )
            }
        )
    }
    
    // Report scroll position for auto-scroll behavior
    func reportScrollPosition() -> some View {
        background(
            GeometryReader { geometry in
                Color.clear
                    .preference(
                        key: ScrollPositionPreference.self,
                        value: geometry.frame(in: .global).minY
                    )
            }
        )
    }
    
    // Report message content size for bubble sizing
    func reportMessageContentSize() -> some View {
        background(
            GeometryReader { geometry in
                Color.clear
                    .preference(
                        key: MessageContentSizePreference.self,
                        value: geometry.size
                    )
            }
        )
    }
}

// MARK: - Responsive Layout Modifiers

extension View {
    // Automatically adjust bubble width based on content and screen size
    func responsiveBubbleWidth(maxWidth: CGFloat? = nil) -> some View {
        modifier(ResponsiveBubbleWidthModifier(maxWidth: maxWidth))
    }
    
    // Auto-scroll to bottom when new messages arrive
    func autoScrollToBottom(enabled: Bool = true) -> some View {
        modifier(AutoScrollModifier(enabled: enabled))
    }
}

// MARK: - Responsive Bubble Width Modifier
private struct ResponsiveBubbleWidthModifier: ViewModifier {
    @Environment(\.chatTheme) private var theme
    let maxWidth: CGFloat?
    @State private var screenWidth: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: effectiveMaxWidth)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            screenWidth = geometry.size.width
                        }
                        .onChange(of: geometry.size.width) { newWidth in
                            screenWidth = newWidth
                        }
                }
            )
    }
    
    private var effectiveMaxWidth: CGFloat {
        let screenBasedWidth = screenWidth * 0.75 // 75% of screen width
        let themeBasedWidth = theme.layout.bubbleMaxWidth
        let providedWidth = maxWidth ?? .infinity
        
        return min(screenBasedWidth, min(themeBasedWidth, providedWidth))
    }
}


// MARK: - Auto Scroll Modifier
private struct AutoScrollModifier: ViewModifier {
    let enabled: Bool
    @State private var shouldScrollToBottom = true
    @State private var scrollPosition: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .onPreferenceChange(ScrollPositionPreference.self) { position in
                scrollPosition = position
                // If user scrolled up significantly, disable auto-scroll
                shouldScrollToBottom = position < 100
            }
    }
}

// MARK: - Dynamic Spacing Modifier
extension View {
    func dynamicSpacing(_ baseSpacing: CGFloat) -> some View {
        modifier(DynamicSpacingModifier(baseSpacing: baseSpacing))
    }
}

private struct DynamicSpacingModifier: ViewModifier {
    @Environment(\.chatTheme) private var theme
    @Environment(\.sizeCategory) private var sizeCategory
    
    let baseSpacing: CGFloat
    
    func body(content: Content) -> some View {
        content
            .padding(effectiveSpacing)
    }
    
    private var effectiveSpacing: CGFloat {
        let scaleFactor: CGFloat
        
        switch sizeCategory {
        case .extraSmall, .small:
            scaleFactor = 0.8
        case .medium:
            scaleFactor = 1.0
        case .large, .extraLarge:
            scaleFactor = 1.2
        case .extraExtraLarge, .extraExtraExtraLarge:
            scaleFactor = 1.4
        default:
            scaleFactor = 1.6
        }
        
        return baseSpacing * scaleFactor
    }
}

// MARK: - Adaptive Text Modifier
extension View {
    func adaptiveTextSize() -> some View {
        modifier(AdaptiveTextSizeModifier())
    }
}

private struct AdaptiveTextSizeModifier: ViewModifier {
    @Environment(\.sizeCategory) private var sizeCategory
    @Environment(\.chatTheme) private var theme
    
    func body(content: Content) -> some View {
        content
            .font(adaptiveFont)
    }
    
    private var adaptiveFont: Font {
        switch sizeCategory {
        case .extraSmall, .small:
            return .caption
        case .medium, .large:
            return theme.typography.body
        case .extraLarge, .extraExtraLarge:
            return .title3
        default:
            return .title2
        }
    }
}

// MARK: - Safe Area Aware Modifier
extension View {
    func safeAreaAware() -> some View {
        modifier(SafeAreaAwareModifier())
    }
}

private struct SafeAreaAwareModifier: ViewModifier {
    @Environment(\.chatTheme) private var theme
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            // Could update theme spacing based on safe area
                        }
                }
            )
    }
}
