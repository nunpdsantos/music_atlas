# Music Atlas 🎵

A comprehensive music theory exploration and interactive fretboard visualization app built with Flutter. Music Atlas combines the Circle of Fifths, extensive chord/scale databases, and beautiful interactive guitar and piano visualizations into one powerful musical reference tool.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)
![Material3](https://img.shields.io/badge/Material%203-757575?style=flat&logo=material-design&logoColor=white)

## Features

### 🎯 Core Functionality

- **Interactive Circle of Fifths** - Explore key relationships, view triads, and understand harmonic connections
- **Chord & Scale Search** - Comprehensive database with smart accidental toggles (♯/♭) and instant results
- **Key Transposition** - Transpose chord progressions to any key with one tap
- **Modal Scale Explorer** - All 7 modes (Ionian, Dorian, Phrygian, etc.) with characteristics and usage guides
- **Interactive Fretboard** - Beautiful guitar visualization with interval coloring and scrollable fret access
- **Piano Keyboard** - Elegant piano visualization with configurable octave ranges

### 🎨 Design Highlights

- **Material 3 Design** - Modern, polished interface with careful attention to visual hierarchy
- **Dark/Light Themes** - Full theme support with semantic color systems
- **Responsive Layout** - Optimized for all screen sizes with intelligent scaling
- **Professional Typography** - Inter font family for clarity and elegance
- **Color-Coded Intervals** - 12-color chromatic spectrum for instant interval recognition
- **Smooth Animations** - Thoughtful transitions and interactive feedback

### 🎸 Interactive Instruments

Both instruments feature:
- **Real-time Note Highlighting** - See chord and scale patterns instantly
- **Interval Color Coding** - Understand note relationships at a glance
- **Root Note Emphasis** - Clear visual distinction for tonal centers
- **Left/Right Handed Support** - Configurable for all players (guitar)
- **Smooth Scrolling** - Explore the entire fretboard with gesture controls
- **Visual Overview** - Minimap scrollbar for quick navigation (guitar)

## Screenshots

### Main Screens
- Circle of Fifths - Interactive key exploration
- Search - Chord and scale finder
- Transpose - Key transposition tool
- Modes - Modal scale reference
- Settings - User preferences

### Interactive Visualizations
- Guitar Fretboard - 24-fret visualization with interval coloring
- Piano Keyboard - 1-2 octave range with note highlighting

## Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- iOS Simulator / Android Emulator / Physical Device

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd music_atlas
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

**Android**
```bash
flutter build apk --release
```

**iOS**
```bash
flutter build ios --release
```

**Web**
```bash
flutter build web --release
```

## Architecture

### Tech Stack

- **Framework:** Flutter
- **State Management:** Flutter Riverpod
- **Architecture Pattern:** MVVM with separation of concerns
- **Design System:** Material 3 with custom AppTheme
- **Typography:** Google Fonts (Inter)

### Project Structure

```
lib/
├── core/               # Core utilities and configuration
│   ├── theme.dart      # Complete design system
│   └── note_utils.dart # Music theory utilities
├── data/               # Data models and repositories
│   ├── models/         # ChordDefinition, TriadPack, etc.
│   └── repositories/   # Data loading and management
├── logic/              # Business logic and state
│   ├── providers.dart  # Riverpod providers
│   └── theory_engine.dart # Music theory calculations
└── ui/                 # User interface
    ├── components/     # Reusable widgets
    │   ├── guitar_fretboard.dart
    │   ├── piano_keyboard.dart
    │   └── interactive_fretboard_sheet.dart
    └── screens/        # Main app screens
        ├── home_shell.dart
        ├── circle_screen.dart
        ├── search_screen.dart
        ├── transposer_screen.dart
        ├── modes_screen.dart
        └── settings_screen.dart
```

### Key Components

#### Design System (`lib/core/theme.dart`)
Central theme configuration with:
- Brand colors (Tonic Blue, Minor Amber, Accent Red)
- Semantic light/dark mode colors
- 12-interval color mapping for music theory
- Typography scales and weights
- Helper methods for theme-aware components

#### Music Theory Engine (`lib/logic/theory_engine.dart`)
- Major scale generation with strict note spelling
- Relative minor relationships (natural, harmonic, melodic)
- Key signature generation
- Mode characteristics database
- Interval calculations

#### State Management (`lib/logic/providers.dart`)
Riverpod providers for:
- Dark mode toggle
- Guitar handedness preference
- Octave range selection
- Chord search state
- Selected key/scale tracking

## Music Theory Features

### Circle of Fifths
- 12-key circular layout
- Major and relative minor relationships
- Triad visualization for each key
- Key signature display (sharps/flats)

### Chord Database
- Extensive chord library with proper theoretical spellings
- Aliases and enharmonic equivalents
- Interval structure for each chord
- Visual fretboard representations

### Scale System
- All 7 modal scales (Ionian through Locrian)
- Characteristics and mood descriptions
- Common usage scenarios
- Interval patterns

### Transposition
- Transpose any chord progression to any key
- Maintains chord quality and relationships
- Instant preview of results

## Customization

### Theme Customization

The app's visual design is controlled by `lib/core/theme.dart`. You can customize:

**Brand Colors**
```dart
static const tonicBlue = Color(0xFF1D4ED8);
static const minorAmber = Color(0xFFA36D11);
static const accentRed = Color(0xFFBE123C);
```

**Interval Colors**
```dart
static const intervalColors = [
  Color(0xFF1D4ED8),  // Root (Blue)
  Color(0xFFEF4444),  // ♭2 (Red)
  // ... 12 colors total
];
```

### Settings

User-configurable preferences:
- **Dark Mode** - Toggle between light and dark themes
- **Left/Right Handed** - Switch guitar headstock orientation
- **Piano Octaves** - Choose 1 or 2 octave display range

## Development Guidelines

For detailed information about design principles, code patterns, and contribution guidelines, see [DESIGN_GUIDELINES.md](DESIGN_GUIDELINES.md).

### Key Principles

1. **Visual Polish** - Every component should feel polished and professional
2. **Music Theory Accuracy** - All theoretical information must be correct
3. **Performance** - Smooth 60fps interactions and animations
4. **Accessibility** - Clear contrast ratios and readable typography
5. **Consistency** - Follow established design patterns throughout

## Dependencies

### Main Dependencies
```yaml
flutter_riverpod: ^2.4.0      # State management
google_fonts: ^6.1.0          # Typography
```

### Dev Dependencies
```yaml
flutter_lints: ^2.0.0         # Code quality
```

## Testing

Run tests:
```bash
flutter test
```

Run with coverage:
```bash
flutter test --coverage
```

## Performance

- **60 FPS** target for all animations and scrolling
- **Efficient rendering** using CustomPaint for instruments
- **Debounced search** for instant results without lag
- **Lazy loading** of heavy components

## Browser Support (Web)

- Chrome/Edge (recommended)
- Firefox
- Safari

## Contributing

1. Follow the design guidelines in `DESIGN_GUIDELINES.md`
2. Maintain music theory accuracy
3. Test on multiple screen sizes
4. Ensure dark/light theme compatibility
5. Write clear commit messages

## License

[Add your license here]

## Acknowledgments

- Flutter team for the amazing framework
- Music theory resources and community
- All contributors and testers

## Support

For issues, questions, or suggestions:
- Open an issue in the repository
- Check existing documentation
- Review the design guidelines

---

**Made with ❤️ using Flutter**
