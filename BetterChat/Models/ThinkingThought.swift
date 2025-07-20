import Foundation

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