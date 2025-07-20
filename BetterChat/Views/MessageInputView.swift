import SwiftUI

struct MessageInputView<AttachmentPreview: View>: View {
    @Binding var text: String
    @FocusState private var isTextFieldFocused: Bool
    let configuration: ChatConfiguration
    let attachments: [Any]
    let attachmentPreview: (Any) -> AttachmentPreview
    let onSend: () -> Void
    let onAttachment: () -> Void
    let onRemoveAttachment: (Int) -> Void
    
    private var sendButtonIcon: Image
    private var attachmentActions: [AttachmentAction]
    
    init(
        text: Binding<String>,
        configuration: ChatConfiguration,
        attachments: [Any],
        sendButtonIcon: Image = Image(systemName: "arrow.up.circle.fill"),
        attachmentActions: [AttachmentAction] = [],
        @ViewBuilder attachmentPreview: @escaping (Any) -> AttachmentPreview,
        onSend: @escaping () -> Void,
        onAttachment: @escaping () -> Void,
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
                HStack(spacing: 8) {
                    ForEach(0..<attachments.count, id: \.self) { index in
                        attachmentItemView(index: index)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
        }
    }
    
    private func attachmentItemView(index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            attachmentPreview(attachments[index])
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                )
            
            Button(action: { onRemoveAttachment(index) }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.7))
                            .frame(width: 22, height: 22)
                    )
            }
            .offset(x: 8, y: -8)
        }
    }
    
    private var inputAreaView: some View {
        HStack(alignment: .bottom, spacing: 6) {
            attachmentButton
            textInputContainer
        }
        .padding(.vertical, 5)
        .padding(.bottom, 3)
        .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
    }
    
    private var attachmentButton: some View {
        Button(action: onAttachment) {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color.gray)
                .frame(width: 34, height: 34)
        }
        .padding(.leading, 6)
    }
    
    private var textInputContainer: some View {
        HStack(alignment: .bottom, spacing: 0) {
            textField
            sendButtonView
        }
        .background(textFieldBackground)
        .padding(.trailing, 6)
    }
    
    private var textField: some View {
        TextField("iMessage", text: $text, axis: .vertical)
            .textFieldStyle(.plain)
            .font(.system(size: 17))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .lineLimit(1...6)
            .frame(minHeight: 34)
            .focused($isTextFieldFocused)
    }
    
    @ViewBuilder
    private var sendButtonView: some View {
        if !text.isEmpty {
            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
            }
            .padding(.trailing, 2)
            .padding(.bottom, 1)
            .transition(.scale.combined(with: .opacity))
        }
    }
    
    private var textFieldBackground: some View {
        RoundedRectangle(cornerRadius: 17)
            .fill(Color.gray.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 17)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
            )
    }
    
    private var backgroundView: some View {
        Color.white
            .overlay(
                VStack {
                    Divider()
                    Spacer()
                }
            )
    }
}