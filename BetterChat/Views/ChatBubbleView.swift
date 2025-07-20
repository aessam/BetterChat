import SwiftUI

struct ChatBubbleView<Message: MessageProtocol, Content: View>: View {
    let message: Message
    let configuration: ChatConfiguration
    let content: Content
    let showReaction: Bool
    
    private var bubbleColor: Color {
        message.sender == .currentUser ? configuration.bubbleStyle.currentUserColor : configuration.bubbleStyle.otherUserColor
    }
    
    private var textColor: Color {
        message.sender == .currentUser ? .white : .primary
    }
    
    private var alignment: HorizontalAlignment {
        message.sender == .currentUser ? .trailing : .leading
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: ChatConstants.Spacing.tiny) {
            if message.sender == .currentUser { 
                Spacer(minLength: ChatConstants.Sizes.minBubbleSpacing)
            }
            
            VStack(alignment: alignment, spacing: ChatConstants.Spacing.tiny) {
                // Bubble with reaction overlay
                ZStack(alignment: message.sender == .currentUser ? .topLeading : .topTrailing) {
                    // Bubble
                    content
                        .chatBubble(isCurrentUser: message.sender == .currentUser, configuration: configuration)
                    
                    // Reaction on top corner
                    if let reaction = message.reactionType, showReaction {
                        Text(reaction)
                            .reactionBadge(
                                isCurrentUser: message.sender == .currentUser,
                                xOffset: message.sender == .currentUser ? -ChatConstants.Spacing.inputPadding : ChatConstants.Spacing.inputPadding
                            )
                    }
                }
                
                // Status below bubble for sent messages
                if message.sender == .currentUser && message.status != .sending {
                    MessageStatusView(status: message.status)
                        .padding(.trailing, ChatConstants.Spacing.tiny)
                }
            }
            
            if message.sender != .currentUser { 
                Spacer(minLength: ChatConstants.Sizes.minBubbleSpacing)
            }
        }
        .padding(.horizontal, ChatConstants.Spacing.bubblePadding)
        .padding(.vertical, ChatConstants.Spacing.tiny)
    }
}

struct MessageStatusView: View {
    let status: MessageStatus
    
    var body: some View {
        HStack(spacing: -ChatConstants.Spacing.tiny + 1) {
            switch status {
            case .sending:
                Image(systemName: ChatConstants.SystemNames.sendingStatus)
                    .font(.system(size: ChatConstants.FontSizes.caption - 1, weight: .medium))
                    .messageStatus(status)
            case .sent:
                Text("Delivered")
                    .messageStatus(status)
            case .delivered:
                Text("Delivered")
                    .messageStatus(status)
            case .read:
                Text("Read")
                    .messageStatus(status)
            case .failed:
                HStack(spacing: ChatConstants.Spacing.tiny) {
                    Image(systemName: ChatConstants.SystemNames.failedStatus)
                        .font(.system(size: ChatConstants.Sizes.statusIconSize))
                    Text("Not Delivered")
                }
                .messageStatus(status)
            }
        }
    }
}


