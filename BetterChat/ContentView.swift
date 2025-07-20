import SwiftUI
import Combine

// Example Message Model
struct ExampleMessage: MessageProtocol {
    let id: String
    let timestamp: Date
    let sender: MessageSender
    var status: MessageStatus
    var reactionType: String?
    let text: String
    let attachments: [ExampleAttachment]
    let associatedThoughts: [ThinkingThought]? // Add this to link thoughts to messages
}

struct ExampleAttachment: AttachmentItem, Identifiable {
    let id: String
    let displayName: String
    let type: AttachmentType
    
    enum AttachmentType {
        case image(Image)
        case document(URL)
        case link(URL)
    }
}

// Example Data Source
class ExampleChatDataSource: ObservableObject, ChatDataSource {
    @Published var messages: [ExampleMessage] = [
        ExampleMessage(
            id: "1",
            timestamp: Date().addingTimeInterval(-3600),
            sender: .otherUser,
            status: .read,
            reactionType: "😊",
            text: "Hey! How's the new chat module coming along?",
            attachments: [],
            associatedThoughts: nil
        ),
        ExampleMessage(
            id: "2",
            timestamp: Date().addingTimeInterval(-3000),
            sender: .currentUser,
            status: .read,
            reactionType: "❤️",
            text: "It's going great! The modular design is really flexible.",
            attachments: [],
            associatedThoughts: nil
        ),
        ExampleMessage(
            id: "3",
            timestamp: Date().addingTimeInterval(-2000),
            sender: .otherUser,
            status: .read,
            reactionType: nil,
            text: "Can you share a screenshot?",
            attachments: [],
            associatedThoughts: nil
        ),
        ExampleMessage(
            id: "4",
            timestamp: Date().addingTimeInterval(-1000),
            sender: .currentUser,
            status: .delivered,
            reactionType: nil,
            text: "Sure! Here it is:",
            attachments: [
                ExampleAttachment(
                    id: "att1",
                    displayName: "screenshot.png",
                    type: .image(Image(systemName: "photo.fill"))
                )
            ],
            associatedThoughts: nil
        )
    ]
    
    @Published var isTyping: Bool = false
    @Published var isThinking: Bool = false  
    @Published var thinkingThoughts: [ThinkingThought] = []
    @Published var completedThinkingSessions: [ThinkingSession] = []
    
    
    func messageContent(for message: ExampleMessage) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(message.text)
            
