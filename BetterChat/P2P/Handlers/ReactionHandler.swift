import Foundation

/// Payload structure for reactions
public struct ReactionPayload: Codable, P2PSerializable {
    public let messageId: String
    public let emoji: String
    public let action: Action
    
    public enum Action: String, Codable {
        case add
        case remove
    }
    
    public init(messageId: String, emoji: String, action: Action) {
        self.messageId = messageId
        self.emoji = emoji
        self.action = action
    }
}

/// Handler for reaction payloads
public class ReactionHandler: P2PPayloadHandler {
    public var supportedMimeTypes: [String] {
        [P2PMimeType.reaction]
    }
    
    public init() {}
    
    public func handle(envelope: P2PEnvelope) throws -> P2PMessageUpdate {
        // Decode the reaction payload
        let reaction = try ReactionPayload.deserialize(from: envelope.payload)
        
        // Create a Reaction object
        let reactionObj = Reaction(
            emoji: reaction.emoji,
            count: 1,
            isSelected: false // Will be determined by the UI
        )
        
        // Return the appropriate update
        let action: P2PMessageUpdate.ReactionAction = reaction.action == .add ? .add : .remove
        return .reaction(
            messageId: reaction.messageId,
            reaction: reactionObj,
            action: action
        )
    }
    
    public func encode(message: any ChatMessage) throws -> P2PEnvelope? {
        // Reactions are not messages themselves, they're updates to messages
        // This handler doesn't encode ChatMessage types
        return nil
    }
    
    /// Convenience method to create a reaction envelope
    public static func createReactionEnvelope(
        messageId: String,
        emoji: String,
        action: ReactionPayload.Action,
        sender: PeerInfo
    ) throws -> P2PEnvelope {
        let payload = ReactionPayload(
            messageId: messageId,
            emoji: emoji,
            action: action
        )
        
        return P2PEnvelope(
            sender: sender,
            mimeType: P2PMimeType.reaction,
            payload: try payload.serialize()
        )
    }
}