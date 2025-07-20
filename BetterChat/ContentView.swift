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
            attachments: []
        ),
        ExampleMessage(
            id: "2",
            timestamp: Date().addingTimeInterval(-3000),
            sender: .currentUser,
            status: .read,
            reactionType: "❤️",
            text: "It's going great! The modular design is really flexible.",
            attachments: []
        ),
        ExampleMessage(
            id: "3",
            timestamp: Date().addingTimeInterval(-2000),
            sender: .otherUser,
            status: .read,
            reactionType: nil,
            text: "Can you share a screenshot?",
            attachments: []
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
            ]
        )
    ]
    
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
            attachments: attachments.compactMap { $0 as? ExampleAttachment }
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
}

// Main View
struct ContentView: View {
    @StateObject private var dataSource = ExampleChatDataSource()
    
    var body: some View {
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
                )
            ]
        )
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}