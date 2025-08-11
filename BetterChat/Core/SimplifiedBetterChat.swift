import SwiftUI

// MARK: - Simplified BetterChat API

public struct BetterChatView<DataSource: ChatDataSource, AccessoryContent: View, InputAccessoryContent: View, SuggestionContent: View>: View {
    @ObservedObject private var dataSource: DataSource
    @Environment(\.chatTheme) private var theme
    
    private let reactions: [String]
    private let accessoryView: () -> AccessoryContent
    private let inputAccessoryView: () -> InputAccessoryContent
    private let suggestionView: (String) -> SuggestionContent
    
    @State private var inputText = ""
    @State private var selectedMessageForReaction: DataSource.Message?
    @State private var showInputAccessory = false
    
    public init(
        dataSource: DataSource,
        reactions: [String] = ["👍", "👎"],
        @ViewBuilder accessoryView: @escaping () -> AccessoryContent = { EmptyView() },
        @ViewBuilder inputAccessoryView: @escaping () -> InputAccessoryContent = { EmptyView() },
        @ViewBuilder suggestionView: @escaping (String) -> SuggestionContent = { _ in EmptyView() }
    ) {
        self.dataSource = dataSource
        self.reactions = reactions
        self.accessoryView = accessoryView
        self.inputAccessoryView = inputAccessoryView
        self.suggestionView = suggestionView
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Messages
            messagesScrollView
            
            // Input area with all slots
            VStack(spacing: 0) {
                // Suggestion view (above input)
                if !inputText.isEmpty {
                    suggestionView(inputText)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Input accessory view (persistent bar above input field)
                inputAccessoryView()
                    .frame(maxWidth: .infinity)
                
                // Main input row
                SimplifiedInputArea(
                    dataSource: dataSource,
                    inputText: $inputText,
                    accessoryView: accessoryView
                )
            }
            .animation(.easeInOut(duration: 0.2), value: showInputAccessory)
            .animation(.easeInOut(duration: 0.2), value: !inputText.isEmpty)
        }
    }
    
    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: theme.spacing.sm) {
                    ForEach(dataSource.messages, id: \.id) { message in
                        SimplifiedMessageRow(
                            message: message,
                            dataSource: dataSource,
                            reactions: reactions,
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
    }
}

// MARK: - Simplified Input Area

struct SimplifiedInputArea<DataSource: ChatDataSource, AccessoryContent: View>: View {
    @ObservedObject var dataSource: DataSource
    @Binding var inputText: String
    let accessoryView: () -> AccessoryContent
    
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.chatTheme) private var theme
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            // Accessory slot (left side)
            accessoryView()
                .frame(width: 34, height: 34)
            
            // Text input
            HStack(alignment: .bottom) {
                TextField("Message", text: $inputText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.system(size: 17))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .lineLimit(1...5)
                    .focused($isTextFieldFocused)
                
                // Send button
                if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Button(action: sendMessage) {
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
            .padding(.trailing, 6)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 5)
    }
    
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        dataSource.sendMessage(text: text, attachments: [])
        inputText = ""
    }
}

// MARK: - Simplified Message Row

struct SimplifiedMessageRow<DataSource: ChatDataSource>: View {
    let message: DataSource.Message
    @ObservedObject var dataSource: DataSource
    let reactions: [String]
    @Binding var selectedMessageForReaction: DataSource.Message?
    
    @Environment(\.chatTheme) private var theme
    
    var body: some View {
        HStack {
            if message.sender == .currentUser {
                Spacer(minLength: theme.layout.bubbleMaxWidth * 0.3)
            }
            
            VStack(alignment: message.sender == .currentUser ? .trailing : .leading, spacing: 4) {
                // Message bubble
                messageContent
                    .chatBubble(role: message.sender == .currentUser ? .user : .assistant)
                    .onLongPressGesture {
                        withAnimation {
                            selectedMessageForReaction = selectedMessageForReaction?.id == message.id ? nil : message
                        }
                    }
                    .overlay(alignment: .top) {
                        if selectedMessageForReaction?.id == message.id {
                            reactionPicker
                        }
                    }
                
                // Reactions display
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

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @Environment(\.chatTheme) private var theme
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(theme.colors.textSecondary)
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(theme.colors.secondary)
            .clipShape(Capsule())
            
            Spacer()
        }
    }
}

// MARK: - Simplified BetterChat Entry Point

extension BetterChat {
    /// Simplified chat view with customization slots
    public static func simpleChatView<DataSource: ChatDataSource>(
        dataSource: DataSource,
        reactions: [String] = ["👍", "👎"]
    ) -> some View {
        BetterChatView(
            dataSource: dataSource,
            reactions: reactions
        )
    }
    
    /// Chat view with all customization slots
    public static func customChatView<DataSource: ChatDataSource, A: View, I: View, S: View>(
        dataSource: DataSource,
        reactions: [String] = ["👍", "👎"],
        @ViewBuilder accessoryView: @escaping () -> A = { EmptyView() },
        @ViewBuilder inputAccessoryView: @escaping () -> I = { EmptyView() },
        @ViewBuilder suggestionView: @escaping (String) -> S = { _ in EmptyView() }
    ) -> some View {
        BetterChatView(
            dataSource: dataSource,
            reactions: reactions,
            accessoryView: accessoryView,
            inputAccessoryView: inputAccessoryView,
            suggestionView: suggestionView
        )
    }
}