# Thinking Messages

Implement AI thinking processes to show transparent reasoning in your chat interface.

## Overview

Thinking messages provide a unique way to display AI reasoning processes, making conversations more transparent and engaging. Users can see the step-by-step thought process behind AI responses, creating trust and understanding.

## How It Works

When a user sends "think" as a message, BetterChat:

1. **Initiates Thinking**: Displays a collapsible thinking indicator
2. **Progressive Updates**: Shows thoughts as they develop
3. **Visual Feedback**: Animated dots indicate active thinking
4. **Completion**: Collapses automatically when thinking is done
5. **Persistence**: Thinking sessions remain accessible above their related messages

## Basic Implementation

### Data Source Setup

```swift
class ThinkingDataSource: ObservableObject, ChatDataSource {
    @Published var messages: [DemoMessage] = []
    @Published var isTyping = false
    @Published var completedThinkingSessions: [ThinkingSession] = []
    
    func sendMessage(_ content: String, attachments: [any ChatAttachment]) {
        if content.lowercased() == "think" {
            handleThinkingMessage()
        } else {
            // Handle regular message
            let message = DemoMessage(
                id: UUID().uuidString,
                content: content,
                sender: .user,
                timestamp: Date()
            )
            messages.append(message)
        }
    }
    
    private func handleThinkingMessage() {
        let sessionId = UUID().uuidString
        let thinkingSession = ThinkingSession(
            thoughts: [],
            messageId: sessionId
        )
        
        // Start the thinking process
        simulateThinking(session: thinkingSession)
    }
}
```

### Thinking Simulation

```swift
extension ThinkingDataSource {
    private func simulateThinking(session: ThinkingSession) {
        let thoughts = [
            "Let me analyze this question carefully...",
            "Considering different approaches to solve this...",
            "Evaluating the pros and cons of each option...",
            "Synthesizing the information to form a comprehensive response..."
        ]
        
        var currentSession = session
        
        for (index, thoughtContent) in thoughts.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index + 1) * 0.8) {
                let thought = ThinkingThought(
                    content: thoughtContent,
                    timestamp: Date()
                )
                currentSession.thoughts.append(thought)
                
                // Final thought - complete the session
                if index == thoughts.count - 1 {
                    self.completeThinking(session: currentSession)
                }
            }
        }
    }
    
    private func completeThinking(session: ThinkingSession) {
        // Add to completed sessions
        completedThinkingSessions.append(session)
        
        // Add the actual response
        let response = DemoMessage(
            id: session.messageId,
            content: "Based on my analysis, here's my comprehensive response...",
            sender: .assistant,
            timestamp: Date()
        )
        messages.append(response)
    }
}
```

## Advanced Features

### Real-time Thinking Updates

```swift
class StreamingThinkingDataSource: ThinkingDataSource {
    @Published var activeThinkingSession: ThinkingSession?
    
    private func startStreamingThinking() {
        let sessionId = UUID().uuidString
        activeThinkingSession = ThinkingSession(
            thoughts: [],
            messageId: sessionId
        )
        
        // Simulate streaming thoughts
        streamThoughts()
    }
    
    private func streamThoughts() {
        let thoughtParts = [
            "I need to break this down step by step.",
            "First, let me understand the core question.",
            "The user is asking about...",
            "There are several factors to consider:",
            "1. Technical feasibility",
            "2. User experience implications", 
            "3. Performance considerations",
            "After weighing these factors...",
            "My recommendation would be..."
        ]
        
        for (index, part) in thoughtParts.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.6) {
                let thought = ThinkingThought(
                    content: part,
                    timestamp: Date()
                )
                self.activeThinkingSession?.thoughts.append(thought)
                
                if index == thoughtParts.count - 1 {
                    self.finalizeThinking()
                }
            }
        }
    }
    
    private func finalizeThinking() {
        guard let session = activeThinkingSession else { return }
        
        completedThinkingSessions.append(session)
        activeThinkingSession = nil
        
        // Add final response
        addResponse(for: session.messageId)
    }
}
```

### Custom Thinking Triggers

```swift
extension ThinkingDataSource {
    func sendMessage(_ content: String, attachments: [any ChatAttachment]) {
        if shouldTriggerThinking(content) {
            handleThinkingMessage(for: content)
        } else {
            handleRegularMessage(content, attachments: attachments)
        }
    }
    
    private func shouldTriggerThinking(_ content: String) -> Bool {
        let thinkingTriggers = [
            "think",
            "analyze",
            "explain your reasoning",
            "walk me through",
            "step by step"
        ]
        
        return thinkingTriggers.contains { trigger in
            content.lowercased().contains(trigger)
        }
    }
    
    private func handleThinkingMessage(for content: String) {
        let complexity = determineComplexity(content)
        let thoughtCount = complexity.thoughtCount
        let thinkingDelay = complexity.delay
        
        generateThoughts(count: thoughtCount, delay: thinkingDelay)
    }
    
    private func determineComplexity(_ content: String) -> (thoughtCount: Int, delay: Double) {
        if content.contains("complex") || content.contains("detailed") {
            return (6, 1.0) // More thoughts, slower pace
        } else if content.contains("quick") || content.contains("brief") {
            return (3, 0.5) // Fewer thoughts, faster pace
        } else {
            return (4, 0.8) // Default complexity
        }
    }
}
```

