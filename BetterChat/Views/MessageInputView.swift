import SwiftUI

struct MessageInputView<AttachmentPreview: View>: View {
    @Binding var text: String
    @FocusState private var isTextFieldFocused: Bool
    let configuration: ChatConfiguration
    let attachments: [Any]
    let attachmentPreview: (Any) -> AttachmentPreview
    let onSend: () -> Void
    let onAttachment: (Any) -> Void
    let onRemoveAttachment: (Int) -> Void
    
    private var sendButtonIcon: Image
    private var attachmentActions: [AttachmentAction]
    
    init(
        text: Binding<String>,
        configuration: ChatConfiguration,
        attachments: [Any],
        sendButtonIcon: Image = Image(systemName: ChatConstants.SystemNames.sendButton),
        attachmentActions: [AttachmentAction] = [],
        @ViewBuilder attachmentPreview: @escaping (Any) -> AttachmentPreview,
        onSend: @escaping () -> Void,
        onAttachment: @escaping (Any) -> Void,
        onRemoveAttachment: @escaping (Int) -> Void
    ) {
        self._text = text
        self.configuration = configuration
        self.attachments = attachments
        self.sendButtonIcon = sendButtonIcon
        self.attachmentActions = attachmentActions
        self.attachmentPreview = attachmentPreview
        self.onSend = onSend
        self.onAttachment = onAttachment
        self.onRemoveAttachment = onRemoveAttachment
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Attachments
            attachmentsView
            
            // Input area
            inputAreaView
        }
        .background(backgroundView)
        .onReceive(NotificationCenter.default.publisher(for: .dismissKeyboard)) { _ in
            isTextFieldFocused = false
        }
    }
    
    @ViewBuilder
    private var attachmentsView: some View {
        if !attachments.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: ChatConstants.Spacing.attachmentSpacing) {
                    ForEach(0..<attachments.count, id: \.self) { index in
                        attachmentItemView(index: index)
                    }
                }
                .padding(.horizontal, ChatConstants.Spacing.bubblePadding)
                .padding(.vertical, ChatConstants.Spacing.medium)
            }
        }
    }
    
    private func attachmentItemView(index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            attachmentPreview(attachments[index])
                .attachmentPreview()
            
            Button(action: { onRemoveAttachment(index) }) {
                Image(systemName: ChatConstants.SystemNames.removeAttachment)
                    .font(.system(size: ChatConstants.Sizes.removeButtonSize))
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(ChatConstants.Opacity.secondary))
                            .frame(width: 22, height: 22)
                    )
            }
            .offset(x: ChatConstants.Spacing.medium, y: -ChatConstants.Spacing.medium)
        }
    }
    
    private var inputAreaView: some View {
        HStack(alignment: .bottom, spacing: ChatConstants.Spacing.small) {
            attachmentButton
            textInputContainer
        }
        .padding(.vertical, ChatConstants.Spacing.small - 1)
        .padding(.bottom, ChatConstants.Spacing.tiny + 1)
        .animation(.easeInOut(duration: ChatConstants.Animation.sendButtonTransition), value: text.isEmpty)
    }
    
    private var attachmentButton: some View {
        Menu {
            ForEach(attachmentActions.indices, id: \.self) { index in
                Button(action: {
                    Task {
                        if let item = await attachmentActions[index].action() {
                            await MainActor.run {
                                onAttachment(item)
                            }
                        }
                    }
                }) {
                    Label {
                        Text(attachmentActions[index].title)
                    } icon: {
                        attachmentActions[index].icon
                    }
                }
            }
        } label: {
            Image(systemName: ChatConstants.SystemNames.attachmentButton)
                .font(.system(size: ChatConstants.Sizes.removeButtonSize, weight: .medium))
                .foregroundColor(Color.gray)
                .frame(width: ChatConstants.Sizes.attachmentButtonSize, height: ChatConstants.Sizes.attachmentButtonSize)
        }
        .padding(.leading, ChatConstants.Spacing.small)
    }
    
    private var textInputContainer: some View {
        HStack(alignment: .bottom, spacing: 0) {
            textField
            sendButtonView
        }
        .background(textFieldBackground)
        .padding(.trailing, ChatConstants.Spacing.small)
    }
    
    private var textField: some View {
        TextField(ChatConstants.Placeholders.messageInput, text: $text, axis: .vertical)
            .messageInput(configuration: configuration)
            .focused($isTextFieldFocused)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.height > ChatConstants.Sizes.removeButtonSize {
                            isTextFieldFocused = false
                        }
                    }
            )
    }
    
    @ViewBuilder
    private var sendButtonView: some View {
        if !text.isEmpty {
            Button(action: onSend) {
                sendButtonIcon
                    .sendButton(isEnabled: !text.isEmpty)
            }
            .padding(.trailing, ChatConstants.Spacing.tiny)
            .padding(.bottom, 1)
            .transition(.scale.combined(with: .opacity))
        }
    }
    
    private var textFieldBackground: some View {
        RoundedRectangle(cornerRadius: configuration.inputStyle.cornerRadius)
            .fill(Color(.systemGray6))
            .overlay(
                RoundedRectangle(cornerRadius: configuration.inputStyle.cornerRadius)
                    .stroke(Color(.systemGray4), lineWidth: 0.5)
            )
    }
    
    private var backgroundView: some View {
        Color(.systemBackground)
            .overlay(
                VStack {
                    Divider()
                    Spacer()
                }
            )
    }
}