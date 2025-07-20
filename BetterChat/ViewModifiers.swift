import SwiftUI

// MARK: - Chat Bubble Modifier
struct ChatBubbleModifier: ViewModifier {
    let isCurrentUser: Bool
    let configuration: ChatConfiguration
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isCurrentUser ? 
                configuration.bubbleStyle.currentUserColor : 
                configuration.bubbleStyle.otherUserColor
            )
            .foregroundColor(isCurrentUser ? .white : .primary)
            .font(.system(size: 17))
            .clipShape(RoundedRectangle(cornerRadius: configuration.bubbleStyle.cornerRadius))
    }
}

// MARK: - Message Input Modifier
struct MessageInputModifier: ViewModifier {
    let configuration: ChatConfiguration
    
    func body(content: Content) -> some View {
        content
            .textFieldStyle(.plain)
            .font(.system(size: 17))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .lineLimit(1...6)
            .frame(minHeight: 34)
            .background(
                RoundedRectangle(cornerRadius: configuration.inputStyle.cornerRadius)
                    .fill(configuration.inputStyle.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: configuration.inputStyle.cornerRadius)
                            .stroke(Color(.systemGray4), lineWidth: 0.5)
                    )
            )
    }
}

// MARK: - Reaction Overlay Modifier
struct ReactionOverlayModifier: ViewModifier {
    let yOffset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .offset(y: yOffset)
            .transition(.scale.combined(with: .opacity))
    }
}

// MARK: - Attachment Preview Modifier
struct AttachmentPreviewModifier: ViewModifier {
    let size: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
            )
    }
}

// MARK: - Chat Container Modifier
struct ChatContainerModifier: ViewModifier {
    let configuration: ChatConfiguration
    
    func body(content: Content) -> some View {
        content
            .background(configuration.generalStyle.backgroundColor)
            .scrollDismissesKeyboard(.interactively)
    }
}

// MARK: - Send Button Modifier
struct SendButtonModifier: ViewModifier {
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 32))
            .foregroundColor(isEnabled ? .blue : .gray)
            .scaleEffect(isEnabled ? 1.0 : 0.8)
            .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

// MARK: - Message Status Modifier
struct MessageStatusModifier: ViewModifier {
    let status: MessageStatus
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 11))
            .foregroundColor(status == .failed ? .red : .secondary)
    }
}

// MARK: - Reaction Badge Modifier
struct ReactionBadgeModifier: ViewModifier {
    let isCurrentUser: Bool
    let xOffset: CGFloat
    let yOffset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16))
            .padding(2)
            .background(
                Circle()
                    .fill(Color.white)
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                    )
            )
            .offset(x: xOffset, y: yOffset)
    }
}

// MARK: - View Extensions
extension View {
    func chatBubble(isCurrentUser: Bool, configuration: ChatConfiguration) -> some View {
        self.modifier(ChatBubbleModifier(isCurrentUser: isCurrentUser, configuration: configuration))
    }
    
    func messageInput(configuration: ChatConfiguration) -> some View {
        self.modifier(MessageInputModifier(configuration: configuration))
    }
    
    func reactionOverlay(yOffset: CGFloat = -50) -> some View {
        self.modifier(ReactionOverlayModifier(yOffset: yOffset))
    }
    
    func attachmentPreview(size: CGFloat = 60) -> some View {
        self.modifier(AttachmentPreviewModifier(size: size))
    }
    
    func chatContainer(configuration: ChatConfiguration) -> some View {
        self.modifier(ChatContainerModifier(configuration: configuration))
    }
    
    func sendButton(isEnabled: Bool) -> some View {
        self.modifier(SendButtonModifier(isEnabled: isEnabled))
    }
    
    func messageStatus(_ status: MessageStatus) -> some View {
        self.modifier(MessageStatusModifier(status: status))
    }
    
    func reactionBadge(isCurrentUser: Bool, xOffset: CGFloat, yOffset: CGFloat = -8) -> some View {
        self.modifier(ReactionBadgeModifier(isCurrentUser: isCurrentUser, xOffset: xOffset, yOffset: yOffset))
    }
}