## UI Customization

### Custom Thinking Indicator

```swift
struct CustomThinkingIndicator: View {
    let thoughts: [ThinkingThought]
    let isThinking: Bool
    @Environment(\.chatTheme) private var theme
    
    @State private var isExpanded = true
    @State private var currentThoughtIndex = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            // Header with brain icon and status
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(theme.colors.accent)
                    .font(.title3)
                
                Text("AI is thinking...")
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
                
                if isThinking {
                    thinkingAnimation
                }
                
                Spacer()
                
                Button(action: { isExpanded.toggle() }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(theme.colors.accent)
                        .font(.caption)
                }
            }
            
            // Expandable thought content
            if isExpanded {
                thoughtsContent
            }
        }
        .padding(theme.spacing.md)
        .background(thinkingBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.layout.cornerRadius))
    }
    
    private var thinkingBackground: some View {
        LinearGradient(
            colors: [
                theme.colors.surface,
                theme.colors.surface.opacity(0.7)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var thoughtsContent: some View {
        LazyVStack(alignment: .leading, spacing: theme.spacing.xs) {
            ForEach(Array(thoughts.enumerated()), id: \.element.id) { index, thought in
                ThoughtRow(
                    thought: thought,
                    index: index,
                    isLatest: index == thoughts.count - 1 && isThinking
                )
            }
        }
        .animation(.easeInOut(duration: theme.animation.medium), value: thoughts.count)
    }
}

struct ThoughtRow: View {
    let thought: ThinkingThought
    let index: Int
    let isLatest: Bool
    
    @Environment(\.chatTheme) private var theme
    @State private var isVisible = false
    
    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            // Thought number indicator
            Text("\(index + 1)")
                .font(.caption2)
                .foregroundColor(theme.colors.accent)
                .frame(width: 20, height: 20)
                .background(
                    Circle()
                        .fill(theme.colors.accent.opacity(0.1))
                        .stroke(theme.colors.accent.opacity(0.3), lineWidth: 1)
                )
            
            // Thought content
            VStack(alignment: .leading, spacing: 2) {
                Text(thought.content)
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.text)
                
                Text(formatTime(thought.timestamp))
                    .font(.caption2)
                    .foregroundColor(theme.colors.textSecondary)
            }
            
            Spacer()
            
            if isLatest {
                pulsingIndicator
            }
        }
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 10)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3).delay(0.1)) {
                isVisible = true
            }
        }
    }
    
    private var pulsingIndicator: some View {
        Circle()
            .fill(theme.colors.accent)
            .frame(width: 6, height: 6)
            .scaleEffect(isLatest ? 1.2 : 1.0)
            .animation(
                .easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true),
                value: isLatest
            )
    }
}
```

### Themed Thinking Process

```swift
extension ThinkingIndicatorView {
    func customTheme(_ theme: ChatDesignTokens) -> some View {
        self
            .environment(\.chatTheme, theme)
    }
    
    func accentColor(_ color: Color) -> some View {
        let customTheme = ChatDesignTokens(
            colors: ChatColors(
                primary: color,
                accent: color
            )
        )
        return self.environment(\.chatTheme, customTheme)
    }
}
```

## Integration Patterns

### Backend Integration

```swift
class APIThinkingDataSource: ThinkingDataSource {
    private let apiClient: ChatAPIClient
    
    override func handleThinkingMessage() {
        let sessionId = UUID().uuidString
        
        Task {
            do {
                let stream = try await apiClient.streamThinking()
                await processThinkingStream(stream, sessionId: sessionId)
            } catch {
                await handleThinkingError(error)
            }
        }
    }
    
    @MainActor
    private func processThinkingStream(
        _ stream: AsyncThrowingStream<ThinkingUpdate, Error>,
        sessionId: String
    ) async {
        var session = ThinkingSession(thoughts: [], messageId: sessionId)
        
        do {
            for try await update in stream {
                switch update.type {
                case .thought:
                    let thought = ThinkingThought(
                        content: update.content,
                        timestamp: Date()
                    )
                    session.thoughts.append(thought)
                    
                case .completion:
                    completedThinkingSessions.append(session)
                    addFinalResponse(update.content, messageId: sessionId)
                    break
                }
            }
        } catch {
            await handleThinkingError(error)
        }
    }
}
```

### WebSocket Real-time Updates

