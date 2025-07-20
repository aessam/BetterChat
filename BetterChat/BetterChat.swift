import SwiftUI

public struct BetterChat {
    public static func chatView<DataSource: ChatDataSource>(
        dataSource: DataSource,
        configuration: ChatConfiguration = ChatConfiguration(),
        sendButtonIcon: Image = Image(systemName: "arrow.up.circle.fill"),
        attachmentActions: [AttachmentAction] = []
    ) -> ChatView<DataSource> {
        ChatView(
            dataSource: dataSource,
            configuration: configuration,
            sendButtonIcon: sendButtonIcon,
            attachmentActions: attachmentActions
        )
    }
}