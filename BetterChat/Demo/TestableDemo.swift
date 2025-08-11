import SwiftUI
import Combine

// MARK: - Testable Demo with Feature Toggles

struct TestableMessage: ChatMessage, TextMessage, ReactableMessage {
    let id = UUID().uuidString
    let timestamp = Date()
    let sender: MessageSender
    var status = MessageStatus.sent
    let text: String
    var reactions: [Reaction]
}

class TestableDataSource: ObservableObject, ChatDataSource {
    typealias Message = TestableMessage
    typealias Attachment = ImageAttachment
    
    @Published var messages: [TestableMessage] = [
        TestableMessage(sender: .otherUser, text: "Test all features with the toggles above!", reactions: []),
        TestableMessage(sender: .currentUser, text: "Double-tap messages for reactions", reactions: [])
    ]
    @Published var isTyping = false
    @Published var isThinking = false
    @Published var currentThoughts: [ThinkingThought] = []
    @Published var completedThinkingSessions: [ThinkingSession] = []
    
    func sendMessage(text: String, attachments: [ImageAttachment]) {
        messages.append(TestableMessage(sender: .currentUser, text: text, reactions: []))
        
        // Auto-reply
        Task { @MainActor in
            isTyping = true
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            isTyping = false
            messages.append(TestableMessage(sender: .otherUser, text: "Received: \(text)", reactions: []))
        }
    }
    
    func retryMessage(_ message: TestableMessage) {}
    
    func reactToMessage(_ message: TestableMessage, reaction: String) {
        guard let i = messages.firstIndex(where: { $0.id == message.id }) else { return }
        var reactions = messages[i].reactions
        if let existingIndex = reactions.firstIndex(where: { $0.emoji == reaction }) {
            reactions[existingIndex].count += 1
        } else {
            reactions.append(Reaction(emoji: reaction, count: 1, isSelected: true))
        }
        messages[i].reactions = reactions
    }
    
    func removeReaction(from message: TestableMessage, reaction: String) {
        guard let i = messages.firstIndex(where: { $0.id == message.id }) else { return }
        messages[i].reactions.removeAll { $0.emoji == reaction }
    }
}

// MARK: - Testable Demo View

struct TestableDemoView: View {
    @StateObject private var dataSource = TestableDataSource()
    
    // Feature toggles
    @State private var showAttachButton = true
    @State private var showInputAccessory = true
    @State private var showMentions = true
    @State private var enableReactions = true
    
    // UI State
    @State private var attachmentTapped = ""
    @State private var currentMessage = "Quick actions bar"
    
    var body: some View {
        VStack(spacing: 0) {
            // Control Panel
            controlPanel
            
            Divider()
            
            // Chat View
            chatView
        }
    }
    
