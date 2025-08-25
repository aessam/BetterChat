import Foundation

/// Central processor for handling P2P messages with different MIME types
public class P2PMessageProcessor {
    /// Registry of handlers by MIME type
    private var handlers: [String: P2PPayloadHandler] = [:]
    
    /// Fallback handler for unknown MIME types
    private var fallbackHandler: P2PPayloadHandler?
    
    /// Thread-safe queue for handler access
    private let queue = DispatchQueue(label: "com.betterchat.p2p.processor", attributes: .concurrent)
    
    public init() {
        // Register built-in handlers will be done by the data source
    }
    
    /// Register a handler for specific MIME types
    public func register(handler: P2PPayloadHandler) {
        queue.async(flags: .barrier) {
            for mimeType in handler.supportedMimeTypes {
                self.handlers[mimeType.lowercased()] = handler
            }
        }
    }
    
    /// Register multiple handlers at once
    public func registerHandlers(_ handlers: [P2PPayloadHandler]) {
        handlers.forEach { register(handler: $0) }
    }
    
    /// Set a fallback handler for unknown MIME types
    public func setFallbackHandler(_ handler: P2PPayloadHandler) {
        queue.async(flags: .barrier) {
            self.fallbackHandler = handler
        }
    }
    
    /// Process an incoming P2P envelope
    public func process(envelope: P2PEnvelope) throws -> P2PMessageUpdate {
        // Get the appropriate handler
        let handler = queue.sync {
            handlers[envelope.mimeType.lowercased()] ?? fallbackHandler
        }
        
        guard let handler = handler else {
            throw P2PError.unsupportedMimeType(envelope.mimeType)
        }
        
        return try handler.handle(envelope: envelope)
    }
    
    /// Encode a message into an envelope
    public func encode(message: any ChatMessage) throws -> P2PEnvelope {
        // Try each handler to see if it can encode this message
        let handlersSnapshot = queue.sync { Array(handlers.values) }
        
        for handler in handlersSnapshot {
            if let envelope = try handler.encode(message: message) {
                return envelope
            }
        }
        
        // If no handler can encode it, try the fallback
        if let fallback = queue.sync(execute: { fallbackHandler }),
           let envelope = try fallback.encode(message: message) {
            return envelope
        }
        
        throw P2PError.noEncoderForMessage
    }
    
    /// Check if a MIME type is supported
    public func isSupported(mimeType: String) -> Bool {
        queue.sync {
            handlers[mimeType.lowercased()] != nil || fallbackHandler != nil
        }
    }
    
    /// Get all supported MIME types
    public func supportedMimeTypes() -> [String] {
        queue.sync {
            Array(handlers.keys).sorted()
        }
    }
    
    /// Remove a handler for a specific MIME type
    public func removeHandler(for mimeType: String) {
        queue.async(flags: .barrier) {
            self.handlers.removeValue(forKey: mimeType.lowercased())
        }
    }
    
    /// Clear all handlers
    public func clearHandlers() {
        queue.async(flags: .barrier) {
            self.handlers.removeAll()
            self.fallbackHandler = nil
        }
    }
}

/// Errors that can occur during P2P message processing
public enum P2PError: LocalizedError {
    case unsupportedMimeType(String)
    case noEncoderForMessage
    case invalidPayload
    case serializationFailed(Error)
    case deserializationFailed(Error)
    case handlerError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .unsupportedMimeType(let type):
            return "Unsupported MIME type: \(type)"
        case .noEncoderForMessage:
            return "No encoder found for message"
        case .invalidPayload:
            return "Invalid payload data"
        case .serializationFailed(let error):
            return "Serialization failed: \(error.localizedDescription)"
        case .deserializationFailed(let error):
            return "Deserialization failed: \(error.localizedDescription)"
        case .handlerError(let error):
            return "Handler error: \(error.localizedDescription)"
        }
    }
}