import SwiftUI

struct TypingIndicatorView: View {
    @State private var animationPhase = 0.0
    
    let configuration: ChatConfiguration
    
    init(configuration: ChatConfiguration) {
        self.configuration = configuration
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            // Avatar space to align with other user messages
            Circle()
                .fill(Color.clear)
                .frame(width: 32, height: 32)
                .padding(.trailing, 8)
            
            // Typing bubble
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color(.systemGray3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(scale(for: index))
                        .opacity(opacity(for: index))
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                            value: animationPhase
                        )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: configuration.bubbleStyle.cornerRadius)
                    .fill(configuration.bubbleStyle.otherUserColor)
            )
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .onAppear {
            animationPhase = 1.0
        }
        .onDisappear {
            animationPhase = 0.0
        }
    }
    
    private func scale(for index: Int) -> CGFloat {
        let phase = (animationPhase + Double(index) * 0.33).truncatingRemainder(dividingBy: 1.0)
        return 1.0 + 0.5 * sin(phase * 2 * .pi)
    }
    
    private func opacity(for index: Int) -> Double {
        let phase = (animationPhase + Double(index) * 0.33).truncatingRemainder(dividingBy: 1.0)
        return 0.4 + 0.6 * (1.0 + sin(phase * 2 * .pi)) / 2.0
    }
}