    private var controlPanel: some View {
        VStack(spacing: 12) {
            Text("Feature Controls")
                .font(.headline)
            
            VStack(spacing: 8) {
                Toggle("Attach Button", isOn: $showAttachButton)
                Toggle("Input Accessory Bar", isOn: $showInputAccessory)
                Toggle("Mentions (@/#)", isOn: $showMentions)
                Toggle("Reactions (double-tap)", isOn: $enableReactions)
            }
            .font(.caption)
            .toggleStyle(SwitchToggleStyle(tint: .blue))
            
            if !attachmentTapped.isEmpty {
                Text(attachmentTapped)
                    .font(.caption)
                    .foregroundColor(.orange)
                    .animation(.easeInOut, value: attachmentTapped)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    private var chatView: some View {
        TestableBetterChatView(
            dataSource: dataSource,
            reactions: enableReactions ? ["👍", "👎", "❤️", "😂"] : [],
            enableDoubleTapReactions: enableReactions,
            accessoryView: {
                if showAttachButton {
                    Button(action: {
                        attachmentTapped = "Attachment tapped at \(Date().formatted(date: .omitted, time: .shortened))"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            attachmentTapped = ""
                        }
                    }) {
                        Image(systemName: "paperclip.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                    }
                } else {
                    Color.clear.frame(width: 34, height: 34)
                }
            },
            inputAccessoryView: {
                if showInputAccessory {
                    VStack(spacing: 4) {
                        Text(currentMessage)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 15) {
                            Button(action: {
                                dataSource.sendMessage(text: "Quick: Hello! 👋", attachments: [])
                                currentMessage = "Sent: Hello!"
                                resetMessage()
                            }) {
                                Text("👋 Hello")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                dataSource.sendMessage(text: "Quick: Thanks!", attachments: [])
                                currentMessage = "Sent: Thanks!"
                                resetMessage()
                            }) {
                                Text("🙏 Thanks")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.2))
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                dataSource.sendMessage(text: "Quick: OK", attachments: [])
                                currentMessage = "Sent: OK"
                                resetMessage()
                            }) {
                                Text("✅ OK")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.orange.opacity(0.2))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .overlay(alignment: .top) { Divider() }
                }
            },
            suggestionView: { text in
                if showMentions {
                    if text.contains("@") {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(["@alice", "@bob", "@charlie"], id: \.self) { mention in
                                Button(action: {}) {
                                    HStack {
                                        Image(systemName: "person.circle.fill")
                                            .foregroundColor(.blue)
                                        Text(mention)
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                }
                                Divider()
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                    } else if text.contains("#") {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(["#general", "#random", "#engineering"], id: \.self) { channel in
                                Button(action: {}) {
                                    HStack {
                                        Image(systemName: "number.circle.fill")
                                            .foregroundColor(.green)
                                        Text(channel)
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                }
                                Divider()
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                    }
                }
            }
        )
        .chatTheme(ChatThemePreset.blue)
    }
    
    private func resetMessage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            currentMessage = "Quick actions bar"
        }
    }
}

// MARK: - Custom Chat View with Double Tap

struct TestableBetterChatView<DataSource: ChatDataSource, AccessoryContent: View, InputAccessoryContent: View, SuggestionContent: View>: View {
    @ObservedObject private var dataSource: DataSource
    @Environment(\.chatTheme) private var theme
    
    private let reactions: [String]
    private let enableDoubleTapReactions: Bool
    private let accessoryView: () -> AccessoryContent
    private let inputAccessoryView: () -> InputAccessoryContent
    private let suggestionView: (String) -> SuggestionContent
    
    @State private var inputText = ""
    @State private var selectedMessageForReaction: DataSource.Message?
    
    init(
        dataSource: DataSource,
        reactions: [String] = ["👍", "👎"],
        enableDoubleTapReactions: Bool = true,
        @ViewBuilder accessoryView: @escaping () -> AccessoryContent = { EmptyView() },
        @ViewBuilder inputAccessoryView: @escaping () -> InputAccessoryContent = { EmptyView() },
        @ViewBuilder suggestionView: @escaping (String) -> SuggestionContent = { _ in EmptyView() }
    ) {
        self.dataSource = dataSource
        self.reactions = reactions
        self.enableDoubleTapReactions = enableDoubleTapReactions
        self.accessoryView = accessoryView
        self.inputAccessoryView = inputAccessoryView
        self.suggestionView = suggestionView
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: theme.spacing.sm) {
                        ForEach(dataSource.messages, id: \.id) { message in
                            TestableMessageRow(
                                message: message,
                                dataSource: dataSource,
                                reactions: reactions,
                                enableDoubleTap: enableDoubleTapReactions,
                                selectedMessageForReaction: $selectedMessageForReaction
                            )
                            .id(message.id)
                        }
                        
                        if dataSource.isTyping {
                            TypingIndicator()
                        }
                    }
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.vertical, theme.spacing.lg)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: dataSource.messages.count) { oldValue, newValue in
                    if newValue > oldValue, let lastMessage = dataSource.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input area
            VStack(spacing: 0) {
                if !inputText.isEmpty {
                    suggestionView(inputText)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                inputAccessoryView()
                    .frame(maxWidth: .infinity)
                
                SimplifiedInputArea(
                    dataSource: dataSource,
                    inputText: $inputText,
                    accessoryView: accessoryView
                )
            }
            .animation(.easeInOut(duration: 0.2), value: !inputText.isEmpty)
        }
    }
}

// MARK: - Message Row with Double Tap

struct TestableMessageRow<DataSource: ChatDataSource>: View {
    let message: DataSource.Message
    @ObservedObject var dataSource: DataSource
    let reactions: [String]
    let enableDoubleTap: Bool
    @Binding var selectedMessageForReaction: DataSource.Message?
    
    @Environment(\.chatTheme) private var theme
    
    var body: some View {
        HStack {
            if message.sender == .currentUser {
                Spacer(minLength: theme.layout.bubbleMaxWidth * 0.3)
            }
            
            VStack(alignment: message.sender == .currentUser ? .trailing : .leading, spacing: 4) {
                messageContent
                    .chatBubble(role: message.sender == .currentUser ? .user : .assistant)
                    .onTapGesture(count: 2) {
                        if enableDoubleTap {
                            withAnimation {
                                selectedMessageForReaction = selectedMessageForReaction?.id == message.id ? nil : message
                            }
                        }
                    }
                    .overlay(alignment: .top) {
                        if selectedMessageForReaction?.id == message.id {
                            reactionPicker
                        }
                    }
                
                if let reactable = message as? any ReactableMessage,
                   !reactable.reactions.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(reactable.reactions, id: \.id) { reaction in
                            Text("\(reaction.emoji) \(reaction.count)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.gray.opacity(0.2)))
                        }
                    }
                }
            }
            
            if message.sender != .currentUser {
                Spacer(minLength: theme.layout.bubbleMaxWidth * 0.3)
            }
        }
    }
    
    @ViewBuilder
    private var messageContent: some View {
        if let textMessage = message as? any TextMessage {
            Text(textMessage.text)
        }
    }
    
    private var reactionPicker: some View {
        HStack(spacing: 12) {
            ForEach(reactions, id: \.self) { emoji in
                Text(emoji)
                    .font(.system(size: 24))
                    .onTapGesture {
                        dataSource.reactToMessage(message, reaction: emoji)
                        selectedMessageForReaction = nil
                    }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(radius: 8)
        )
        .offset(y: -40)
        .transition(.scale.combined(with: .opacity))
        .zIndex(1)
    }
}

// MARK: - App Entry

@main
struct TestableApp: App {
    var body: some Scene {
        WindowGroup {
            TestableDemoView()
        }
    }
}
