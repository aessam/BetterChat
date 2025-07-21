import SwiftUI
import Combine

// MARK: - Demo Data Source
public class DemoDataSource: ObservableObject, ChatDataSource {
    public typealias Attachment = ImageAttachment
    
    @Published public var messages: [DemoMessage] = [
        DemoMessage(
            sender: .otherUser,
            text: "Hey! How's the new chat system working?"
        ),
        DemoMessage(
            sender: .currentUser,
            text: "It's amazing! The new API is so clean and SwiftUI-native. Look at how easy theming is now."
        ),
        DemoMessage(
            sender: .otherUser,
            text: "That's awesome! I love how everything just works with environment values.",
            reactions: [
                Reaction(emoji: "🎉", count: 2, isSelected: true),
                Reaction(emoji: "👍", count: 1, isSelected: false)
            ]
        )
    ]
    
    @Published public var isTyping: Bool = false
    @Published public var isThinking: Bool = false
    @Published public var currentThoughts: [ThinkingThought] = []
    @Published public var completedThinkingSessions: [ThinkingSession] = []
    
    public init() {}
    
    public func sendMessage(text: String, attachments: [ImageAttachment]) {
        onSendMessage(text: text, attachments: attachments)
    }
    
    public func onSendMessage(text: String, attachments: [Any]) {
        // Convert Any attachments to ImageAttachment for demo
        let demoAttachments = attachments.compactMap { attachment -> ImageAttachment? in
            if let stringAttachment = attachment as? String {
                // Create a mock ImageAttachment from the string
                return ImageAttachment(
                    displayName: stringAttachment,
                    image: Image(systemName: stringAttachment.contains("photo") ? "photo" : 
                                           stringAttachment.contains("camera") ? "camera" : "doc"),
                    thumbnail: Image(systemName: stringAttachment.contains("photo") ? "photo" : 
                                              stringAttachment.contains("camera") ? "camera" : "doc")
                )
            }
            return attachment as? ImageAttachment
        }
        
        let newMessage = DemoMessage(
            sender: .currentUser,
            status: .sending,
            text: text,
            attachments: demoAttachments
        )
        messages.append(newMessage)
        
        // Simulate message status updates
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let index = self.messages.firstIndex(where: { $0.id == newMessage.id }) {
                self.messages[index] = DemoMessage(
                    id: newMessage.id,
                    timestamp: newMessage.timestamp,
                    sender: newMessage.sender,
                    status: .sent,
                    text: newMessage.text,
                    attachments: newMessage.attachments
                )
            }
        }
        
        // Check if user wants thinking response
        if text.lowercased().contains("think") {
            simulateThinkingResponse()
        } else {
            simulateRegularResponse()
        }
    }
    
    private func simulateThinkingResponse() {
        // Start thinking after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isThinking = true
            self.currentThoughts = [
                ThinkingThought(content: "Let me process this request...")
            ]
        }
        
        // Add more thoughts progressively
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.currentThoughts.append(ThinkingThought(content: "Analyzing the best approach..."))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.currentThoughts.append(ThinkingThought(content: "Considering various options..."))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            self.currentThoughts.append(ThinkingThought(content: "Almost ready with the answer..."))
        }
        
        // Stop thinking and start typing
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
            self.isThinking = false
            self.isTyping = true
            
            // Create response message ID first
            let responseId = UUID().uuidString
            
            // Create completed thinking session associated with the upcoming response
            let thinkingSession = ThinkingSession(
                thoughts: self.currentThoughts,
                messageId: responseId
            )
            self.completedThinkingSessions.append(thinkingSession)
            self.currentThoughts = []
            
            // Send final response after typing
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.isTyping = false
                let response = DemoMessage(
                    id: responseId,
                    sender: .otherUser,
                    text: "After careful consideration, I believe the new chat system with thinking capabilities provides a much better user experience. The visual feedback helps users understand when the AI is processing complex requests."
                )
                self.messages.append(response)
            }
        }
    }
    
    private func simulateRegularResponse() {
        // Regular response for non-thinking messages
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isTyping = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.isTyping = false
            let response = DemoMessage(
                sender: .otherUser,
                text: "That's a great message! The new system is so much better."
            )
            self.messages.append(response)
        }
    }
    
    public func retryMessage(_ message: DemoMessage) {
        // Implementation for retry
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index] = DemoMessage(
                id: message.id,
                timestamp: message.timestamp,
                sender: message.sender,
                status: .sending,
                text: message.text,
                attachments: message.attachments
            )
        }
    }
    
    public func reactToMessage(_ message: DemoMessage, reaction: String) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            var updatedReactions = messages[index].reactions
            
            if let reactionIndex = updatedReactions.firstIndex(where: { $0.emoji == reaction }) {
                // Update existing reaction
                updatedReactions[reactionIndex] = Reaction(
                    id: updatedReactions[reactionIndex].id,
                    emoji: reaction,
                    count: updatedReactions[reactionIndex].count + 1,
                    isSelected: true
                )
            } else {
                // Add new reaction
                updatedReactions.append(Reaction(emoji: reaction, isSelected: true))
            }
            
            messages[index] = DemoMessage(
                id: message.id,
                timestamp: message.timestamp,
                sender: message.sender,
                status: message.status,
                text: message.text,
                reactions: updatedReactions,
                attachments: message.attachments
            )
        }
    }
    
    public func removeReaction(from message: DemoMessage, reaction: String) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            var updatedReactions = messages[index].reactions
            
            if let reactionIndex = updatedReactions.firstIndex(where: { $0.emoji == reaction }) {
                if updatedReactions[reactionIndex].count > 1 {
                    updatedReactions[reactionIndex] = Reaction(
                        id: updatedReactions[reactionIndex].id,
                        emoji: reaction,
                        count: updatedReactions[reactionIndex].count - 1,
                        isSelected: false
                    )
                } else {
                    updatedReactions.remove(at: reactionIndex)
                }
            }
            
            messages[index] = DemoMessage(
                id: message.id,
                timestamp: message.timestamp,
                sender: message.sender,
                status: message.status,
                text: message.text,
                reactions: updatedReactions,
                attachments: message.attachments
            )
        }
    }
    
    public func messageContent(for message: DemoMessage) -> some View {
        Text(message.text)
    }
    
    public func attachmentPreview(for attachment: Any) -> some View {
        EmptyView()
    }
}
