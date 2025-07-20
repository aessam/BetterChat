import SwiftUI

public struct ChatConfiguration {
    public var bubbleStyle: BubbleStyle
    public var inputStyle: InputStyle
    public var generalStyle: GeneralStyle
    
    public init(
        bubbleStyle: BubbleStyle = .init(),
        inputStyle: InputStyle = .init(),
        generalStyle: GeneralStyle = .init()
    ) {
        self.bubbleStyle = bubbleStyle
        self.inputStyle = inputStyle
        self.generalStyle = generalStyle
    }
}

public struct BubbleStyle {
    public var currentUserColor: Color
    public var otherUserColor: Color
    public var textColor: Color
    public var font: Font
    public var cornerRadius: CGFloat
    public var padding: EdgeInsets
    
    public init(
        currentUserColor: Color = .blue,
        otherUserColor: Color = Color(.systemGray5),
        textColor: Color = .primary,
        font: Font = .body,
        cornerRadius: CGFloat = 18,
        padding: EdgeInsets = EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
    ) {
        self.currentUserColor = currentUserColor
        self.otherUserColor = otherUserColor
        self.textColor = textColor
        self.font = font
        self.cornerRadius = cornerRadius
        self.padding = padding
    }
}

public struct InputStyle {
    public var backgroundColor: Color
    public var textColor: Color
    public var font: Font
    public var minHeight: CGFloat
    public var maxHeight: CGFloat
    public var cornerRadius: CGFloat
    
    public init(
        backgroundColor: Color = Color(.tertiarySystemBackground),
        textColor: Color = .primary,
        font: Font = .body,
        minHeight: CGFloat = 20,
        maxHeight: CGFloat = 100,
        cornerRadius: CGFloat = 17
    ) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.font = font
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.cornerRadius = cornerRadius
    }
}

public struct GeneralStyle {
    public var backgroundColor: Color
    public var animationDuration: Double
    public var showTimestamps: Bool
    public var timestampFormat: DateFormatter
    
    public init(
        backgroundColor: Color = Color(.systemBackground),
        animationDuration: Double = 0.3,
        showTimestamps: Bool = true,
        timestampFormat: DateFormatter = {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter
        }()
    ) {
        self.backgroundColor = backgroundColor
        self.animationDuration = animationDuration
        self.showTimestamps = showTimestamps
        self.timestampFormat = timestampFormat
    }
}