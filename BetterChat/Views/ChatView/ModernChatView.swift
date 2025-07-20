import SwiftUI
import Combine

// MARK: - Modern Chat View
public struct ModernChatView<DataSource: ChatDataSource>: View {
    @ObservedObject private var dataSource: DataSource
    @Environment(\.chatTheme) private var theme
    
    @State private var inputText = ""
    @State private var selectedAttachments: [Any] = []
    @State private var selectedMessageForReaction: DataSource.Message?
    
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
                
                InputArea(
                    dataSource: dataSource,
                    inputText: $inputText,
                    selectedAttachments: $selectedAttachments,
                    attachmentActions: attachmentActions
                )
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
                        MessageRow(
                            message: message,
                            dataSource: dataSource,
                            selectedMessageForReaction: $selectedMessageForReaction
                        )
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