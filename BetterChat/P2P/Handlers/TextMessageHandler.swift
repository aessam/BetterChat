import Foundation

/// Handler for text-based message payloads
public class TextMessageHandler: P2PPayloadHandler {
    public var supportedMimeTypes: [String] {
        [P2PMimeType.text, P2PMimeType.markdown, P2PMimeType.html]
    }
    
    public init() {}
    
    public func handle(envelope: P2PEnvelope) throws -> P2PMessageUpdate {
        // Decode the text from the payload
        guard let text = String(data: envelope.payload, encoding: .utf8) else {
            throw P2PError.invalidPayload
        }
        
        // Determine the sender type based on peer info
        let sender: MessageSender = envelope.sender.peerID == getCurrentPeerID() ? .currentUser : .otherUser
        
        // Create the text message
        let message = P2PTextMessage(
            id: envelope.id,
            timestamp: envelope.timestamp,
            sender: sender,
            status: sender == .currentUser ? .sent : .delivered,
            text: text,
            peerInfo: envelope.sender,
            envelopeId: envelope.id
        )
        
        return .newMessage(message)
    }
    
    public func encode(message: any ChatMessage) throws -> P2PEnvelope? {
        // Check if this is a text message we can encode
        guard let textMessage = message as? TextMessage else {
            return nil
        }
        
        // Convert text to data
        guard let textData = textMessage.text.data(using: .utf8) else {
            throw P2PError.serializationFailed(EncodingError.invalidText)
        }
        
        // Create envelope
        return P2PEnvelope(
            id: message.id,
            timestamp: message.timestamp,
            sender: getCurrentPeerInfo(),
            mimeType: P2PMimeType.text,
            payload: textData,
            metadata: ["encoding": "utf-8"]
        )
    }
    
    private func getCurrentPeerID() -> String {
        // This will be provided by the P2PSession
        // For now, return a placeholder
        return ProcessInfo.processInfo.hostName ?? "unknown"
    }
    
    private func getCurrentPeerInfo() -> PeerInfo {
        // This will be provided by the P2PSession
        // For now, return a placeholder
        return PeerInfo(
            peerID: getCurrentPeerID(),
            displayName: getDeviceName(),
            deviceInfo: getPlatformInfo()
        )
    }
}

enum EncodingError: Error {
    case invalidText
}