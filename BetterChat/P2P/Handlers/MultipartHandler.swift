import Foundation
import SwiftUI

/// Structure for multipart payloads containing multiple parts
public struct MultipartPayload: Codable, P2PSerializable {
    public struct Part: Codable {
        public let mimeType: String
        public let contentId: String?
        public let headers: [String: String]?
        public let data: Data
        
        public init(
            mimeType: String,
            data: Data,
            contentId: String? = nil,
            headers: [String: String]? = nil
        ) {
            self.mimeType = mimeType
            self.data = data
            self.contentId = contentId
            self.headers = headers
        }
    }
    
    public let boundary: String
    public let parts: [Part]
    
    public init(parts: [Part], boundary: String = UUID().uuidString) {
        self.parts = parts
        self.boundary = boundary
    }
}

/// Handler for multipart messages containing multiple payloads
public class MultipartHandler: P2PPayloadHandler {
    public var supportedMimeTypes: [String] {
        [
            P2PMimeType.multipart,
            P2PMimeType.multipartAlternative,
            P2PMimeType.multipartRelated
        ]
    }
    
    private let processor: P2PMessageProcessor
    
    public init(processor: P2PMessageProcessor) {
        self.processor = processor
    }
    
    public func handle(envelope: P2PEnvelope) throws -> P2PMessageUpdate {
        // Decode the multipart payload
        let multipart = try MultipartPayload.deserialize(from: envelope.payload)
        
        // Process each part and combine results
        var textContent = ""
        var imageAttachments: [ImageAttachment] = []
        var reactions: [(String, Reaction, P2PMessageUpdate.ReactionAction)] = []
        
        for part in multipart.parts {
            // Create a sub-envelope for each part
            let partEnvelope = P2PEnvelope(
                id: "\(envelope.id)_\(part.contentId ?? UUID().uuidString)",
                timestamp: envelope.timestamp,
                sender: envelope.sender,
                mimeType: part.mimeType,
                payload: part.data,
                metadata: part.headers
            )
            
            // Process the part based on its MIME type
            if P2PMimeType.isText(part.mimeType) {
                if let text = String(data: part.data, encoding: .utf8) {
                    if !textContent.isEmpty {
                        textContent += "\n"
                    }
                    textContent += text
                }
            } else if P2PMimeType.isImage(part.mimeType) {
                // Create image attachment
                let platformImage = PlatformImage.from(data: part.data) ?? createEmptyPlatformImage()
                let image = Image(platformImage: platformImage)
                
                let filename = part.headers?["filename"] ?? "image.\(P2PMimeType.subType(from: part.mimeType) ?? "jpg")"
                let attachment = ImageAttachment(
                    displayName: filename,
                    size: Int64(part.data.count),
                    image: image
                )
                imageAttachments.append(attachment)
            } else if part.mimeType == P2PMimeType.reaction {
                // Handle reactions
                if let reactionPayload = try? ReactionPayload.deserialize(from: part.data) {
                    let reaction = Reaction(
                        emoji: reactionPayload.emoji,
                        count: 1,
                        isSelected: false
                    )
                    let action: P2PMessageUpdate.ReactionAction = reactionPayload.action == .add ? .add : .remove
                    reactions.append((reactionPayload.messageId, reaction, action))
                }
            }
        }
        
        // Create appropriate message based on collected content
        if !reactions.isEmpty {
            // If we have reactions, return the first one (shouldn't mix reactions with other content)
            let (messageId, reaction, action) = reactions[0]
            return .reaction(messageId: messageId, reaction: reaction, action: action)
        } else if !imageAttachments.isEmpty {
            // Create image message with attachments and caption
            let sender: MessageSender = envelope.sender.peerID == getCurrentPeerID() ? .currentUser : .otherUser
            let message = P2PImageMessage(
                id: envelope.id,
                timestamp: envelope.timestamp,
                sender: sender,
                status: sender == .currentUser ? .sent : .delivered,
                attachments: imageAttachments,
                caption: textContent.isEmpty ? nil : textContent,
                peerInfo: envelope.sender,
                envelopeId: envelope.id
            )
            return .newMessage(message)
        } else if !textContent.isEmpty {
            // Create text message
            let sender: MessageSender = envelope.sender.peerID == getCurrentPeerID() ? .currentUser : .otherUser
            let message = P2PTextMessage(
                id: envelope.id,
                timestamp: envelope.timestamp,
                sender: sender,
                status: sender == .currentUser ? .sent : .delivered,
                text: textContent,
                peerInfo: envelope.sender,
                envelopeId: envelope.id
            )
            return .newMessage(message)
        } else {
            // Fallback to generic message
            let message = P2PGenericMessage(from: envelope)
            return .newMessage(message)
        }
    }
    
    public func encode(message: any ChatMessage) throws -> P2PEnvelope? {
        // Check if this is a complex message that needs multipart encoding
        var parts: [MultipartPayload.Part] = []
        
        // Add text part if available
        if let textMessage = message as? TextMessage {
            if let textData = textMessage.text.data(using: .utf8) {
                parts.append(MultipartPayload.Part(
                    mimeType: P2PMimeType.text,
                    data: textData
                ))
            }
        }
        
        // Add image parts if available
        if let mediaMessage = message as? (any MediaMessage) {
            for attachment in mediaMessage.attachments {
                if attachment is ImageAttachment {
                    // In production, you'd get the actual image data
                    let imageData = Data() // Placeholder
                    parts.append(MultipartPayload.Part(
                        mimeType: P2PMimeType.imageJPEG,
                        data: imageData,
                        headers: ["filename": attachment.displayName]
                    ))
                }
            }
        }
        
        // Only create multipart if we have multiple parts
        guard parts.count > 1 else {
            return nil // Let other handlers handle single-part messages
        }
        
        let multipart = MultipartPayload(parts: parts)
        
        return P2PEnvelope(
            id: message.id,
            timestamp: message.timestamp,
            sender: getCurrentPeerInfo(),
            mimeType: P2PMimeType.multipart,
            payload: try multipart.serialize(),
            metadata: ["parts-count": "\(parts.count)"]
        )
    }
    
    private func getCurrentPeerID() -> String {
        ProcessInfo.processInfo.hostName ?? "unknown"
    }
    
    private func getCurrentPeerInfo() -> PeerInfo {
        PeerInfo(
            peerID: getCurrentPeerID(),
            displayName: getDeviceName(),
            deviceInfo: getPlatformInfo()
        )
    }
}

/// Convenience method to create a multipart envelope
public extension MultipartHandler {
    static func createMultipartEnvelope(
        text: String? = nil,
        images: [Data] = [],
        sender: PeerInfo,
        metadata: [String: String]? = nil
    ) throws -> P2PEnvelope {
        var parts: [MultipartPayload.Part] = []
        
        // Add text part
        if let text = text, let textData = text.data(using: .utf8) {
            parts.append(MultipartPayload.Part(
                mimeType: P2PMimeType.text,
                data: textData
            ))
        }
        
        // Add image parts
        for (index, imageData) in images.enumerated() {
            parts.append(MultipartPayload.Part(
                mimeType: P2PMimeType.imageJPEG,
                data: imageData,
                contentId: "image_\(index)",
                headers: ["filename": "image_\(index).jpg"]
            ))
        }
        
        let multipart = MultipartPayload(parts: parts)
        
        return P2PEnvelope(
            sender: sender,
            mimeType: P2PMimeType.multipart,
            payload: try multipart.serialize(),
            metadata: metadata
        )
    }
}