import Foundation

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