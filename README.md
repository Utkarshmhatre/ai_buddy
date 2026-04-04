# 🧠 AI Buddy - Privacy-First Mental Wellness Companion

<p align="center">
  <img src="assets/logo.jpeg" alt="AI Buddy Logo" width="150" height="150" style="border-radius: 30px;">
</p>

<p align="center">
  <strong>Your private, AI-powered companion for daily mental wellness</strong><br>
  <em>Built with Flutter • Powered by Google Gemini AI • Privacy-First Architecture</em>
</p>

<p align="center">
  <a href="#-features">Features</a> •
  <a href="#-installation">Installation</a> •
  <a href="#-usage">Usage</a> •
  <a href="#-roadmap">Roadmap</a> •
  <a href="#-contributing">Contributing</a> •
  <a href="#-license">License</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.19+-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.3+-0175C2?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Gemini-AI-4285F4?logo=google" alt="Gemini AI">
  <img src="https://img.shields.io/badge/License-Proprietary-red.svg" alt="License">
  <img src="https://img.shields.io/badge/Status-In%20Development-yellow.svg" alt="Status">
</p>

---

## 🌟 About

AI Buddy is a **proprietary mental wellness companion** developed by our dedicated team, combining empathetic AI conversations with evidence-based therapeutic techniques. Originally created for a hackathon, we're now evolving it into a comprehensive mental health support platform with a focus on privacy, accessibility, and user wellbeing.

### Why AI Buddy?

- **🔒 Privacy-First**: All data encrypted and stored locally on your device
- **🤖 Emotion-Aware AI**: Aura, your AI companion, responds with contextual emotions through animated GIFs
- **🧘 Evidence-Based**: Integrates CBT, DBT, and mindfulness techniques
- **🛡️ Safety-Focused**: Multi-layer crisis detection with immediate access to professional help
- **♿ Accessible**: WCAG 2.1 AA compliant with comprehensive accessibility features
- **🌍 No Account Required**: Use the app without signing up or sharing personal information

### Development Status

🚧 **Active Development**: This project is currently being developed by our core team. The code is shared for transparency and educational purposes, but is not open for public contributions or commercial use.

> ⚠️ **Important**: AI Buddy is NOT a replacement for professional mental health care. If you're experiencing a crisis, please contact emergency services (911) or the 988 Suicide & Crisis Lifeline.

---

## ✨ Features

### 🎭 Aura - Your AI Companion

Meet **Aura**, an animated AI companion that responds with emotion-appropriate expressions:

<p align="center">
  <img src="assets/gifs/empathetic/medium.gif" alt="Empathetic" width="100">
  <img src="assets/gifs/encouraging/medium.gif" alt="Encouraging" width="100">
  <img src="assets/gifs/calm/medium.gif" alt="Calm" width="100">
  <img src="assets/gifs/celebratory/medium.gif" alt="Celebratory" width="100">
</p>

- **6 Emotion Types**: Empathetic, Encouraging, Calm, Celebratory, Thoughtful, Supportive
- **3 Intensity Levels**: Low, Medium, High animations for nuanced expression
- **18 Unique GIFs**: Carefully crafted animations that respond to conversation context
- **Animated Background**: Calming ambient animations in chat interface

### 💬 Intelligent Conversations

- **Context-Aware Responses**: AI remembers your conversation history and personal preferences
- **Therapeutic Techniques**: Natural integration of CBT, DBT, and mindfulness practices
- **Crisis Detection**: 4-layer detection system with immediate safety resources
- **Voice Input Ready**: Interface prepared for future voice interaction features
- **Message Management**: Edit, delete, and retry messages with full control

### 📊 Wellness Tracking

#### Mood Tracking
- Quick emoji-based check-ins
- Visual trend analysis with charts
- Pattern recognition and insights
- Exportable mood history

#### Mindful Journaling
- AI-generated guided prompts
- Free-form writing support
- Mood tagging for entries
- Rich text formatting (coming soon)
- Search and filter capabilities

