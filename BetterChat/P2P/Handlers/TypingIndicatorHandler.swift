import Foundation

/// Payload for typing indicators
public struct TypingIndicatorPayload: Codable, P2PSerializable {
    public let isTyping: Bool
    public let messagePreview: String? // Optional preview of what's being typed
    
    public init(isTyping: Bool, messagePreview: String? = nil) {
        self.isTyping = isTyping
        self.messagePreview = messagePreview
    }
}

/// Handler for typing indicator payloads
public class TypingIndicatorHandler: P2PPayloadHandler {
    public var supportedMimeTypes: [String] {
        [P2PMimeType.typingIndicator]
    }
    
    public init() {}
    
    public func handle(envelope: P2PEnvelope) throws -> P2PMessageUpdate {
        // Decode the typing indicator payload
        let payload = try TypingIndicatorPayload.deserialize(from: envelope.payload)
        
        // Return typing status update
        return .typingStatus(
            peer: envelope.sender,
            isTyping: payload.isTyping
        )
    }
    
    public func encode(message: any ChatMessage) throws -> P2PEnvelope? {
        // Typing indicators are not messages, they're status updates
        return nil
    }
    
    /// Convenience method to create a typing indicator envelope
    public static func createTypingEnvelope(
        isTyping: Bool,
        messagePreview: String? = nil,
        sender: PeerInfo
    ) throws -> P2PEnvelope {
        let payload = TypingIndicatorPayload(
            isTyping: isTyping,
            messagePreview: messagePreview
        )
        
        return P2PEnvelope(
            sender: sender,
            mimeType: P2PMimeType.typingIndicator,
            payload: try payload.serialize(),
            metadata: messagePreview != nil ? ["has-preview": "true"] : nil
        )
    }
}