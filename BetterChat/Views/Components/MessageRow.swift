import SwiftUI

public struct MessageRow<DataSource: ChatDataSource>: View {
    let message: DataSource.Message
    @ObservedObject private var dataSource: DataSource
    @Environment(\.chatTheme) private var theme
    
    @Binding private var selectedMessageForReaction: DataSource.Message?
    
    public init(
        message: DataSource.Message,
        dataSource: DataSource,
        selectedMessageForReaction: Binding<DataSource.Message?>
    ) {
        self.message = message
        self.dataSource = dataSource
        self._selectedMessageForReaction = selectedMessageForReaction
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Show thinking session if there's one for this message
            if let thinkingSession = dataSource.completedThinkingSessions.first(where: { $0.messageId == message.id }) {
                ThinkingIndicatorView(
                    thoughts: thinkingSession.thoughts,
                    isThinking: false
                )
            }
            
            // Message content
            HStack {
                if message.sender == .currentUser {
                    Spacer(minLength: theme.layout.bubbleMaxWidth * 0.3)
                }
                
                messageContent
                    .overlay(alignment: .top) {
                        // Reaction picker overlay - similar to old implementation
                        if selectedMessageForReaction?.id == message.id {
                            reactionPickerOverlay
                        }
                    }
                    .onLongPressGesture {
                        withAnimation(.easeOut(duration: 0.2)) {
                            if selectedMessageForReaction?.id == message.id {
                                selectedMessageForReaction = nil
                            } else {
                                selectedMessageForReaction = message
                            }
                        }
                    }
                    .onTapGesture {
                        if message.status == .failed {
                            dataSource.retryMessage(message)
                        } else if selectedMessageForReaction != nil {
                            withAnimation(.easeOut(duration: 0.2)) {
                                selectedMessageForReaction = nil
                            }
                        }
                    }
                
                if message.sender != .currentUser {
                    Spacer(minLength: theme.layout.bubbleMaxWidth * 0.3)
                }
            }
        }
    }
    
    // MARK: - Message Content
    @ViewBuilder
    private var messageContent: some View {
        VStack(alignment: message.sender == .currentUser ? .trailing : .leading, spacing: theme.spacing.xs) {
            // Message bubble
            messageContentView
                .chatBubble(
                    role: message.sender == .currentUser ? .user : .assistant
                )
            
            // Reactions if message supports them
            if let reactableMessage = message as? (any ReactableMessage),
               !reactableMessage.reactions.isEmpty {
                reactionRow(for: reactableMessage.reactions)
            }
            
            // Status and timestamp
            messageMetadata
        }
    }
    
    @ViewBuilder
    private var messageContentView: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            // Show text if message has text
            if let textMessage = message as? (any TextMessage), !textMessage.text.isEmpty {
                Text(textMessage.text)
            }
            
            // Show attachments if message has them
            if let mediaMessage = message as? (any MediaMessage), !mediaMessage.attachments.isEmpty {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: theme.spacing.sm) {
                    ForEach(mediaMessage.attachments, id: \.id) { attachment in
                        attachmentPreview(for: attachment)
                    }
                }
            }
        }
    }
    
    // MARK: - Reaction Picker Overlay
    private var reactionPickerOverlay: some View {
        HStack(spacing: 8) {
            ForEach(ChatConstants.Reactions.defaultEmojis, id: \.self) { emoji in
                Text(emoji)
                    .font(.system(size: 30))
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.2)) {
                            dataSource.reactToMessage(message, reaction: emoji)
                            selectedMessageForReaction = nil
                        }
                    }
            }
            
            // Remove reaction button if message has reactions
            if let reactableMessage = message as? (any ReactableMessage),
               !reactableMessage.reactions.isEmpty {
                Text("✕")
                    .font(.system(size: 24))
                    .foregroundColor(.secondary)
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.2)) {
                            dataSource.removeReaction(from: message, reaction: "")
                            selectedMessageForReaction = nil
                        }
                    }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .offset(y: -50) // Position above the message
        .transition(.scale.combined(with: .opacity))
        .zIndex(1)
    }
    
    // MARK: - Attachment Preview  
    @ViewBuilder
    private func attachmentPreview(for attachment: any ChatAttachment) -> some View {
        if let imageAttachment = attachment as? ImageAttachment {
            (imageAttachment.thumbnail ?? imageAttachment.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipped()
        } else if let linkAttachment = attachment as? LinkAttachment {
            VStack(spacing: theme.spacing.xs) {
                if let thumbnail = linkAttachment.thumbnail {
                    thumbnail
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 60)
                        .clipped()
                } else {
                    Image(systemName: "link")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .font(.title2)
                        .foregroundColor(theme.colors.accent)
                        .frame(height: 60)
                }
                
                VStack(spacing: 2) {
                    if let title = linkAttachment.title {
                        Text(title)
                            .font(.caption)
                            .fontWeight(.medium)
                            .lineLimit(1)
                    }
                    
                    Text(linkAttachment.url.host ?? linkAttachment.url.absoluteString)
                        .font(.caption2)
                        .foregroundColor(theme.colors.textSecondary)
                        .lineLimit(1)
                }
            }
            .frame(width: 100)
        } else {
            // Fallback for any other attachment type
            VStack(spacing: theme.spacing.xs) {
                Image(systemName: "doc")
                    .font(.title2)
                    .foregroundColor(theme.colors.accent)
                
                Text("Attachment")
                    .font(theme.typography.caption)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 100, height: 100)
        }
    }
    
    // MARK: - Reactions
    private func reactionRow(for reactions: [Reaction]) -> some View {
        HStack(spacing: theme.spacing.xs) {
            ForEach(reactions) { reaction in
                HStack(spacing: 2) {
                    Text(reaction.emoji)
                        .font(.caption)
                    
                    if reaction.count > 1 {
                        Text("\(reaction.count)")
                            .font(.caption2)
                            .foregroundColor(theme.colors.textSecondary)
                    }
                }
                .padding(.horizontal, theme.spacing.sm)
                .padding(.vertical, theme.spacing.xs)
                .background(
                    Capsule()
                        .fill(reaction.isSelected ? theme.colors.accent.opacity(0.2) : theme.colors.surface)
                        .overlay(
                            Capsule()
                                .stroke(
                                    reaction.isSelected ? theme.colors.accent : theme.colors.secondary,
                                    lineWidth: 1
                                )
                        )
                )
                .onTapGesture {
                    if let selectedMessage = selectedMessageForReaction {
                        if reaction.isSelected {
                            dataSource.removeReaction(from: selectedMessage, reaction: reaction.emoji)
                        } else {
                            dataSource.reactToMessage(selectedMessage, reaction: reaction.emoji)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Message Metadata
    private var messageMetadata: some View {
        HStack(spacing: theme.spacing.xs) {
            // Status indicator
            statusIcon(for: message.status)
            
            // Timestamp (optional, can be controlled by environment)
            Text(message.timestamp, style: .time)
                .font(.caption2)
                .foregroundColor(theme.colors.textSecondary)
        }
    }
    
    @ViewBuilder
    private func statusIcon(for status: MessageStatus) -> some View {
        switch status {
        case .sending:
            Image(systemName: "clock")
                .foregroundColor(theme.colors.textSecondary)
        case .sent:
            Image(systemName: "checkmark")
                .foregroundColor(theme.colors.textSecondary)
        case .delivered:
            Image(systemName: "checkmark.circle")
                .foregroundColor(theme.colors.textSecondary)
        case .read:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(theme.colors.accent)
        case .failed:
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(theme.colors.error)
        }
    }
}
