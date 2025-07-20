import SwiftUI

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
}

public protocol MessageProtocol: Identifiable {
    var id: String { get }
    var timestamp: Date { get }
    var sender: MessageSender { get }
    var status: MessageStatus { get }
    var reactionType: String? { get }
}

public protocol ChatDataSource {
    associatedtype Message: MessageProtocol
    associatedtype MessageContent: View
    associatedtype AttachmentPreview: View
    
    var messages: [Message] { get }
    var isTyping: Bool { get }
    var isThinking: Bool { get }
    var thinkingThoughts: [ThinkingThought] { get }
    var completedThinkingSessions: [ThinkingSession] { get }
    
    @ViewBuilder
    func messageContent(for message: Message) -> MessageContent
    
    @ViewBuilder
    func attachmentPreview(for attachment: Any) -> AttachmentPreview
    
    func onSendMessage(text: String, attachments: [Any])
    func onRetryMessage(_ message: Message)
    func onTapAttachment(in message: Message)
    func onReaction(_ reaction: String, to message: Message)
}

// Thinking Session to persist in chat history
public struct ThinkingSession: Identifiable {
    public let id: String
    public let timestamp: Date
    public let thoughts: [ThinkingThought]
    public let isActive: Bool
    public let sender: MessageSender
    
    public init(id: String = UUID().uuidString, timestamp: Date = Date(), thoughts: [ThinkingThought], isActive: Bool, sender: MessageSender = .otherUser) {
        self.id = id
        self.timestamp = timestamp
        self.thoughts = thoughts
        self.isActive = isActive
        self.sender = sender
    }
}