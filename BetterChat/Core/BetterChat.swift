import SwiftUI

// MARK: - Modern BetterChat API
public struct BetterChat {
    // Modern, simple API - no configuration needed!
    public static func chatView<DataSource: ChatDataSource>(
        dataSource: DataSource,
        attachmentActions: [AttachmentAction] = []
    ) -> ModernChatView<DataSource> {
        ModernChatView(
            dataSource: dataSource,
            attachmentActions: attachmentActions
        )
    }
    
    // Convenience method with theme
    public static func chatView<DataSource: ChatDataSource>(
        dataSource: DataSource,
        theme: ChatThemePreset = .light,
        attachmentActions: [AttachmentAction] = []
    ) -> some View {
        ModernChatView(
            dataSource: dataSource,
            attachmentActions: attachmentActions
        )
        .chatTheme(theme)
    }
    
    // Advanced customization with full theme control
    public static func chatView<DataSource: ChatDataSource>(
        dataSource: DataSource,
        customTheme: ChatDesignTokens,
        attachmentActions: [AttachmentAction] = []
    ) -> some View {
        ModernChatView(
            dataSource: dataSource,
            attachmentActions: attachmentActions
        )
        .chatTheme(customTheme)
    }
}
