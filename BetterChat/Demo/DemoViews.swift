import SwiftUI

// MARK: - Demo Views
public struct ModernChatDemoView: View {
    @StateObject private var dataSource = DemoDataSource()
    
    public var body: some View {
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
public struct ChatComponentsDemo: View {
    public var body: some View {
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