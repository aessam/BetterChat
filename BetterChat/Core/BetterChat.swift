import SwiftUI

// MARK: - Modern BetterChat API
public struct BetterChat {
    // MARK: - Simplified API (Recommended)
    
    /// Minimal chat view - just text and reactions
    public static func chat<DataSource: ChatDataSource>(
        _ dataSource: DataSource
    ) -> some View {
        BetterChatView(
            dataSource: dataSource,
            reactions: ["👍", "👎"]
        )
    }
    
    /// Chat with custom slots for full control
    public static func chat<DataSource: ChatDataSource, A: View, I: View, S: View>(
        _ dataSource: DataSource,
        reactions: [String] = ["👍", "👎"],
        @ViewBuilder accessory: @escaping () -> A = { EmptyView() },
        @ViewBuilder inputAccessory: @escaping () -> I = { EmptyView() },
        @ViewBuilder suggestions: @escaping (String) -> S = { _ in EmptyView() }
    ) -> some View {
        BetterChatView(
            dataSource: dataSource,
            reactions: reactions,
            accessoryView: accessory,
            inputAccessoryView: inputAccessory,
            suggestionView: suggestions
        )
    }
    
    // MARK: - Legacy API (For backwards compatibility)
    // Legacy attachment-based API
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
    
    // Paginated chat view for large message lists
    public static func paginatedChatView<DataSource: ChatDataSource>(
        dataSource: DataSource,
        theme: ChatThemePreset = .light,
        attachmentActions: [AttachmentAction] = [],
        pageSize: Int = 50,
        windowSize: Int = 150
    ) -> some View {
        PaginatedChatView(
            dataSource: dataSource,
            attachmentActions: attachmentActions,
            pageSize: pageSize,
            windowSize: windowSize
        )
        .chatTheme(theme)
    }
}
