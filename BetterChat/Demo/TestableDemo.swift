import SwiftUI
import Combine

// MARK: - Testable Demo with Feature Toggles

// MARK: - Content Protocols
public protocol TextMessage: ChatMessage {
    var text: String { get }
}

public protocol MediaMessage: ChatMessage {
    associatedtype Attachment: ChatAttachment
    var attachments: [Attachment] { get }
}

public protocol ReactableMessage: ChatMessage {
    var reactions: [Reaction] { get }
}


// Custom message type for shelf display
struct ShelfMessage: ChatMessage, ReactableMessage {
    let id = UUID().uuidString
    let timestamp = Date()
    let sender: MessageSender
    var status = MessageStatus.sent
    var reactions: [Reaction]
    let shelves: [[String]] // Array of shelves, each containing items
}

struct TestableMessage: ChatMessage, TextMessage, ReactableMessage {
    let id = UUID().uuidString
    let timestamp = Date()
    let sender: MessageSender
    var status = MessageStatus.sent
    let text: String
    var reactions: [Reaction]
}

// Protocol for any message type in our demo
protocol DemoMessage: ChatMessage, ReactableMessage {}

extension TestableMessage: DemoMessage {}
extension ShelfMessage: DemoMessage {}

class TestableDataSource: ObservableObject {
    typealias Attachment = ImageAttachment
    
    @Published var messages: [any DemoMessage] = [
        TestableMessage(sender: .otherUser, text: "Hello! I'm Claude 🤖 Double-tap any message to react with stickers!", reactions: []),
        TestableMessage(sender: .currentUser, text: "Cool! Show me what you can do", reactions: []),
        TestableMessage(sender: .otherUser, text: "Send '📷' to see shelf layout example", reactions: [])
    ]
    @Published var isTyping = false
    @Published var isThinking = false
    @Published var currentThoughts: [ThinkingThought] = []
    @Published var completedThinkingSessions: [ThinkingSession] = []
    
    func sendMessage(text: String, attachments: [ImageAttachment]) {
        messages.append(TestableMessage(sender: .currentUser, text: text, reactions: []))
        
        // Check if user sent camera/media emoji - respond with shelf message
        if text.contains("📷") || text.contains("🖼") || text.contains("media") {
            Task { @MainActor in
                isTyping = true
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                isTyping = false
                
                // Send a shelf message with 3 horizontal scrollable shelves
                let shelfMessage = ShelfMessage(
                    sender: .otherUser,
                    reactions: [],
                    shelves: [
                        ["🏞 Landscapes", "🌅 Sunsets", "🏔 Mountains", "🏖 Beaches"],
                        ["🐕 Dogs", "🐈 Cats", "🦜 Birds", "🐠 Fish", "🦋 Butterflies"],
                        ["🍕 Pizza", "🍔 Burgers", "🍣 Sushi", "🥗 Salads", "🍰 Desserts"]
                    ]
                )
                messages.append(shelfMessage)
            }
        } else {
            // Regular text reply
            Task { @MainActor in
                isTyping = true
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                isTyping = false
                messages.append(TestableMessage(sender: .otherUser, text: "Received: \(text)", reactions: []))
            }
        }
    }
    
    func retryMessage(_ message: any DemoMessage) {}
    
    func reactToMessage(_ message: any DemoMessage, reaction: String) {
        guard let i = messages.firstIndex(where: { $0.id == message.id }) else { return }
        
        // Update reactions based on message type
        if var textMsg = messages[i] as? TestableMessage {
            textMsg.reactions = [Reaction(emoji: reaction, count: 1, isSelected: true)]
            messages[i] = textMsg
        } else if var shelfMsg = messages[i] as? ShelfMessage {
            shelfMsg.reactions = [Reaction(emoji: reaction, count: 1, isSelected: true)]
            messages[i] = shelfMsg
        }
    }
    
