import SwiftUI
import Combine

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
        sendButtonIcon: Image = Image(systemName: "arrow.up.circle.fill"),
        attachmentActions: [AttachmentAction] = []
    ) {
        self.dataSource = dataSource
        self.configuration = configuration
        self.sendButtonIcon = sendButtonIcon
        self.attachmentActions = attachmentActions
        self.viewModel = ChatViewModel(dataSource: dataSource)
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
                }
                .padding(.bottom, 90)
                .padding(.top, 10)
            }
            .background(configuration.generalStyle.backgroundColor)
            .onReceive(viewModel.scrollPublisher) { messageId in
                withAnimation(.easeOut(duration: 0.3)) {
                    proxy.scrollTo(messageId, anchor: .bottom)
                }
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.height > 50 {
                        NotificationCenter.default.post(name: .dismissKeyboard, object: nil)
                    }
                }
        )
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
                    ForEach(["❤️", "👍", "😂", "😮", "😢", "🔥"], id: \.self) { emoji in
                        Text(emoji)
                            .font(.system(size: 30))
                            .onTapGesture {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    dataSource.onReaction(emoji, to: message)
                                    selectedMessageForReaction = nil
                                }
                            }
                    }
                    
                    if message.reactionType != nil {
                        Text("✕")
                            .font(.system(size: 24))
                            .foregroundColor(.secondary)
                            .onTapGesture {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    dataSource.onReaction("", to: message)
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
                dataSource.onRetryMessage(message)
            } else if selectedMessageForReaction != nil {
                withAnimation(.easeOut(duration: 0.2)) {
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

