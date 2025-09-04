# Incubate - Personal Journaling App

A beautiful, private journaling app that helps you capture thoughts, track goals, and gain insights through AI-powered reflection.

## Features

### Core Journaling
- **Raw Entries**: Free-form text journaling
- **Todo Lists**: Track daily tasks and completion
- **Goal Setting**: Define and monitor personal objectives
- **Reflection**: Q&A format for structured self-reflection

### Inky AI Companion
Meet Inky, your AI-powered growth companion that analyzes your journal entries to provide personalized insights and daily reflection prompts.

#### What Inky Does
- **Sentiment Analysis**: Tracks your mood trends over time using Apple's Natural Language framework
- **Pattern Detection**: Identifies productivity patterns, goal correlations, and growth momentum
- **Daily Check-ins**: Guides you through structured reflection conversations
- **Growth Insights**: Celebrates wins and highlights areas for improvement

#### How It Works
1. **Daily Reflection**: Tap "Daily Reflection" on the main screen
2. **3-Stage Conversation**: 
   - Greeting & Check-in
   - Contextual Insights & Patterns
   - Goal-Setting & Forward Planning
3. **Personalized Insights**: View patterns, momentum, and growth scores
4. **Privacy First**: All analysis happens on-device using Apple's Natural Language framework

#### Technical Implementation
- **Natural Language Framework**: Sentiment analysis and keyword extraction
- **Pattern Recognition**: Cross-entry correlation analysis
- **Demo Data**: Generates sample entries for testing when no data exists
- **SwiftUI Architecture**: Follows existing app patterns and design system

## Getting Started

### Prerequisites
- iOS 15.0+
- Xcode 13.0+
- Natural Language framework (included with iOS)

### Installation
1. Clone the repository
2. Open `Incubate.xcodeproj` in Xcode
3. Build and run on your device or simulator

### Testing Inky AI
The app includes demo data generation for testing:
- Create entries or let Inky generate sample data
- Tap "Daily Reflection" to start a reflection session
- View insights and patterns in the insights sheet

## Architecture

### Services
- `DatabaseManager`: SQLite persistence for all journal entries
- `InkyAIService`: AI-powered analysis and conversation generation
- `HapticsService`: Tactile feedback for better UX

### Models
- `Entry`: Base journal entry with type, content, and metadata
- `EntryDetail`: Rich entry data with child items
- `DailyReflection`: Conversation state and growth tracking

### Views
- `MainView`: Dashboard with entry buckets and Inky button
- `DailyReflectionView`: Chat interface for AI conversations
- `EntriesListView`: Browse entries by type
- Various editors for different entry types

## Privacy & Security

- **Local-Only**: All data stays on your device
- **No Network Calls**: Inky works entirely offline
- **Apple Frameworks**: Uses only Apple's built-in Natural Language capabilities
- **User Control**: You decide when to engage with AI features

## Future Enhancements

- Voice conversation support
- Advanced pattern recognition
- Integration with Health app data
- Custom insight categories
- Export and backup features

## Contributing

This is a personal project showcasing modern iOS development practices:
- SwiftUI for declarative UI
- Combine for reactive programming
- SQLite for local persistence
- Apple's Natural Language framework for AI capabilities

---

Built with ❤️ and ☕ for personal growth and reflection.