```swift
class RealtimeThinkingDataSource: ThinkingDataSource {
    private var webSocket: URLSessionWebSocketTask?
    
    private func connectWebSocket() {
        let url = URL(string: "wss://api.example.com/thinking")!
        webSocket = URLSession.shared.webSocketTask(with: url)
        webSocket?.resume()
        
        receiveMessages()
    }
    
    private func receiveMessages() {
        webSocket?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.handleWebSocketMessage(text)
                default:
                    break
                }
                self?.receiveMessages() // Continue listening
                
            case .failure(let error):
                print("WebSocket error: \(error)")
            }
        }
    }
    
    private func handleWebSocketMessage(_ message: String) {
        guard let data = message.data(using: .utf8),
              let update = try? JSONDecoder().decode(ThinkingUpdate.self, from: data) else {
            return
        }
        
        DispatchQueue.main.async {
            self.processThinkingUpdate(update)
        }
    }
}
```

## Best Practices

### Performance Optimization

```swift
// ✅ Good: Limit thinking history
class OptimizedThinkingDataSource: ThinkingDataSource {
    private let maxThinkingSessions = 10
    
    override func completeThinking(session: ThinkingSession) {
        super.completeThinking(session: session)
        
        // Trim old thinking sessions
        if completedThinkingSessions.count > maxThinkingSessions {
            completedThinkingSessions.removeFirst()
        }
    }
}

// ✅ Good: Efficient thought updates
private func addThought(_ content: String, to sessionId: String) {
    if let index = completedThinkingSessions.firstIndex(where: { $0.messageId == sessionId }) {
        let thought = ThinkingThought(content: content, timestamp: Date())
        completedThinkingSessions[index].thoughts.append(thought)
    }
}
```

### User Experience

```swift
// ✅ Good: Provide thinking controls
struct ThinkingControls: View {
    @Binding var autoCollapse: Bool
    @Binding var thinkingSpeed: Double
    
    var body: some View {
        VStack {
            Toggle("Auto-collapse thinking", isOn: $autoCollapse)
            
            HStack {
                Text("Thinking speed")
                Slider(value: $thinkingSpeed, in: 0.5...2.0)
                Text("\(thinkingSpeed, specifier: "%.1f")x")
            }
        }
    }
}

// ✅ Good: Accessibility support
extension ThinkingIndicatorView {
    var accessibilityDescription: String {
        if isThinking {
            return "AI is currently thinking. \(thoughts.count) thoughts so far."
        } else {
            return "AI thinking completed with \(thoughts.count) thoughts."
        }
    }
}
```

### Error Handling

```swift
extension ThinkingDataSource {
    private func handleThinkingError(_ error: Error) {
        let errorMessage = DemoMessage(
            id: UUID().uuidString,
            content: "Sorry, I encountered an error while thinking: \(error.localizedDescription)",
            sender: .system,
            timestamp: Date()
        )
        
        DispatchQueue.main.async {
            self.messages.append(errorMessage)
        }
    }
    
    private func handleThinkingTimeout() {
        let timeoutMessage = DemoMessage(
            id: UUID().uuidString,
            content: "Thinking process timed out. Let me provide a direct response instead.",
            sender: .assistant,
            timestamp: Date()
        )
        
        DispatchQueue.main.async {
            self.messages.append(timeoutMessage)
        }
    }
}
```

## Testing

### Mock Thinking Scenarios

```swift
class MockThinkingDataSource: ThinkingDataSource {
    func simulateComplexThinking() {
        let complexThoughts = [
            "This is a multi-faceted problem requiring careful analysis...",
            "Let me break this down into key components:",
            "1. Technical requirements and constraints",
            "2. User experience considerations", 
            "3. Performance and scalability factors",
            "4. Security and privacy implications",
            "Analyzing component 1: Technical requirements...",
            "The system needs to handle...",
            "Analyzing component 2: User experience...",
            "Users expect...",
            "Synthesizing all factors...",
            "My recommendation is..."
        ]
        
        generateThoughts(complexThoughts, delay: 0.7)
    }
    
    func simulateQuickThinking() {
        let quickThoughts = [
            "Let me think about this quickly...",
            "The answer is straightforward:",
            "Here's my response."
        ]
        
        generateThoughts(quickThoughts, delay: 0.3)
    }
}
```

## Common Issues

### Memory Management
```swift
// ❌ Avoid: Retaining too many thinking sessions
// Can cause memory issues with long conversations

// ✅ Better: Implement cleanup
private func cleanupOldThinkingSessions() {
    let maxAge: TimeInterval = 3600 // 1 hour
    let cutoffDate = Date().addingTimeInterval(-maxAge)
    
    completedThinkingSessions.removeAll { session in
        session.thoughts.first?.timestamp ?? Date() < cutoffDate
    }
}
```

### Animation Performance
```swift
// ❌ Avoid: Complex animations for every thought
.animation(.spring(), value: thoughts) // Can be expensive

// ✅ Better: Simpler animations
.animation(.easeOut(duration: 0.2), value: thoughts.count)
```

Thinking messages create engaging, transparent AI interactions that build user trust and understanding. They're particularly effective for complex problem-solving scenarios where showing the reasoning process adds significant value.