#### Wellness Exercises
- **Breathing Techniques**: Box Breathing, 4-7-8 Relaxation, Deep Belly, Energizing Breath
- **Visual Guidance**: Animated breathing circles with haptic feedback
- **Session Tracking**: Monitor your practice progress
- **Customizable**: Adjust duration and intensity to your needs

### 🛡️ Comprehensive Safety Features

#### Crisis Detection System
- **Layer 1**: Local keyword detection (150+ patterns across 9 categories)
- **Layer 2**: AI-powered sentiment analysis
- **Layer 3**: Pattern analysis across sessions
- **Layer 4**: Contextual escalation logic

#### International Crisis Resources
Immediate access to crisis hotlines for **12 countries**:
- 🇺🇸 USA: 988 Suicide & Crisis Lifeline
- 🇬🇧 UK: Samaritans (116 123)
- 🇨🇦 Canada: Crisis Services Canada
- 🇦🇺 Australia: Lifeline (13 11 14)
- 🇮🇳 India: iCall (9820466726)
- And 7 more countries...

### 🔒 Privacy & Security

- **100% Local Storage**: All data stays on your device
- **AES-256 Encryption**: Military-grade encryption for sensitive data
- **No Cloud Sync**: Nothing uploaded to external servers
- **PII Detection**: Automatic redaction of sensitive information
- **Data Export**: Download your data anytime (GDPR compliant)
- **Secure Storage**: Platform-specific secure storage for API keys

### ♿ Accessibility

Built with **WCAG 2.1 AA compliance**:
- **4.5:1 Color Contrast**: High-contrast themes for readability
- **44x44dp Touch Targets**: Easy interaction on all devices
- **Screen Reader Support**: Full semantic labels and focus management
- **Reduced Motion**: Respects system animation preferences
- **Dynamic Text**: Supports system font scaling

---

## 🚀 Installation

### Prerequisites

