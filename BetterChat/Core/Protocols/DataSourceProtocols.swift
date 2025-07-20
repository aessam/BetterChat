import SwiftUI

// MARK: - Data Source Protocols

// Protocol for providing chat data
public protocol ChatDataProvider {
    associatedtype Message: ChatMessage
    
    var messages: [Message] { get }
    var isTyping: Bool { get }
    var isThinking: Bool { get }
    var currentThoughts: [ThinkingThought] { get }
    var completedThinkingSessions: [ThinkingSession] { get }
}

// Protocol for handling user actions
public protocol ChatActionHandler {
    associatedtype Message: ChatMessage
    associatedtype Attachment: ChatAttachment
    
    func sendMessage(text: String, attachments: [Attachment])
    func retryMessage(_ message: Message)
    func reactToMessage(_ message: Message, reaction: String)
    func removeReaction(from message: Message, reaction: String)
}

// Protocol for managing chat state
public protocol ChatStateProvider: ObservableObject {
    var scrollPosition: ChatScrollPosition { get }
    var isScrolledToBottom: Bool { get }
    
    func scrollToBottom()
    func scrollToMessage(id: String)
}

// MARK: - Combined Data Source for Convenience
public protocol ChatDataSource: ChatDataProvider, ChatActionHandler, ObservableObject where Message == Self.Message, Attachment == Self.Attachment {
    // Combined protocol for simple use cases
}

// MARK: - Scroll Position
public struct ChatScrollPosition {
    public let messageId: String?
    public let offset: CGFloat
    
    public init(messageId: String? = nil, offset: CGFloat = 0) {
        self.messageId = messageId
        self.offset = offset
    }
    
    public static let bottom = ChatScrollPosition()
}