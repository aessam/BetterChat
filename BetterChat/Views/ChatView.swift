import SwiftUI
import Combine

public struct ChatView<DataSource: ChatDataSource>: View {
    @ObservedObject private var viewModel: ChatViewModel<DataSource>
    @State private var inputText = ""
    @State private var attachments: [Any] = []
    @State private var selectedMessage: DataSource.Message?
    @State private var showReactionPicker = false
    @State private var showAttachmentMenu = false
    @FocusState private var isTextFieldFocused: Bool
    
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
        .sheet(isPresented: $showReactionPicker) {
            reactionPickerSheet
        }
        .sheet(isPresented: $showAttachmentMenu) {
            attachmentMenuSheet
        }
    }
    
    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(dataSource.messages) { message in
                        ChatBubbleView(
                            message: message,
                            configuration: configuration,
                            content: dataSource.messageContent(for: message),
                            showReaction: true
                        )
                        .id(message.id)
                        .onLongPressGesture {
                            selectedMessage = message
                            showReactionPicker = true
                        }
                        .onTapGesture {
                            if message.status == .failed {
                                dataSource.onRetryMessage(message)
                            }
                        }
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
            onAttachment: {
                showAttachmentMenu = true
            },
            onRemoveAttachment: { index in
                attachments.remove(at: index)
            }
        )
        .background(Color.white)
    }
    
    @ViewBuilder
    private var reactionPickerSheet: some View {
        if let message = selectedMessage {
            VStack {
                Text("Select Reaction")
                    .font(.headline)
                    .padding()
                
                dataSource.reactionPicker(for: message)
                    .onReceive(NotificationCenter.default.publisher(for: .dismissReactionPicker)) { _ in
                        showReactionPicker = false
                    }
                
                Button("Cancel") {
                    showReactionPicker = false
                }
                .padding()
            }
            .presentationDetents([.height(200)])
        }
    }
    
    private var attachmentMenuSheet: some View {
        AttachmentMenuView(
            actions: attachmentActions,
            onSelection: { attachment in
                if let attachment = attachment {
                    attachments.append(attachment)
                }
                showAttachmentMenu = false
            }
        )
        .presentationDetents([.height(CGFloat(80 * attachmentActions.count + 100))])
    }
}

class ChatViewModel<DataSource: ChatDataSource>: ObservableObject {
    let scrollPublisher = PassthroughSubject<String, Never>()
    private let dataSource: DataSource
    private var cancellables = Set<AnyCancellable>()
    
    init(dataSource: DataSource) {
        self.dataSource = dataSource
        observeMessages()
    }
    
    private func observeMessages() {
        // This would be implemented based on how the data source updates
        // For now, we'll assume manual triggering
    }
    
    func scrollToBottom() {
        if let lastMessage = dataSource.messages.last {
            scrollPublisher.send(lastMessage.id)
        }
    }
}

struct AttachmentMenuView: View {
    let actions: [AttachmentAction]
    let onSelection: (AttachmentItem?) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Add Attachment")
                .font(.headline)
                .padding()
            
            Divider()
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(actions.indices, id: \.self) { index in
                        Button(action: {
                            Task {
                                let item = await actions[index].action()
                                await MainActor.run {
                                    onSelection(item)
                                }
                            }
                        }) {
                            HStack {
                                actions[index].icon
                                    .font(.system(size: 24))
                                    .frame(width: 40)
                                
                                Text(actions[index].title)
                                    .font(.body)
                                
                                Spacer()
                            }
                            .padding()
                        }
                        .foregroundColor(.primary)
                        
                        if index < actions.count - 1 {
                            Divider()
                                .padding(.leading, 60)
                        }
                    }
                }
            }
        }
    }
}