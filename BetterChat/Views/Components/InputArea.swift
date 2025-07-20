import SwiftUI

public struct InputArea<DataSource: ChatDataSource>: View {
    @ObservedObject private var dataSource: DataSource
    @Environment(\.chatTheme) private var theme
    
    @Binding private var inputText: String
    @Binding private var selectedAttachments: [Any]
    @FocusState private var isTextFieldFocused: Bool
    
    private let attachmentActions: [AttachmentAction]
    
    public init(
        dataSource: DataSource,
        inputText: Binding<String>,
        selectedAttachments: Binding<[Any]>,
        attachmentActions: [AttachmentAction]
    ) {
        self.dataSource = dataSource
        self._inputText = inputText
        self._selectedAttachments = selectedAttachments
        self.attachmentActions = attachmentActions
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Attachment preview
            if !selectedAttachments.isEmpty {
                attachmentPreviewRow
            }
            
            // Input area - EXACTLY like original
            HStack(alignment: .bottom, spacing: 6) {
                attachmentButton
                textInputContainer
            }
            .padding(.vertical, 5)
            .padding(.bottom, 3)
            .animation(.easeInOut(duration: 0.2), value: inputText.isEmpty)
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(
            Color(.systemBackground)
                .overlay(
                    VStack {
                        Divider()
                        Spacer(minLength: 0)
                    }
                )
        )
    }
    
    // MARK: - Attachment Preview Row
    private var attachmentPreviewRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.sm) {
                ForEach(selectedAttachments.indices, id: \.self) { index in
                    attachmentPreviewView(for: selectedAttachments[index])
                        .overlay(alignment: .topTrailing) {
                            Button {
                                selectedAttachments.remove(at: index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .background(Color.white, in: Circle())
                            }
                            .offset(x: 8, y: -8)
                        }
                }
            }
            .padding(.horizontal, theme.spacing.md)
        }
        .padding(.top, theme.spacing.sm)
    }
    
    // MARK: - Attachment Button
    private var attachmentButton: some View {
        Menu {
            ForEach(attachmentActions.indices, id: \.self) { index in
                Button(action: {
                    Task {
                        if let item = await attachmentActions[index].action() {
                            await MainActor.run {
                                selectedAttachments.append(item)
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
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color.gray)
                .frame(width: 34, height: 34)
        }
        .padding(.leading, 6)
    }
    
    // MARK: - Text Input Container
    private var textInputContainer: some View {
        HStack(alignment: .bottom, spacing: 0) {
            textField
            sendButtonView
        }
        .background(textFieldBackground)
        .padding(.trailing, 6)
    }
    
    private var textField: some View {
        TextField("iMessage", text: $inputText, axis: .vertical)
            .textFieldStyle(.plain)
            .font(.system(size: 17))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .lineLimit(1...3)
            .frame(minHeight: 34)
            .focused($isTextFieldFocused)
    }
    
    @ViewBuilder
    private var sendButtonView: some View {
        if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Button(action: sendMessage) {
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
            .fill(Color(.systemGray6))
            .overlay(
                RoundedRectangle(cornerRadius: 17)
                    .stroke(Color(.systemGray4), lineWidth: 0.5)
            )
    }
    
    // MARK: - Helper Methods
    private var canSendMessage: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !selectedAttachments.isEmpty
    }
    
    private func sendMessage() {
        guard canSendMessage else { return }
        
        // Try to convert Any attachments to the expected DataSource.Attachment type
        let convertedAttachments = selectedAttachments.compactMap { $0 as? DataSource.Attachment }
        dataSource.sendMessage(text: inputText, attachments: convertedAttachments)
        inputText = ""
        selectedAttachments.removeAll()
    }
    
    // MARK: - Attachment Preview View
    @ViewBuilder  
    private func attachmentPreviewView(for attachment: Any) -> some View {
        if let imageAttachment = attachment as? ImageAttachment {
            // Show actual image attachment
            (imageAttachment.thumbnail ?? imageAttachment.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60)
                .clipped()
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                )
        } else if let stringAttachment = attachment as? String {
            // Show preview for string-based attachments
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.1))
                .frame(width: 60, height: 60)
                .overlay {
                    VStack(spacing: 4) {
                        Image(systemName: stringAttachment.contains("photo") ? "photo" : 
                                         stringAttachment.contains("camera") ? "camera" : "doc")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text(stringAttachment.contains("photo") ? "Photo" : 
                             stringAttachment.contains("camera") ? "Camera" : "Doc")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 0.5)
                )
        } else {
            // Fallback for any other attachment type
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: "doc")
                        .foregroundColor(.gray)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                )
        }
    }
}