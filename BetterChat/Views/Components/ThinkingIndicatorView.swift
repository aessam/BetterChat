import SwiftUI

public struct ThinkingIndicatorView: View {
    let thoughts: [ThinkingThought]
    let isThinking: Bool
    @Environment(\.chatTheme) private var theme
    
    @State private var isExpanded = true
    @State private var animationPhase = 0.0
    @State private var collapseTask: Task<Void, Never>?
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    public init(thoughts: [ThinkingThought], isThinking: Bool) {
        self.thoughts = thoughts
        self.isThinking = isThinking
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Avatar space to align with other user messages
            Circle()
                .fill(Color.clear)
                .frame(width: 32, height: 32)
                .padding(.trailing, 8)
            
            // Thinking content
            VStack(alignment: .leading, spacing: 0) {
                DisclosureGroup(
                    isExpanded: $isExpanded,
                    content: {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(thoughts) { thought in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(thoughtTitle(for: thought))
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text(Self.timeFormatter.string(from: thought.timestamp))
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Text(thought.content)
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding(.vertical, 4)
                                
                                if thought.id != thoughts.last?.id {
                                    Divider()
                                        .background(Color(.systemGray5))
                                }
                            }
                            
                            if isThinking {
                                HStack {
                                    Text("Thinking")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    
                                    thinkingAnimation
                                    
                                    Spacer()
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding(.top, 8)
                        .animation(.easeInOut(duration: 0.3), value: thoughts.count)
                    },
                    label: {
                        HStack {
                            Image(systemName: "brain")
                                .foregroundColor(theme.colors.accent)
                                .font(.caption)
                            
                            Text("Thinking Process")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            if isThinking {
                                thinkingAnimation
                            }
                            
                            Spacer()
                            
                            Text("\(thoughts.count) thought\(thoughts.count == 1 ? "" : "s")")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                )
                .accentColor(theme.colors.accent)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: theme.layout.cornerRadius)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.layout.cornerRadius)
                            .stroke(Color(.systemGray4), lineWidth: 0.5)
                    )
            )
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .onAppear {
            if isThinking {
                animationPhase = 1.0
            }
            // Auto-collapse when thinking is complete
            if !isThinking && thoughts.count > 0 {
                collapseTask?.cancel()
                collapseTask = Task {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    if !Task.isCancelled {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded = false
                        }
                    }
                }
            }
        }
        .onDisappear {
            collapseTask?.cancel()
        }
        .onChange(of: isThinking) { _, newValue in
            if newValue {
                animationPhase = 1.0
                collapseTask?.cancel()
            } else {
                animationPhase = 0.0
                // Auto-collapse when thinking stops
                collapseTask?.cancel()
                collapseTask = Task {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    if !Task.isCancelled {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded = false
                        }
                    }
                }
            }
        }
    }
    
    private var thinkingAnimation: some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(theme.colors.accent)
                    .frame(width: 3, height: 3)
                    .scaleEffect(scale(for: index))
                    .opacity(opacity(for: index))
                    .animation(
                        .easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.3),
                        value: animationPhase
                    )
            }
        }
    }
    
    private func scale(for index: Int) -> CGFloat {
        let phase = (animationPhase + Double(index) * 0.33).truncatingRemainder(dividingBy: 1.0)
        return 0.5 + 0.5 * (1.0 + sin(phase * 2 * .pi)) / 2.0
    }
    
    private func opacity(for index: Int) -> Double {
        let phase = (animationPhase + Double(index) * 0.33).truncatingRemainder(dividingBy: 1.0)
        return 0.3 + 0.7 * (1.0 + sin(phase * 2 * .pi)) / 2.0
    }
    
    private func thoughtTitle(for thought: ThinkingThought) -> String {
        if let index = thoughts.firstIndex(where: { $0.id == thought.id }) {
            return "Thought \(index + 1)"
        }
        return "Thought"
    }
    
}