            ForEach(message.attachments) { attachment in
                switch attachment.type {
                case .image(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onTapGesture {
                            print("Tapped image: \(attachment.displayName)")
                        }
                case .document(let url):
                    HStack {
                        Image(systemName: "doc.fill")
                        Text(attachment.displayName)
                            .lineLimit(1)
                    }
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .onTapGesture {
                        print("Tapped document: \(url)")
                    }
                case .link(let url):
                    Text(url.absoluteString)
                        .foregroundColor(.blue)
                        .underline()
                        .onTapGesture {
                            print("Tapped link: \(url)")
                        }
                }
            }
        }
    }
    
    func attachmentPreview(for attachment: Any) -> some View {
        Group {
            if let exampleAttachment = attachment as? ExampleAttachment {
                switch exampleAttachment.type {
                case .image(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .document:
                    ZStack {
                        Color.blue.opacity(0.1)
                        Image(systemName: "doc.fill")
                            .font(.title2)
                    }
                case .link:
                    ZStack {
                        Color.blue.opacity(0.1)
                        Image(systemName: "link")
                            .font(.title2)
                    }
                }
            } else {
                Color.gray.opacity(0.3)
            }
        }
    }
    
    
    func onSendMessage(text: String, attachments: [Any]) {
        let newMessage = ExampleMessage(
            id: UUID().uuidString,
            timestamp: Date(),
            sender: .currentUser,
            status: .sending,
            reactionType: nil,
            text: text,
            attachments: attachments.compactMap { $0 as? ExampleAttachment },
            associatedThoughts: nil
        )
        
        messages.append(newMessage)
        
        // Simulate message delivery
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let index = self.messages.firstIndex(where: { $0.id == newMessage.id }) {
                self.messages[index].status = .sent
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let index = self.messages.firstIndex(where: { $0.id == newMessage.id }) {
                self.messages[index].status = .delivered
            }
        }
        
        // Simulate automatic response
        simulateResponse(to: text)
    }
    
    func onRetryMessage(_ message: ExampleMessage) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index].status = .sending
            
            // Simulate retry
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.messages[index].status = .sent
            }
        }
    }
    
    func onTapAttachment(in message: ExampleMessage) {
        print("Tapped attachment in message: \(message.id)")
    }
    
    func onReaction(_ reaction: String, to message: ExampleMessage) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index].reactionType = reaction.isEmpty ? nil : reaction
        }
    }
    
    // Demo functions for typing and thinking indicators
    func simulateTyping() {
        isTyping = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.isTyping = false
            self.messages.append(ExampleMessage(
                id: UUID().uuidString,
                timestamp: Date(),
                sender: .otherUser,
                status: .read,
                reactionType: nil,
                text: "This message was preceded by a typing indicator!",
                attachments: [],
                associatedThoughts: nil
            ))
        }
    }
    
    func simulateThinking() {
        isThinking = true
        thinkingThoughts = []
        let sessionStartTime = Date()
        
        // Add thoughts progressively
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.thinkingThoughts.append(ThinkingThought(
                content: "Let me analyze the user's question about implementing chat features..."
            ))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.thinkingThoughts.append(ThinkingThought(
                content: "I should consider the existing architecture and how to best integrate these new components."
            ))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.thinkingThoughts.append(ThinkingThought(
                content: "The typing indicator should be simple with animated dots, and the thinking indicator should be collapsible to show the reasoning process."
            ))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
            // Save the thinking session to history
            let completedSession = ThinkingSession(
                timestamp: sessionStartTime,
                thoughts: self.thinkingThoughts,
                isActive: false,
                sender: .otherUser
            )
            self.completedThinkingSessions.append(completedSession)
            
            // Clear active thinking
            self.isThinking = false
            self.thinkingThoughts = []
            
            // Send the message (from other user to simulate AI response)
            self.messages.append(ExampleMessage(
                id: UUID().uuidString,
                timestamp: Date(),
                sender: .otherUser,
                status: .read,
                reactionType: nil,
                text: "After thinking through the implementation, I believe we should use DisclosureGroup for the collapsible thinking indicator and a simple dot animation for typing.",
                attachments: [],
                associatedThoughts: nil
            ))
        }
    }
    
    func simulateResponse(to userMessage: String) {
        // ALWAYS show thinking for user messages
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.simulateThinkingResponse(to: userMessage)
        }
    }
    
    func simulateThinkingResponse(to userMessage: String) {
        isThinking = true
        thinkingThoughts = []
        let sessionStartTime = Date()
        
        // Add thoughts progressively
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.thinkingThoughts.append(ThinkingThought(
                content: "Analyzing the user's message: '\(String(userMessage.prefix(30)))...'"
            ))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.thinkingThoughts.append(ThinkingThought(
                content: "Considering context and formulating an appropriate response..."
            ))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            // Save the thinking session to history
            let completedSession = ThinkingSession(
                timestamp: sessionStartTime,
                thoughts: self.thinkingThoughts,
                isActive: false,
                sender: .otherUser
            )
            self.completedThinkingSessions.append(completedSession)
            
            // Clear active thinking and start typing
            self.isThinking = false
            self.thinkingThoughts = []
            self.isTyping = true
            
            // After typing, add the response message
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.isTyping = false
                let response = self.generateThoughtfulResponse(to: userMessage)
                self.messages.append(ExampleMessage(
                    id: UUID().uuidString,
                    timestamp: Date(),
                    sender: .otherUser,
                    status: .read,
                    reactionType: nil,
                    text: response,
                    attachments: [],
                    associatedThoughts: nil
                ))
            }
        }
    }
    
    func generateResponse(to message: String) -> String {
        let responses = [
            "That's interesting! Tell me more about that.",
            "I see what you mean. Have you considered another perspective?",
            "Thanks for sharing that with me!",
            "That makes sense. What do you think about it?",
            "I appreciate your thoughts on this.",
            "Absolutely! I couldn't agree more.",
            "That's a great point you're making."
        ]
        return responses.randomElement() ?? "Thanks for your message!"
    }
    
    func generateQuickResponse(to message: String) -> String {
        let responses = [
            "Got it! 👍",
            "Sounds good!",
            "Sure thing!",
            "Makes sense.",
            "I understand.",
            "Noted!",
            "Perfect!"
        ]
        return responses.randomElement() ?? "Okay!"
    }
    
    func generateThoughtfulResponse(to message: String) -> String {
        let responses = [
            "After considering what you've said, I think this is a really valuable perspective. It shows great insight into the topic.",
            "I've been thinking about your message, and it raises some interesting points that deserve further discussion.",
            "Your message touches on something important. I believe we should explore this idea more deeply.",
            "This is a thoughtful observation. It reminds me of similar discussions about innovation and progress.",
            "I appreciate you bringing this up. It's a complex topic that requires careful consideration."
        ]
        return responses.randomElement() ?? "That's a thought-provoking message. Let me share my perspective on this."
    }
}

// Main View
struct ContentView: View {
    @StateObject private var dataSource = ExampleChatDataSource()
    
    var body: some View {
        NavigationView {
            BetterChat.chatView(
                dataSource: dataSource,
                configuration: ChatConfiguration(
                    bubbleStyle: BubbleStyle(
                        currentUserColor: .blue,
                        otherUserColor: Color(.systemGray5),
                        textColor: .primary,
                        font: .body,
                        cornerRadius: 18
                    ),
                    inputStyle: InputStyle(),
                    generalStyle: GeneralStyle(
                        showTimestamps: false
                    )
                ),
                sendButtonIcon: Image(systemName: "arrow.up.circle.fill"),
                attachmentActions: [
                    AttachmentAction(
                        title: "Photo Library",
                        icon: Image(systemName: "photo"),
                        action: {
                            // Simulate photo picker
                            return ExampleAttachment(
                                id: UUID().uuidString,
                                displayName: "photo.jpg",
                                type: .image(Image(systemName: "photo.fill"))
                            )
                        }
                    ),
                    AttachmentAction(
                        title: "Document",
                        icon: Image(systemName: "doc"),
                        action: {
                            // Simulate document picker
                            return ExampleAttachment(
                                id: UUID().uuidString,
                                displayName: "document.pdf",
                                type: .document(URL(string: "file://document.pdf")!)
                            )
                        }
                    ),
                    AttachmentAction(
                        title: "Location",
                        icon: Image(systemName: "location"),
                        action: {
                            // Simulate location sharing
                            return nil
                        }
                    ),
                    AttachmentAction(
                        title: "Simulate Typing",
                        icon: Image(systemName: "ellipsis.message"),
                        action: {
                            dataSource.simulateTyping()
                            return nil
                        }
                    ),
                    AttachmentAction(
                        title: "Simulate Thinking",
                        icon: Image(systemName: "brain"),
                        action: {
                            dataSource.simulateThinking()
                            return nil
                        }
                    )
                ]
            )
            .navigationTitle("BetterChat Demo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}