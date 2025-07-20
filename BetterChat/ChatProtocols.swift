import SwiftUI

// MARK: - Core Message Types
public enum MessageStatus {
    case sending
    case sent
    case delivered
    case read
    case failed
}

public enum MessageSender {
    case currentUser
    case otherUser
    case system
}

// MARK: - Message Protocol
public protocol ChatMessage: Identifiable {
    var id: String { get }
    var timestamp: Date { get }
    var sender: MessageSender { get }
    var status: MessageStatus { get }
}

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

public protocol ThinkingMessage: ChatMessage {
    var thoughts: [ThinkingThought] { get }
    var isComplete: Bool { get }
}

// MARK: - Attachment System
public protocol ChatAttachment: Identifiable {
    var id: String { get }
    var displayName: String { get }
    var size: Int64? { get }
}

public struct ImageAttachment: ChatAttachment {
    public let id: String
    public let displayName: String
    public let size: Int64?
    public let image: Image
    public let thumbnail: Image?
    
    public init(id: String = UUID().uuidString, displayName: String, size: Int64? = nil, image: Image, thumbnail: Image? = nil) {
        self.id = id
        self.displayName = displayName
        self.size = size
        self.image = image
        self.thumbnail = thumbnail
    }
}

// DocumentAttachment moved to AttachmentSystem.swift

public struct LinkAttachment: ChatAttachment {
    public let id: String
    public let displayName: String
    public let size: Int64?
    public let url: URL
    public let title: String?
    public let description: String?
    public let thumbnail: Image?
    
    public init(id: String = UUID().uuidString, displayName: String, size: Int64? = nil, url: URL, title: String? = nil, description: String? = nil, thumbnail: Image? = nil) {
        self.id = id
        self.displayName = displayName
        self.size = size
        self.url = url
        self.title = title
        self.description = description
        self.thumbnail = thumbnail
    }
}

// MARK: - Reaction System
public struct Reaction: Identifiable {
    public let id: String
    public let emoji: String
    public let count: Int
    public let isSelected: Bool
    
    public init(id: String = UUID().uuidString, emoji: String, count: Int = 1, isSelected: Bool = false) {
        self.id = id
        self.emoji = emoji
        self.count = count
        self.isSelected = isSelected
    }
}

// MARK: - Thinking System
public struct ThinkingThought: Identifiable {
    public let id: String
    public let content: String
    public let timestamp: Date
    
    public init(id: String = UUID().uuidString, content: String, timestamp: Date = Date()) {
        self.id = id
        self.content = content
        self.timestamp = timestamp
    }
}

public struct ThinkingSession: Identifiable {
    public let id: String
    public let timestamp: Date
    public let thoughts: [ThinkingThought]
    public let messageId: String // ID of the message this thinking session is for
    
    public init(id: String = UUID().uuidString, timestamp: Date = Date(), thoughts: [ThinkingThought], messageId: String) {
        self.id = id
        self.timestamp = timestamp
        self.thoughts = thoughts
        self.messageId = messageId
    }
}

// MARK: - Focused Data Source Protocols

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

// MARK: - Attachment Actions
public struct AttachmentAction {
    public let title: String
    public let icon: Image
    public let action: () async -> Any?
    
    public init(title: String, icon: Image, action: @escaping () async -> Any?) {
        self.title = title
        self.icon = icon
        self.action = action
    }
}

// MARK: - Combined Data Source for Convenience
public protocol ChatDataSource: ChatDataProvider, ChatActionHandler, ObservableObject where Message == Self.Message, Attachment == Self.Attachment {
    // Combined protocol for simple use cases
}