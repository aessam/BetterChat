import SwiftUI
import Combine

// Wrapper for heterogeneous items in the chat
enum ChatItemWrapper<Message: MessageProtocol>: Identifiable {
    case message(Message)
    case thinkingSession(ThinkingSession)
    
    var id: String {
        switch self {
        case .message(let message):
            return message.id
        case .thinkingSession(let session):
            return session.id
        }
    }
    
    var timestamp: Date {
        switch self {
        case .message(let message):
            return message.timestamp
        case .thinkingSession(let session):
            return session.timestamp
        }
    }
}

public struct ChatView<DataSource: ChatDataSource>: View {
    @ObservedObject private var viewModel: ChatViewModel<DataSource>
    @State private var inputText = ""
    @State private var attachments: [Any] = []
    @State private var selectedMessageForReaction: DataSource.Message?
    
    private let dataSource: DataSource
    private let configuration: ChatConfiguration
    private let sendButtonIcon: Image
    private let attachmentActions: [AttachmentAction]
    
    public init(
        dataSource: DataSource,
        configuration: ChatConfiguration = ChatConfiguration(),
        sendButtonIcon: Image = Image(systemName: ChatConstants.SystemNames.sendButton),
        attachmentActions: [AttachmentAction] = []
    ) {
        self.dataSource = dataSource
        self.configuration = configuration
        self.sendButtonIcon = sendButtonIcon
        self.attachmentActions = attachmentActions
        self.viewModel = ChatViewModel(dataSource: dataSource)
    }
    
    // MARK: - Convenience Initializers
    public init(dataSource: DataSource) {
        self.init(
            dataSource: dataSource,
            configuration: .standard()
        )
    }
    
    public init(dataSource: DataSource, theme: ChatTheme) {
        self.init(
            dataSource: dataSource,
            configuration: .themed(theme)
        )
    }
    
    public init(dataSource: DataSource, configuration: ChatConfiguration) {
        self.init(
            dataSource: dataSource,
            configuration: configuration,
            sendButtonIcon: Image(systemName: ChatConstants.SystemNames.sendButton),
            attachmentActions: []
        )
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                messagesView
                inputView
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(dataSource.messages) { message in
                        // Show completed thinking sessions that belong to this message
                        ForEach(dataSource.completedThinkingSessions.filter { $0.timestamp < message.timestamp && isNearestToMessage($0, message: message) }) { session in
                            ThinkingIndicatorView(
                                thoughts: session.thoughts,
                                configuration: configuration,
                                isThinking: false
                            )
                            .id(session.id)
                        }
                        
                        MessageRow(
                            message: message,
                            configuration: configuration,
                            content: dataSource.messageContent(for: message),
                            dataSource: dataSource,
                            selectedMessageForReaction: $selectedMessageForReaction
                        )
                        .id(message.id)
                        .zIndex(selectedMessageForReaction?.id == message.id ? 1 : 0)
                    }
                    
                    // Show active thinking indicator
                    if dataSource.isThinking {
                        ThinkingIndicatorView(
                            thoughts: dataSource.thinkingThoughts,
                            configuration: configuration,
                            isThinking: true
                        )
                        .id("active-thinking-indicator")
                    }
                    
                    // Show typing indicator
                    if dataSource.isTyping {
                        TypingIndicatorView(configuration: configuration)
                            .id("typing-indicator")
                    }
                }
                .padding(.bottom, ChatConstants.Spacing.sectionSpacing)
                .padding(.top, ChatConstants.Spacing.sectionSpacing)
            }
            .chatContainer(configuration: configuration)
            .onReceive(viewModel.scrollPublisher) { messageId in
                withAnimation(.easeOut(duration: configuration.generalStyle.animationDuration)) {
                    proxy.scrollTo(messageId, anchor: .bottom)
                }
            }
        }
    }
    
    private var inputView: some View {
        MessageInputView(
            text: $inputText,
            configuration: configuration,
            attachments: attachments,
            sendButtonIcon: sendButtonIcon,
            attachmentActions: attachmentActions,
            attachmentPreview: { attachment in
                dataSource.attachmentPreview(for: attachment)
            },
            onSend: {
                guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !attachments.isEmpty else { return }
                dataSource.onSendMessage(text: inputText, attachments: attachments)
                inputText = ""
                attachments = []
            },
            onAttachment: { attachment in
                attachments.append(attachment)
            },
            onRemoveAttachment: { index in
                attachments.remove(at: index)
            }
        )
        .background(Color(.systemBackground))
    }
    
    private func isNearestToMessage(_ session: ThinkingSession, message: DataSource.Message) -> Bool {
        // Find the next message after this thinking session
        let nextMessage = dataSource.messages
            .filter { $0.timestamp > session.timestamp }
            .min { $0.timestamp < $1.timestamp }
        
        return nextMessage?.id == message.id
    }
    
}

struct MessageRow<DataSource: ChatDataSource, Content: View>: View {
    let message: DataSource.Message
    let configuration: ChatConfiguration
    let content: Content
    let dataSource: DataSource
    @Binding var selectedMessageForReaction: DataSource.Message?
    
    var body: some View {
        ChatBubbleView(
            message: message,
            configuration: configuration,
            content: content,
            showReaction: true
        )
        .overlay(alignment: .top) {
            // Reaction picker overlay
            if selectedMessageForReaction?.id == message.id {
                HStack(spacing: 8) {
                    ForEach(ChatConstants.Reactions.defaultEmojis, id: \.self) { emoji in
                        Text(emoji)
                            .font(.system(size: ChatConstants.FontSizes.reactionIcon))
                            .onTapGesture {
                                withAnimation(.easeOut(duration: ChatConstants.Animation.reactionTransition)) {
                                    dataSource.onReaction(emoji, to: message)
                                    selectedMessageForReaction = nil
                                }
                            }
                    }
                    
                    if message.reactionType != nil {
                        Text(ChatConstants.Reactions.removeSymbol)
                            .font(.system(size: ChatConstants.FontSizes.title))
                            .foregroundColor(.secondary)
                            .onTapGesture {
                                withAnimation(.easeOut(duration: ChatConstants.Animation.reactionTransition)) {
                                    dataSource.onReaction("", to: message)
                                    selectedMessageForReaction = nil
                                }
                            }
                    }
                }
                .reactionOverlay()
            }
        }
        .onLongPressGesture {
            withAnimation(.easeOut(duration: ChatConstants.Animation.reactionTransition)) {
                if selectedMessageForReaction?.id == message.id {
                    selectedMessageForReaction = nil
                } else {
                    selectedMessageForReaction = message
                }
            }
        }
        .onTapGesture {
            if message.status == .failed {
                dataSource.onRetryMessage(message)
            } else if selectedMessageForReaction != nil {
                withAnimation(.easeOut(duration: ChatConstants.Animation.reactionTransition)) {
                    selectedMessageForReaction = nil
                }
            }
        }
    }
}

class ChatViewModel<DataSource: ChatDataSource>: ObservableObject {
    let scrollPublisher = PassthroughSubject<String, Never>()
    private let dataSource: DataSource
    
    init(dataSource: DataSource) {
        self.dataSource = dataSource
    }
    
    func scrollToBottom() {
        if let lastMessage = dataSource.messages.last {
            scrollPublisher.send(lastMessage.id)
        }
    }
}

