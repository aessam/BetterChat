import Foundation

// MARK: - Reaction System
public struct Reaction: Identifiable {
    public let id: String
    public let emoji: String
    public var count: Int
    public var isSelected: Bool
    
    public init(id: String = UUID().uuidString, emoji: String, count: Int = 1, isSelected: Bool = false) {
        self.id = id
        self.emoji = emoji
        self.count = count
        self.isSelected = isSelected
    }
}