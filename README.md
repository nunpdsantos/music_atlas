# Music Atlas

A premium Flutter application for music theory visualization and learning. Music Atlas helps musicians understand chord structures, scales, and harmonic relationships through beautiful interactive instrument visualizations.

## Features

### Circle of Fifths
Interactive circle of fifths visualization showing key relationships, relative majors/minors, and harmonic progressions.

### Interactive Instruments
- **Guitar Fretboard**: Premium rosewood fretboard with realistic strings, mother-of-pearl inlays, and interval-colored note markers
- **Piano Keyboard**: Elegant ivory and ebony keys with 3D beveling and proper lighting effects

### Chord & Scale Visualization
- Color-coded interval system for instant recognition
- Root note highlighting with glow effects
- Dynamic legend showing active intervals
- Support for all chord qualities and scale modes

### Transposer
Quickly transpose chords and progressions to any key.

### Modes Explorer
Learn and visualize all modal scales with their characteristic intervals.

## Architecture

```
lib/
├── core/                    # Core utilities & design system
│   ├── theme.dart          # Centralized theme & colors
│   ├── note_utils.dart     # Music theory utilities
│   └── size_config.dart    # Responsive sizing
├── data/                    # Data models & persistence
│   ├── models.dart         # Chord/Scale definitions
│   ├── guitar_data.dart    # Guitar-specific data
│   └── repository.dart     # Data access layer
├── logic/                   # Business logic & state
│   ├── providers.dart      # Riverpod state management
│   └── theory_engine.dart  # Music theory calculations
├── ui/
│   ├── components/         # Reusable UI components
│   │   ├── guitar_fretboard.dart
│   │   ├── piano_keyboard.dart
│   │   ├── interactive_fretboard_sheet.dart
│   │   ├── fretboard_overview.dart
│   │   ├── circle_of_fifths.dart
│   │   └── chord_card.dart
│   └── screens/            # Full-page screens
└── main.dart               # Entry point
```

## Design System

Music Atlas uses a carefully crafted design system. See [STYLE_GUIDE.md](./STYLE_GUIDE.md) for complete design specifications.

### Key Principles
1. **Premium Feel**: 3D effects, gradients, and realistic material simulations
2. **Musical Accuracy**: Proper interval coloring and theory-correct visualizations
3. **Accessibility**: Clear contrast, readable labels, and intuitive interactions
4. **Theme Consistency**: Full light/dark mode support throughout

### Interval Color System
Each musical interval has a unique color for instant visual recognition:
- Root (Tonic Blue) - The foundation
- Perfect intervals (Blue/Green spectrum) - Stable, consonant
- Major/Minor thirds (Amber/Yellow) - Character-defining
- Chromatic tones (Red/Purple spectrum) - Tension and color

## Development

### Prerequisites
- Flutter SDK 3.19+
- Dart 3.0+

### Getting Started
```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

### State Management
The app uses **Riverpod** for state management. Key providers:
- `circleProvider`: Circle of fifths key selection
- `triadPackProvider`: Current scale/chord data
- `fretboardViewProvider`: Instrument view settings
- `appSettingsProvider`: User preferences

## Contributing

When contributing to Music Atlas:
1. Follow the design system in [STYLE_GUIDE.md](./STYLE_GUIDE.md)
2. Maintain the premium visual quality
3. Ensure theme consistency (light/dark mode)
4. Test on multiple screen sizes

## License

MIT License - See LICENSE file for details.