    func removeReaction(from message: any DemoMessage, reaction: String) {
        guard let i = messages.firstIndex(where: { $0.id == message.id }) else { return }
        
        if var textMsg = messages[i] as? TestableMessage {
            textMsg.reactions.removeAll()
            messages[i] = textMsg
        } else if var shelfMsg = messages[i] as? ShelfMessage {
            shelfMsg.reactions.removeAll()
            messages[i] = shelfMsg
        }
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
            reactions: enableReactions ? ["🤖", "🧠", "✨", "🎯", "💭", "🔮"] : [],
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
                                dataSource.sendMessage(text: "📷 Show me media", attachments: [])
                                currentMessage = "Sent: Media request!"
                                resetMessage()
                            }) {
                                Text("📷 Media")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.2))
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                dataSource.sendMessage(text: "Can you help me with this? 🤖", attachments: [])
                                currentMessage = "Sent: Help request!"
                                resetMessage()
                            }) {
                                Text("🤖 Help")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                dataSource.sendMessage(text: "That's brilliant! ✨", attachments: [])
                                currentMessage = "Sent: Brilliant!"
                                resetMessage()
                            }) {
                                Text("✨ Nice")
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

struct TestableBetterChatView<AccessoryContent: View, InputAccessoryContent: View, SuggestionContent: View>: View {
    @ObservedObject private var dataSource: TestableDataSource
    @Environment(\.chatTheme) private var theme
    
    private let reactions: [String]
    private let enableDoubleTapReactions: Bool
    private let accessoryView: () -> AccessoryContent
    private let inputAccessoryView: () -> InputAccessoryContent
    private let suggestionView: (String) -> SuggestionContent
    
    @State private var inputText = ""
    @State private var selectedMessageForReaction: (any DemoMessage)?
    
    init(
        dataSource: TestableDataSource,
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
                
                HStack(alignment: .bottom, spacing: 6) {
                    accessoryView()
                        .frame(minWidth: 0, maxWidth: 34, minHeight: 0, maxHeight: 34)
                    
                    HStack(alignment: .bottom) {
                        TextField("Message", text: $inputText, axis: .vertical)
                            .textFieldStyle(.plain)
                            .font(.system(size: 17))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .lineLimit(1...5)
                        
                        if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Button(action: {
                                let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                                guard !text.isEmpty else { return }
                                dataSource.sendMessage(text: text, attachments: [])
                                inputText = ""
                            }) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.blue)
                            }
                            .padding(.trailing, 2)
                            .padding(.bottom, 1)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 17)
                            .fill(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 17)
                                    .stroke(Color(.systemGray4), lineWidth: 0.5)
                            )
                    )
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
            }
            .animation(.easeInOut(duration: 0.2), value: !inputText.isEmpty)
        }
    }
}

// MARK: - Shelf Message View

struct ShelfMessageView: View {
    let shelves: [[String]]
    @Environment(\.chatTheme) private var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(shelves.enumerated()), id: \.offset) { index, shelf in
                VStack(alignment: .leading, spacing: 4) {
                    Text("Shelf \(index + 1)")
                        .font(.caption)
                        .foregroundColor(theme.colors.textSecondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(shelf, id: \.self) { item in
                                VStack {
                                    Text(String(item.prefix(2)))
                                        .font(.title2)
                                    Text(String(item.dropFirst(2)).trimmingCharacters(in: .whitespaces))
                                        .font(.caption2)
                                        .lineLimit(1)
                                }
                                .frame(width: 80, height: 80)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue.opacity(0.1))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                    }
                }
            }
        }
        .padding(12)
    }
}

// MARK: - Message Row with Double Tap

struct TestableMessageRow: View {
    let message: any DemoMessage
    let dataSource: TestableDataSource
    let reactions: [String]
    let enableDoubleTap: Bool
    @Binding var selectedMessageForReaction: (any DemoMessage)?
    
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
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedMessageForReaction = selectedMessageForReaction?.id == message.id ? nil : message
                            }
                        }
                    }
                    .overlay(alignment: .top) {
                        if selectedMessageForReaction?.id == message.id {
                            reactionPicker
                        }
                    }
                
                if let reaction = message.reactions.first {
                    // Only show the emoji, no counter
                    Text(reaction.emoji)
                        .font(.system(size: 16))
                        .padding(4)
                        .background(Circle().fill(Color.blue.opacity(0.1)))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            if message.sender != .currentUser {
                Spacer(minLength: theme.layout.bubbleMaxWidth * 0.3)
            }
        }
    }
    
    @ViewBuilder
    private var messageContent: some View {
        if let textMessage = message as? TestableMessage {
            Text(textMessage.text)
        } else if let shelfMessage = message as? ShelfMessage {
            ShelfMessageView(shelves: shelfMessage.shelves)
        }
    }
    
    private var reactionPicker: some View {
        HStack(spacing: 12) {
            ForEach(reactions, id: \.self) { emoji in
                Text(emoji)
                    .font(.system(size: 24))
                    .scaleEffect(1.0)
                    .onTapGesture {
                        // Instant feedback
                        withAnimation(.easeOut(duration: 0.1)) {
                            dataSource.reactToMessage(message, reaction: emoji)
                            selectedMessageForReaction = nil
                        }
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
        .transition(.scale(scale: 0.8).combined(with: .opacity))
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
