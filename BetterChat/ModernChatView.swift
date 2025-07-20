import SwiftUI
import Combine

// MARK: - Modern Chat View
public struct ModernChatView<DataSource: ChatDataSource>: View {
    @ObservedObject private var dataSource: DataSource
    @Environment(\.chatTheme) private var theme
    
    @State private var inputText = ""
    @State private var selectedAttachments: [Any] = []
    @State private var selectedMessageForReaction: DataSource.Message?
    @FocusState private var isTextFieldFocused: Bool
    
    private let attachmentActions: [AttachmentAction]
    
    public init(
        dataSource: DataSource,
        attachmentActions: [AttachmentAction] = []
    ) {
        self.dataSource = dataSource
        self.attachmentActions = attachmentActions
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                messagesScrollView
                inputArea
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Messages View
    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: theme.spacing.sm) {
                    ForEach(dataSource.messages) { message in
                        messageRow(for: message)
                    }
                    
                    // Thinking indicator
                    if dataSource.isThinking {
                        thinkingIndicator
                    }
                    
                    // Typing indicator
                    if dataSource.isTyping {
                        typingIndicator
                    }
                }
                .padding(.horizontal, theme.spacing.md)
                .padding(.top, theme.spacing.lg)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: dataSource.messages.count) { oldValue, newValue in
                if let lastMessage = dataSource.messages.last {
                    withAnimation(.easeInOut(duration: theme.animation.medium)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - Message Row
    @ViewBuilder
    private func messageRow(for message: DataSource.Message) -> some View {
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
                
                messageContent(for: message)
                    .overlay(alignment: .top) {
                    // Reaction picker overlay - similar to old implementation
                    if selectedMessageForReaction?.id == message.id {
                        HStack(spacing: 8) {
                            ForEach(["❤️", "👍", "😂", "😮", "😢", "🔥"], id: \.self) { emoji in
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
    
    @ViewBuilder
    private func messageContent(for message: DataSource.Message) -> some View {
        VStack(alignment: message.sender == .currentUser ? .trailing : .leading, spacing: theme.spacing.xs) {
            // Message bubble
            messageContentView(for: message)
                .chatBubble(
                    role: message.sender == .currentUser ? .user : .assistant
                )
            
            // Reactions if message supports them
            if let reactableMessage = message as? (any ReactableMessage),
               !reactableMessage.reactions.isEmpty {
                reactionRow(for: reactableMessage.reactions)
            }
            
            // Status and timestamp
            messageMetadata(for: message)
        }
    }
    
    @ViewBuilder
    private func messageContentView(for message: DataSource.Message) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            // Show text if message has text
            if let textMessage = message as? (any TextMessage), !textMessage.text.isEmpty {
                Text(textMessage.text)
            }
            
            // Show attachments if message has them
            if let mediaMessage = message as? (any MediaMessage), !mediaMessage.attachments.isEmpty {
                Text("📎 \(mediaMessage.attachments.count) attachment(s)")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: theme.spacing.sm) {
                    ForEach(mediaMessage.attachments, id: \.id) { attachment in
                        attachmentPreview(for: attachment)
                    }
                }
            }
        }
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
    private func messageMetadata(for message: DataSource.Message) -> some View {
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
    
    // MARK: - Thinking Indicator
    private var thinkingIndicator: some View {
        ThinkingIndicatorView(
            thoughts: dataSource.currentThoughts,
            isThinking: dataSource.isThinking
        )
    }
    
    // MARK: - Typing Indicator
    private var typingIndicator: some View {
        HStack {
            HStack(spacing: theme.spacing.xs) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(theme.colors.textSecondary)
                        .frame(width: 6, height: 6)
                        .scaleEffect(0.8)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                            value: UUID()
                        )
                }
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
            .background(theme.colors.secondary)
            .clipShape(Capsule())
            
            Spacer()
        }
    }
    
    // MARK: - Input Area
    private var inputArea: some View {
        VStack(spacing: 0) {
            // Attachment preview
            if !selectedAttachments.isEmpty {
                attachmentPreviewRow
            }
            
            // Input area - EXACTLY like original
            HStack(alignment: .bottom, spacing: 6) {
                attachmentButton
                textInputContainer
            }
            .padding(.vertical, 5)
            .padding(.bottom, 3)
            .animation(.easeInOut(duration: 0.2), value: inputText.isEmpty)
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(
            Color(.systemBackground)
                .overlay(
                    VStack {
                        Divider()
                        Spacer(minLength: 0)
                    }
                )
        )
    }
    
    // MARK: - Attachment Preview Row
    private var attachmentPreviewRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.sm) {
                ForEach(selectedAttachments.indices, id: \.self) { index in
                    attachmentPreviewView(for: selectedAttachments[index])
                        .overlay(alignment: .topTrailing) {
                            Button {
                                selectedAttachments.remove(at: index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .background(Color.white, in: Circle())
                            }
                            .offset(x: 8, y: -8)
                        }
                }
            }
            .padding(.horizontal, theme.spacing.md)
        }
        .padding(.top, theme.spacing.sm)
    }
    
    // MARK: - Attachment Button
    private var attachmentButton: some View {
        Menu {
            ForEach(attachmentActions.indices, id: \.self) { index in
                Button(action: {
                    Task {
                        if let item = await attachmentActions[index].action() {
                            await MainActor.run {
                                selectedAttachments.append(item)
                            }
                        }
                    }
                }) {
                    Label {
                        Text(attachmentActions[index].title)
                    } icon: {
                        attachmentActions[index].icon
                    }
                }
            }
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color.gray)
                .frame(width: 34, height: 34)
        }
        .padding(.leading, 6)
    }
    
    // MARK: - Text Input Container
    private var textInputContainer: some View {
        HStack(alignment: .bottom, spacing: 0) {
            textField
            sendButtonView
        }
        .background(textFieldBackground)
        .padding(.trailing, 6)
    }
    
    private var textField: some View {
        TextField("iMessage", text: $inputText, axis: .vertical)
            .textFieldStyle(.plain)
            .font(.system(size: 17))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .lineLimit(1...3)
            .frame(minHeight: 34)
            .focused($isTextFieldFocused)
    }
    
    @ViewBuilder
    private var sendButtonView: some View {
        if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
            }
            .padding(.trailing, 2)
            .padding(.bottom, 1)
            .transition(.scale.combined(with: .opacity))
        }
    }
    
    private var textFieldBackground: some View {
        RoundedRectangle(cornerRadius: 17)
            .fill(Color(.systemGray6))
            .overlay(
                RoundedRectangle(cornerRadius: 17)
                    .stroke(Color(.systemGray4), lineWidth: 0.5)
            )
    }
    
    
    // MARK: - Helper Methods
    private var canSendMessage: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !selectedAttachments.isEmpty
    }
    
    private func sendMessage() {
        guard canSendMessage else { return }
        
        // Try to convert Any attachments to the expected DataSource.Attachment type
        let convertedAttachments = selectedAttachments.compactMap { $0 as? DataSource.Attachment }
        dataSource.sendMessage(text: inputText, attachments: convertedAttachments)
        inputText = ""
        selectedAttachments.removeAll()
    }
    
    // MARK: - Attachment Preview View
    @ViewBuilder  
    private func attachmentPreviewView(for attachment: Any) -> some View {
        if let imageAttachment = attachment as? ImageAttachment {
            // Show actual image attachment
            (imageAttachment.thumbnail ?? imageAttachment.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60)
                .clipped()
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                )
        } else if let stringAttachment = attachment as? String {
            // Show preview for string-based attachments
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.1))
                .frame(width: 60, height: 60)
                .overlay {
                    VStack(spacing: 4) {
                        Image(systemName: stringAttachment.contains("photo") ? "photo" : 
                                         stringAttachment.contains("camera") ? "camera" : "doc")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text(stringAttachment.contains("photo") ? "Photo" : 
                             stringAttachment.contains("camera") ? "Camera" : "Doc")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 0.5)
                )
        } else {
            // Fallback for any other attachment type
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: "doc")
                        .foregroundColor(.gray)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                )
        }
    }
    
}

// MARK: - Convenience Extensions
public extension ModernChatView {
    // Chainable configuration
    func attachments(_ actions: [AttachmentAction]) -> some View {
        ModernChatView(dataSource: dataSource, attachmentActions: actions)
    }
}