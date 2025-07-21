import SwiftUI

// MARK: - Demo Views
public struct ModernChatDemoView: View {
    @StateObject private var dataSource = DemoDataSource()
    @State private var selectedTheme: ChatThemePreset = .blue
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Theme selector
                themePicker.padding(2)
                
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
                    .chatTheme(selectedTheme)  // Apply selected theme!
                    .safeAreaAware()
            }
            .navigationTitle("Modern Chat")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var themePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ThemeButton(title: "Light", theme: .light, selectedTheme: $selectedTheme)
                ThemeButton(title: "Dark", theme: .dark, selectedTheme: $selectedTheme)
                ThemeButton(title: "Blue", theme: .blue, selectedTheme: $selectedTheme)
                ThemeButton(title: "Green", theme: .green, selectedTheme: $selectedTheme)
                ThemeButton(title: "Minimal", theme: .minimal, selectedTheme: $selectedTheme)
            }
            .padding(.horizontal)
            .padding(.vertical, 2)
        }
        .background(Color(.clear))
    }
}

struct ThemeButton: View {
    let title: String
    let theme: ChatThemePreset
    @Binding var selectedTheme: ChatThemePreset
    
    var body: some View {
        Button(title) {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTheme = theme
            }
        }
        .font(.caption)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(backgroundColor)
        .foregroundColor(textColor)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
        )
    }
    
    private var isSelected: Bool {
        selectedTheme == theme
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return themeColor.opacity(0.2)
        } else {
            return Color(.systemGray6)
        }
    }
    
    private var textColor: Color {
        if isSelected {
            return themeColor
        } else {
            return .secondary
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return themeColor
        } else {
            return Color(.systemGray4)
        }
    }
    
    private var themeColor: Color {
        switch theme {
        case .light: return .orange
        case .dark: return .purple
        case .blue: return .blue
        case .green: return .green
        case .minimal: return .gray
        }
    }
}

