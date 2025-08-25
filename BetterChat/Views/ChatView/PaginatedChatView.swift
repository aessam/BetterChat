import SwiftUI
import Combine

/// A performance-optimized chat view with pagination support for large message lists.
///
/// `PaginatedChatView` provides efficient memory management by loading messages
/// in pages and keeping only a window of messages in memory at once.
///
/// ## Features
/// - Automatic pagination when scrolling
/// - Configurable page size and window size
/// - Memory-efficient for thousands of messages
/// - Smooth scrolling performance
///
/// ## Usage
/// ```swift
/// PaginatedChatView(
///     dataSource: myDataSource,
///     pageSize: 50,
///     windowSize: 150
/// )
/// ```
public struct PaginatedChatView<DataSource: ChatDataSource>: View {
    @ObservedObject private var dataSource: DataSource
    @Environment(\.chatTheme) private var theme
    
    @State private var inputText = ""
    @State private var selectedAttachments: [Any] = []
    @State private var selectedMessageForReaction: DataSource.Message?
    @State private var scrollTarget: String?
    @State private var scrollTask: Task<Void, Never>?
    
    // Pagination state
    @State private var visibleMessages: [DataSource.Message] = []
    @State private var currentPage = 0
    @State private var isLoadingMore = false
    
    private let attachmentActions: [AttachmentAction]
    private let pageSize: Int
    private let windowSize: Int
    
    /// Creates a paginated chat view with specified pagination parameters.
    ///
    /// - Parameters:
    ///   - dataSource: The data source managing chat data
    ///   - attachmentActions: Optional attachment actions
    ///   - pageSize: Number of messages to load per page (default: 50)
    ///   - windowSize: Maximum messages to keep in memory (default: 150)
    public init(
        dataSource: DataSource,
        attachmentActions: [AttachmentAction] = [],
        pageSize: Int = 50,
        windowSize: Int = 150
    ) {
        self.dataSource = dataSource
        self.attachmentActions = attachmentActions
        self.pageSize = pageSize
        self.windowSize = windowSize
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
        .onAppear {
            loadInitialMessages()
        }
        .onChange(of: dataSource.messages.count) { _, _ in
            updateVisibleMessages()
        }
    }
    
    // MARK: - Messages View
    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: theme.spacing.sm) {
                    // Load more indicator at top
                    if isLoadingMore {
                        ProgressView()
                            .padding()
                    }
                    
                    // Messages
                    ForEach(visibleMessages, id: \.id) { message in
                        MessageRow(
                            message: message,
                            dataSource: dataSource,
                            selectedMessageForReaction: $selectedMessageForReaction
                        )
                        .id(message.id)
                        .onAppear {
                            checkForPagination(message: message)
                        }
                    }
                    
                    // Thinking indicator
                    if dataSource.isThinking {
                        ThinkingIndicatorView(
                            thoughts: dataSource.currentThoughts,
                            isThinking: dataSource.isThinking
                        )
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
            .onChange(of: visibleMessages.count) { oldValue, newValue in
                guard newValue > oldValue else { return }
                if let lastMessage = visibleMessages.last {
                    // Debounced scrolling
                    scrollTask?.cancel()
                    scrollTask = Task {
                        try? await Task.sleep(nanoseconds: 100_000_000)
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
    
    // MARK: - Pagination Logic
    private func loadInitialMessages() {
        let allMessages = Array(dataSource.messages)
        let startIndex = max(0, allMessages.count - pageSize)
        visibleMessages = Array(allMessages[startIndex..<allMessages.count])
        currentPage = max(0, (allMessages.count / pageSize) - 1)
    }
    
    private func updateVisibleMessages() {
        let allMessages = Array(dataSource.messages)
        
        // If we have new messages, add them
        if let lastVisible = visibleMessages.last,
           let lastVisibleIndex = allMessages.firstIndex(where: { $0.id == lastVisible.id }),
           lastVisibleIndex < allMessages.count - 1 {
            // Add new messages
            let newMessages = Array(allMessages[(lastVisibleIndex + 1)..<allMessages.count])
            visibleMessages.append(contentsOf: newMessages)
            
            // Trim if exceeds window size
            if visibleMessages.count > windowSize {
                let trimCount = visibleMessages.count - windowSize
                visibleMessages.removeFirst(trimCount)
            }
        } else if visibleMessages.isEmpty {
            loadInitialMessages()
        }
    }
    
    private func checkForPagination(message: DataSource.Message) {
        guard !isLoadingMore else { return }
        
        // Check if this is one of the first messages
        if let index = visibleMessages.firstIndex(where: { $0.id == message.id }),
           index < 5 {
            loadMoreMessages()
        }
    }
    
    private func loadMoreMessages() {
        guard currentPage > 0, !isLoadingMore else { return }
        
        isLoadingMore = true
        
        Task {
            await MainActor.run {
                let allMessages = Array(dataSource.messages)
                let endIndex = currentPage * pageSize
                let startIndex = max(0, endIndex - pageSize)
                
                if startIndex < endIndex, startIndex >= 0 {
                    let newMessages = Array(allMessages[startIndex..<min(endIndex, allMessages.count)])
                    visibleMessages.insert(contentsOf: newMessages, at: 0)
                    currentPage -= 1
                    
                    // Trim if exceeds window size
                    if visibleMessages.count > windowSize {
                        let trimCount = visibleMessages.count - windowSize
                        visibleMessages.removeLast(trimCount)
                    }
                }
                
                isLoadingMore = false
            }
        }
    }
}

// MARK: - Convenience Extension
public extension PaginatedChatView {
    /// Creates a paginated chat view with default pagination settings
    init(dataSource: DataSource, attachmentActions: [AttachmentAction] = []) {
        self.init(
            dataSource: dataSource,
            attachmentActions: attachmentActions,
            pageSize: 50,
            windowSize: 150
        )
    }
}