import SwiftUI
import Combine

/// A modern, customizable chat interface built with SwiftUI.
///
/// `ModernChatView` provides a complete chat experience with support for:
/// - Text messaging with real-time updates
/// - Rich attachments (images, documents, etc.)
/// - Message reactions and interactions
/// - Thinking processes for AI conversations
/// - Comprehensive theming system
///
/// ## Usage
///
/// Basic implementation with a data source:
///
/// ```swift
/// ModernChatView(dataSource: myDataSource)
///     .chatTheme(.blue)
/// ```
///
/// With attachment support:
///
/// ```swift
/// ModernChatView(
///     dataSource: myDataSource,
///     attachmentActions: [
///         AttachmentAction(
///             title: "Photo",
///             icon: Image(systemName: "photo"),
///             action: { /* return attachment */ }
///         )
///     ]
/// )
/// ```
///
/// - Important: Your data source must conform to ``ChatDataSource`` protocol.
/// - Note: The view automatically handles keyboard management and scroll behavior.
public struct ModernChatView<DataSource: ChatDataSource>: View {
    /// The data source that provides messages and handles chat operations.
    @ObservedObject private var dataSource: DataSource
    
    /// The current theme applied to the chat interface.
    @Environment(\.chatTheme) private var theme
    
    /// The current input text being typed by the user.
    @State private var inputText = ""
    
    /// Currently selected attachments to be sent with the next message.
    @State private var selectedAttachments: [Any] = []
    
    /// The message currently selected for reaction (if any).
    @State private var selectedMessageForReaction: DataSource.Message?
    @State private var scrollTarget: String?
    @State private var scrollTask: Task<Void, Never>?
    
    /// Available attachment actions for the input area.
    private let attachmentActions: [AttachmentAction]
    
    /// Creates a new chat view with the specified data source and attachment actions.
    ///
    /// - Parameters:
    ///   - dataSource: The data source conforming to ``ChatDataSource`` that manages chat data.
    ///   - attachmentActions: Optional array of ``AttachmentAction`` objects for handling attachments.
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
                
                InputArea(
                    dataSource: dataSource,
                    inputText: $inputText,
                    selectedAttachments: $selectedAttachments,
                    attachmentActions: attachmentActions
                )
            }
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
        }
        #if os(iOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
    
    // MARK: - Messages View
    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: theme.spacing.sm) {
                    ForEach(dataSource.messages, id: \.id) { message in
                        MessageRow(
                            message: message,
                            dataSource: dataSource,
                            selectedMessageForReaction: $selectedMessageForReaction
                        )
                        .id(message.id)
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
                guard newValue > oldValue else { return }
                if let lastMessage = dataSource.messages.last {
                    // Debounce scrolling to avoid excessive animations
                    scrollTask?.cancel()
                    scrollTask = Task {
                        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s debounce
                        if !Task.isCancelled {
                            await MainActor.run {
                                withAnimation(.easeInOut(duration: theme.animation.medium)) {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
            }
            .onDisappear {
                scrollTask?.cancel()
            }
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
}

// MARK: - Convenience Extensions
public extension ModernChatView {
    // Chainable configuration
    func attachments(_ actions: [AttachmentAction]) -> some View {
        ModernChatView(dataSource: dataSource, attachmentActions: actions)
    }
}