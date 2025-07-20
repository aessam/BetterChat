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
        HStack(alignment: .top, spacing: 2) {
            if message.sender == .currentUser { 
                Spacer(minLength: 80)
            }
            
            VStack(alignment: alignment, spacing: 2) {
                // Bubble with reaction overlay
                ZStack(alignment: message.sender == .currentUser ? .topLeading : .topTrailing) {
                    // Bubble
                    content
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(bubbleColor)
                        .foregroundColor(textColor)
                        .font(.system(size: 17))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    
                    // Reaction on top corner
                    if let reaction = message.reactionType, showReaction {
                        Text(reaction)
                            .font(.system(size: 16))
                            .padding(2)
                            .background(
                                Circle()
                                    .fill(Color(red: 1, green: 1, blue: 1))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                                    )
                            )
                            .offset(x: message.sender == .currentUser ? -8 : 8, y: -8)
                    }
                }
                
                // Status below bubble for sent messages
                if message.sender == .currentUser && message.status != .sending {
                    MessageStatusView(status: message.status)
                        .padding(.trailing, 2)
                }
            }
            
            if message.sender != .currentUser { 
                Spacer(minLength: 80)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 2)
    }
}

struct MessageStatusView: View {
    let status: MessageStatus
    
    var body: some View {
        HStack(spacing: -3) {
            switch status {
            case .sending:
                Image(systemName: "ellipsis")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
            case .sent:
                Text("Delivered")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            case .delivered:
                Text("Delivered")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            case .read:
                Text("Read")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            case .failed:
                HStack(spacing: 2) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12))
                    Text("Not Delivered")
                        .font(.system(size: 11))
                }
                .foregroundColor(.red)
            }
        }
    }
}


