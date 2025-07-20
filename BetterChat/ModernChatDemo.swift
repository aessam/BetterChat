import SwiftUI
import Combine

// MARK: - Demo Message Implementation
struct DemoMessage: ChatMessage, TextMessage, ReactableMessage, MediaMessage {
    let id: String
    let timestamp: Date
    let sender: MessageSender
    let status: MessageStatus
    let text: String
    let reactions: [Reaction]
    let attachments: [ImageAttachment]
    
    init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        sender: MessageSender,
        status: MessageStatus = .sent,
        text: String,
        reactions: [Reaction] = [],
        attachments: [ImageAttachment] = []
    ) {
        self.id = id
        self.timestamp = timestamp
        self.sender = sender
        self.status = status
        self.text = text
        self.reactions = reactions
        self.attachments = attachments
    }
}

// MARK: - Demo Data Source
class DemoDataSource: ObservableObject, ChatDataSource {
    typealias Attachment = ImageAttachment
    @Published var messages: [DemoMessage] = [
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
    
    @Published var isTyping: Bool = false
    @Published var isThinking: Bool = false
    @Published var currentThoughts: [ThinkingThought] = []
    @Published var completedThinkingSessions: [ThinkingSession] = []
    
    func sendMessage(text: String, attachments: [ImageAttachment]) {
        onSendMessage(text: text, attachments: attachments)
    }
    
    func onSendMessage(text: String, attachments: [Any]) {
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
        } else {
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
    }
    
    func retryMessage(_ message: DemoMessage) {
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
    
    func reactToMessage(_ message: DemoMessage, reaction: String) {
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
    
    func removeReaction(from message: DemoMessage, reaction: String) {
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
    
    func messageContent(for message: DemoMessage) -> some View {
        Text(message.text)
    }
    
    func attachmentPreview(for attachment: Any) -> some View {
        EmptyView()
    }
}

// MARK: - Demo Views
struct ModernChatDemoView: View {
    @StateObject private var dataSource = DemoDataSource()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Theme selector
                themePicker
                
                // Chat view with beautiful new API
                ModernChatView(
                    dataSource: dataSource,
                    attachmentActions: [
                        AttachmentAction(
                            title: "Photo",
                            icon: Image(systemName: "photo"),
                            action: {
                                // Return a proper ImageAttachment
                                return ImageAttachment(
                                    displayName: "Photo attachment",
                                    image: Image(systemName: "photo"),
                                    thumbnail: Image(systemName: "photo")
                                )
                            }
                        ),
                        AttachmentAction(
                            title: "Camera",
                            icon: Image(systemName: "camera"),
                            action: {
                                // Return a proper ImageAttachment
                                return ImageAttachment(
                                    displayName: "Camera attachment",
                                    image: Image(systemName: "camera"),
                                    thumbnail: Image(systemName: "camera")
                                )
                            }
                        ),
                        AttachmentAction(
                            title: "Document",
                            icon: Image(systemName: "doc"),
                            action: {
                                // Return a proper ImageAttachment
                                return ImageAttachment(
                                    displayName: "Document attachment",
                                    image: Image(systemName: "doc"),
                                    thumbnail: Image(systemName: "doc")
                                )
                            }
                        )
                    ]
                )
                    .chatTheme(ChatThemePreset.blue)  // Beautiful, simple theming!
                    .safeAreaAware()
            }
            .navigationTitle("Modern Chat")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var themePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ThemeButton(title: "Light", theme: .light)
                ThemeButton(title: "Dark", theme: .dark)
                ThemeButton(title: "Blue", theme: .blue)
                ThemeButton(title: "Green", theme: .green)
                ThemeButton(title: "Minimal", theme: .minimal)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
}

struct ThemeButton: View {
    let title: String
    let theme: ChatThemePreset
    
    var body: some View {
        Button(title) {
            // In a real app, you'd update the theme here
        }
        .font(.caption)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .clipShape(Capsule())
    }
}

// MARK: - Standalone Component Demos
struct ChatComponentsDemo: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Message bubble examples
                Group {
                    Text("User message example")
                        .userBubble()
                    
                    Text("Assistant message with a longer text that demonstrates the responsive bubble width system")
                        .assistantBubble()
                    
                    Text("System message")
                        .systemBubble()
                }
                
                // Input examples
                Group {
                    Text("Standard input style")
                        .chatInput()
                    
                    Text("Minimal input style")
                        .chatInput(variant: .minimal)
                    
                    Text("Floating input style")
                        .chatInput(variant: .floating)
                }
                
                // Interactive examples
                Group {
                    Text("Send button")
                        .sendButton()
                    
                    Text("Attachment button")
                        .attachmentButton()
                    
                    Text("Reaction button")
                        .reactionButton()
                }
                
                // Chainable API examples
                Group {
                    Text("Chainable theming example")
                        .chatBubble(role: .user)
                        .chatTheme(ChatThemePreset.green)
                    
                    Text("Complex chaining")
                        .assistantBubble(shape: .minimal)
                        .reactions(enabled: true)
                        .responsiveBubbleWidth()
                        .dynamicSpacing(16)
                }
            }
            .padding()
        }
        .chatTheme(ChatThemePreset.blue)  // Apply theme to whole demo
    }
}

// MARK: - Preview Helpers
#Preview("Modern Chat Demo") {
    ModernChatDemoView()
}

#Preview("Components Demo") {
    ChatComponentsDemo()
}

#Preview("Minimal Theme") {
    ModernChatDemoView()
        .chatTheme(ChatThemePreset.minimal)
}

#Preview("Dark Theme") {
    ModernChatDemoView()
        .chatTheme(ChatThemePreset.dark)
}