- **Flutter SDK**: 3.19.0 or higher
- **Dart SDK**: 3.3.0 or higher
- **Google Gemini API Key**: Get one from [Google AI Studio](https://aistudio.google.com/app/apikey)

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/ai_buddy.git
   cd ai_buddy
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Get your Gemini API key**
   - Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
   - Sign in with your Google account
   - Click "Get API Key" or "Create API Key"
   - Copy your API key

4. **Run the app**
   ```bash
   # The app will prompt you to enter your API key on first launch
   flutter run
   
   # Or provide it via command line
   flutter run --dart-define=GEMINI_API_KEY=your_api_key_here
   ```

### Platform-Specific Setup

<details>
<summary><b>Android</b></summary>

Minimum SDK 24 (Android 7.0) is required. No additional setup needed.

```bash
flutter run -d android
```
</details>

<details>
<summary><b>iOS</b></summary>

Minimum iOS 12.0 is required.

```bash
flutter run -d ios
```
</details>

<details>
<summary><b>Web</b></summary>

```bash
flutter run -d chrome
```
</details>

<details>
<summary><b>Desktop (macOS, Linux, Windows)</b></summary>

```bash
# macOS
flutter run -d macos

# Linux
flutter run -d linux

# Windows
flutter run -d windows
```
</details>

### Building for Production

```bash
# Android APK
flutter build apk --release --dart-define=GEMINI_API_KEY=your_api_key_here

# Android App Bundle
flutter build appbundle --release --dart-define=GEMINI_API_KEY=your_api_key_here

# iOS
flutter build ios --release --dart-define=GEMINI_API_KEY=your_api_key_here

# Web
flutter build web --release --dart-define=GEMINI_API_KEY=your_api_key_here
```

---

## 📱 Usage

### First-Time Setup

1. **Enter API Key**: On first launch, you'll be prompted to enter your Gemini API key
2. **Welcome Screen**: Learn about AI Buddy's features and safety information
3. **Start Chatting**: Begin your conversation with Aura immediately

### Daily Workflow

1. **Morning Check-In**: Log your mood and receive a personalized greeting
2. **Chat with Aura**: Share your thoughts, feelings, or challenges
3. **Use Exercises**: Practice breathing techniques or grounding exercises when needed
4. **Journal**: Reflect on your day with guided or free-form journaling
5. **Review Progress**: Check your mood trends and insights

### Key Screens

- **Home**: Dashboard with daily greeting, mood summary, and quick actions
- **Chat**: Main conversation interface with Aura
- **Mood**: Track and visualize your emotional patterns
- **Journal**: Write entries with AI-generated prompts
- **Exercises**: Access guided breathing and mindfulness practices
- **Insights**: View AI-generated patterns and progress reports
- **Settings**: Customize themes, manage data, and configure preferences

---

## 🛠️ Tech Stack

### Core Technologies

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform UI framework |
| **Dart** | Programming language |
| **Google Gemini AI** | Conversational AI and sentiment analysis |
| **Isar Database** | Local encrypted storage |
| **flutter_bloc** | State management |

### Key Packages

```yaml
dependencies:
  # AI & Services
  google_generative_ai: ^0.4.6
  
  # State Management
  flutter_bloc: ^9.1.1
  
  # Database & Storage
  isar: ^4.0.0-dev.14
  flutter_secure_storage: ^10.0.0
  shared_preferences: ^2.2.2
  
  # Security
  encrypt: ^5.0.3
  local_auth: ^3.0.0
  
  # UI/UX
  fl_chart: ^0.69.0
  flutter_animate: ^4.5.0
  flutter_quill: ^11.0.0
  
  # Utilities
  go_router: ^14.6.2
  url_launcher: ^6.2.4
  share_plus: ^9.0.0
```

### Architecture

```
lib/
├── core/
│   ├── ai/                    # Gemini AI integration
│   ├── safety/                # Crisis detection
│   ├── security/              # Encryption & auth
│   ├── theme/                 # App theming
│   └── widgets/               # Shared components
├── data/
│   ├── models/                # Data models
│   └── repositories/          # Data access layer
└── features/
    ├── chat/                  # AI conversation
    ├── mood/                  # Mood tracking
    ├── journal/               # Journaling
    ├── exercises/             # Wellness exercises
    ├── insights/              # Analytics & patterns
    └── settings/              # App configuration
```

---

## 🗺️ Roadmap

### ✅ Completed (v1.1.0)

- [x] Core AI chat with Aura companion
- [x] Emotion-responsive GIF system (18 unique animations)
- [x] Mood tracking with visual analytics
- [x] Journal with AI-generated prompts
- [x] Breathing exercises (4 types)
- [x] Crisis detection and safety resources
- [x] WCAG 2.1 AA accessibility compliance
- [x] Dark mode and theme customization
- [x] Local encryption (AES-256)
- [x] Session timeout and app lock

### 🔄 In Progress (v1.2.0)

- [ ] Real-time mood chart visualization
- [ ] Advanced streak tracking system
- [ ] Rich-text journaling with Quill editor
- [ ] Journal search and filtering
- [ ] Message editing and deletion
- [ ] Voice input integration
- [ ] Export mood/journal data as PDF

### 🔮 Future Plans (v2.0+)

- [ ] **Advanced AI Features**
  - [ ] Streaming responses for natural conversation flow
  - [ ] Context-aware function calling (trigger exercises, create journal entries)
  - [ ] Predictive mood analysis
  - [ ] Personalized daily insights and recommendations
  
- [ ] **Enhanced Wellness Tools**
  - [ ] Guided meditation library
  - [ ] Grounding exercises (5-4-3-2-1 technique)
  - [ ] Progressive muscle relaxation
  - [ ] Sleep tracking and sleep hygiene tips
  - [ ] Activity scheduling (behavioral activation)
  
- [ ] **Social & Community**
  - [ ] Anonymous peer support groups (with moderation)
  - [ ] Share progress with accountability partners
  - [ ] Community challenges and group activities
  
- [ ] **Professional Integration**
  - [ ] Export summaries for therapists
  - [ ] Professional dashboard for mental health providers
  - [ ] Telehealth integration options
  
- [ ] **Platform Expansion**
  - [ ] Wear OS / watchOS companion apps
  - [ ] Web app with full feature parity
  - [ ] Browser extension for quick check-ins
  
- [ ] **Internationalization**
  - [ ] Multi-language support (Spanish, French, Hindi, Japanese, etc.)
  - [ ] Culturally-adapted crisis resources
  - [ ] Localized mental health content

### 📊 Development Phases

| Phase | Focus | Status |
|-------|-------|--------|
| Phase 1 | Core infrastructure, theming, navigation | ✅ Complete |
| Phase 2 | AI chat integration, basic mood tracking | ✅ Complete |
| Phase 3 | Journaling, exercises, enhanced mood features | ✅ Complete |
| Phase 4 | AI enhancements, personalization | ✅ Complete |
| Phase 5 | Safety hardening, accessibility, beta testing | ✅ Complete |
| Phase 6 | Advanced features, data visualization | 🔄 In Progress |
| Phase 7 | Community features, professional tools | 📋 Planned |

---

## 👥 Team & Development

AI Buddy is developed and maintained by our dedicated team. This is a **proprietary project** currently in active development.

### Core Team

- **Project Lead**: [Your Name]
- **Developers**: [Team Member Names]
- **UI/UX Design**: [Designer Names]
- **Mental Health Consulting**: [Professional Names]

### Development Status

🔒 **Private Development**: This project is currently being developed by our core team. We are not accepting external contributions at this time.

### For Team Members

#### Development Guidelines

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter_bloc` for state management
- Maintain repository pattern for data access
- Write meaningful commit messages ([Conventional Commits](https://www.conventionalcommits.org/))

#### Branch Strategy

```bash
main          # Production-ready code
develop       # Integration branch
feature/*     # New features
bugfix/*      # Bug fixes
hotfix/*      # Emergency fixes
```

#### Commit Standards

```bash
feat: add new breathing exercise
fix: resolve mood chart data loading
docs: update installation instructions
style: format code according to Dart guidelines
refactor: restructure AI service architecture
test: add unit tests for crisis detection
chore: update dependencies
```

#### Testing Requirements

- Unit tests for all business logic
- Widget tests for UI components
- Integration tests for critical user flows
- Minimum 70% code coverage for new features

#### Pull Request Process

1. Create feature branch from `develop`
2. Implement changes with tests
3. Update documentation
4. Create PR to `develop` with description
5. Wait for team code review
6. Address review feedback
7. Merge after approval

---

## 🐛 Feedback & Bug Reporting

### For Team Members

Use our internal issue tracking system for bug reports and feature requests. Follow these templates for consistency:

### Bug Report Template

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '...'
3. See error

**Expected behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots.

**Environment:**
 - Device: [e.g. iPhone 12, Pixel 7]
 - OS: [e.g. iOS 16, Android 13]
 - App Version: [e.g. 1.1.0]
 - Build: [e.g. debug/release]
```

### Feature Request Template

```markdown
**Is your feature request related to a problem?**
A clear description of the problem.

**Describe the solution you'd like**
What you want to happen.

**Describe alternatives you've considered**
Other solutions you've thought about.

**Additional context**
Any other context, mockups, or screenshots.

**Priority**
Low / Medium / High / Critical
```

### For Public Users (When App is Released)

Once the app is publicly available, you can:
- Report bugs through the in-app feedback system
- Contact support via email: [support-email@example.com]
- Visit our website for FAQs and troubleshooting

---

## 📄 License & Usage Rights

**Copyright © 2024-2025 [Your Name/Team Name]. All Rights Reserved.**

This is proprietary software. The source code is provided for **reference and educational purposes only**.

### ⚖️ Usage Restrictions

❌ **You MAY NOT**:
- Use this software commercially without explicit written permission
- Redistribute or sublicense this software
- Modify and distribute this software
- Remove or alter copyright notices
- Use this software in derivative works without permission
- Copy substantial portions of the code for other projects

✅ **You MAY**:
- View the source code for learning purposes
- Use the app for personal mental wellness (when publicly released)
- Report bugs and suggest improvements through official channels

### 🔒 Proprietary Notice

This software and associated documentation files (the "Software") are the proprietary and confidential information of [Your Name/Team Name]. The Software is protected by copyright laws and international copyright treaties, as well as other intellectual property laws and treaties.

**No license or rights are granted except as expressly set forth above.**

### 📋 Required Attribution

If you discuss or reference this project in any public medium (blog posts, articles, presentations), you must:
- Provide clear attribution to the original creators
- Link back to the official repository
- Not imply endorsement without permission

### 🤝 Licensing Inquiries

For commercial licensing, partnerships, or usage permissions, please contact:
- **Email**: [your.email@example.com]
- **Website**: [your-website.com]

### ⚠️ Liability Disclaimer

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY ARISING FROM THE USE OF THE SOFTWARE.

**This app is not a substitute for professional mental health care.**

---

## 🚫 Third-Party Use

This project is **NOT open source**. While the code is visible on GitHub, visibility does not equal permission to use, modify, or distribute.

If you're interested in:
- **Using this project**: Wait for our official public release
- **Contributing**: Join our team (contact us for opportunities)
- **Commercial licensing**: Reach out for partnership discussions
- **Academic use**: Contact us for special permissions

---

## 🙏 Acknowledgments

### Our Team

- **Development Team**: Building the future of mental wellness technology
- **Design Team**: Crafting empathetic and accessible user experiences
- **Mental Health Consultants**: Ensuring evidence-based and safe therapeutic approaches
- **Quality Assurance**: Testing rigorously to ensure reliability and safety

### Technologies & Libraries

- [Flutter](https://flutter.dev/) - Cross-platform UI framework
- [Google Gemini AI](https://ai.google.dev/) - Conversational AI capabilities
- [Isar Database](https://isar.dev/) - Fast, encrypted local storage
- All the amazing open-source packages that make this project possible

### Special Thanks

- Mental health professionals who reviewed our safety features and therapeutic approach
- Beta testers who provided invaluable feedback during development
- The Flutter community for exceptional framework and support
- Google for making Gemini AI accessible to developers
- Our families and friends for supporting this important mission

### Research & Resources

This project incorporates evidence-based practices from:
- Cognitive Behavioral Therapy (CBT) literature
- Dialectical Behavior Therapy (DBT) techniques
- Mindfulness-Based Stress Reduction (MBSR) principles
- Crisis intervention best practices

---

## 📞 Support & Contact

### For Team Members

- **Internal Documentation**: [Team Wiki/Confluence]
- **Team Chat**: [Slack/Discord Channel]
- **Project Management**: [Jira/Asana/Trello]
- **Code Repository**: [GitHub Private Repo]

### Business Inquiries

- **Partnership Opportunities**: [business@example.com]
- **Licensing Inquiries**: [licensing@example.com]
- **Press & Media**: [press@example.com]
- **General Contact**: [contact@example.com]

### For Future Public Users

Once AI Buddy is publicly released:
- **User Support**: [support@example.com]
- **Technical Issues**: [help@example.com]
- **Website**: [www.aibuddy.app] (coming soon)

### In Crisis?

**This app is not a substitute for professional help.**

- **🚨 Emergency**: Call 911 (US) or your local emergency number
- **📞 Crisis Support**: Call 988 (US) or your local crisis line
- **💬 Text Support**: Text HOME to 741741 (Crisis Text Line)
- **🌍 International**: [Find Your Country's Resources](https://findahelpline.com/)

---

<p align="center">
  <strong>Built with 💜 for mental wellness</strong>
  <br>
  <em>Remember: It's okay to not be okay. Help is always available.</em>
</p>

<p align="center">
  <a href="#-about">Back to Top</a>
</p>
