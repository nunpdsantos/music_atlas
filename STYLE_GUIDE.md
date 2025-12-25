# Music Atlas Style Guide

This document defines the visual design system and coding standards for the Music Atlas app. Follow these guidelines to maintain consistency and premium quality across all components.

---

## Design Philosophy

### Core Principles

1. **Premium & Polished**: Every element should feel crafted and intentional
2. **Realistic Materials**: Instruments should evoke real-world materials (wood, ivory, metal)
3. **Musical Accuracy**: Visual representations must be theoretically correct
4. **Accessibility First**: Readability and usability for all users
5. **Seamless Theming**: Full light/dark mode parity

---

## Color System

### Brand Colors
```dart
static const Color tonicBlue = Color(0xFF1D4ED8);     // Primary - Root notes
static const Color minorAmber = Color(0xFFA36D11);    // Minor chord indicator
static const Color accentRed = Color(0xFFBE123C);     // Alternative accent
```

### Light Theme
```dart
scaffoldBg:     Color(0xFFF8FAFC)   // Light grey background
cardBg:         Colors.white        // Pure white cards
borderColor:    Color(0xFFE5E7EB)   // Subtle grey borders
textPrimary:    Color(0xFF0F172A)   // Near-black text
textSecondary:  Color(0xFF6B7280)   // Medium grey text
```

### Dark Theme
```dart
darkScaffoldBg:    Color(0xFF0F172A)   // Deep slate background
darkCardBg:        Color(0xFF1E293B)   // Elevated cards
darkBorderColor:   Color(0xFF334155)   // Visible borders
darkTextPrimary:   Color(0xFFF1F5F9)   // Off-white text
darkTextSecondary: Color(0xFF94A3B8)   // Muted grey text
```

### Interval Color Mapping
Each chromatic interval has a unique color for instant visual recognition:

| Interval | Semitones | Color | Hex |
|----------|-----------|-------|-----|
| Root | 0 | Tonic Blue | `#1D4ED8` |
| minor 2nd | 1 | Red | `#EF4444` |
| Major 2nd | 2 | Orange | `#F97316` |
| minor 3rd | 3 | Yellow | `#EAB308` |
| Major 3rd | 4 | Amber | `#F59E0B` |
| Perfect 4th | 5 | Green | `#22C55E` |
| Tritone | 6 | Teal | `#10B981` |
| Perfect 5th | 7 | Blue | `#3B82F6` |
| minor 6th | 8 | Indigo | `#6366F1` |
| Major 6th | 9 | Purple | `#8B5CF6` |
| minor 7th | 10 | Magenta | `#A855F7` |
| Major 7th | 11 | Pink | `#D946EF` |

**Usage**: Always use `AppTheme.getIntervalColor(interval)` for consistency.

---

## Typography

### Font Family
- **Primary**: Inter (Google Fonts)
- **Fallback**: System sans-serif

### Text Styles
```dart
// Headers
fontSize: 24, fontWeight: w800, letterSpacing: -0.5

// Section titles
fontSize: 18, fontWeight: w700

// Body text
fontSize: 14-16, fontWeight: w400-w500

// Labels & captions
fontSize: 11-12, fontWeight: w500-w600
```

---

## Component Design Rules

### Guitar Fretboard

**Materials**:
- Fretboard: Rosewood gradient (dark browns with grain texture)
- Frets: Nickel silver with 3D beveling
- Nut: Bone/ivory appearance with warm white gradient
- Strings: Bronze (wound) and steel (plain) with specular highlights

**Visual Effects**:
```dart
// Wood grain texture
for (int i = 0; i < 30; i++) {
  // Subtle wavy lines simulating grain
}

// Fret markers: Mother of pearl inlays
RadialGradient(
  colors: [Color(0xFFFAFAFA), Color(0xFFE8E8E8), Color(0xFFD4D4D4)],
  center: Alignment(-0.3, -0.3),  // Off-center for realism
)
```

**Note Markers**:
- Gradient fill using interval color
- Inner highlight for glass effect
- Drop shadow for depth
- White border ring
- Root notes: Additional outer glow

### Piano Keyboard

**Materials**:
- White keys: Ivory gradient with subtle aging
- Black keys: Ebony with glossy specular highlight
- Case: Dark wood/lacquer finish

**Key Construction**:
```dart
// White key gradient (top to bottom)
colors: [
  Color(0xFFFFFEFA),  // Bright top
  Color(0xFFFFFDF8),  // Slight warmth
  Color(0xFFF8F5EE),  // Mid-body
  Color(0xFFEDE9E0),  // Darker bottom edge
]

// Black key with bevel
// Top highlight, left edge highlight, center specular
```

**Note Markers**:
- Root notes: Filled circle with interval color + glow
- Other tones: Outlined circle with interval-colored border
- Labels: White on dark, dark on light backgrounds

### Legend Items

**Structure**:
- Gradient-filled color dot (14x14px)
- Subtle shadow for depth
- Bold weight label text

```dart
Container(
  decoration: BoxDecoration(
    gradient: RadialGradient(
      colors: [Color.lerp(color, Colors.white, 0.25)!, color],
      center: Alignment(-0.3, -0.3),
    ),
    boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 4)],
  ),
)
```

---

## Shadows & Elevation

### Standard Shadows
```dart
// Cards & containers
BoxShadow(
  color: Colors.black.withOpacity(isDark ? 0.3 : 0.12),
  blurRadius: 12,
  offset: Offset(0, 4),
)

// Interactive elements
BoxShadow(
  color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
  blurRadius: 6,
  offset: Offset(0, 2),
)

// Heavy elements (instruments)
BoxShadow(
  color: Colors.black.withOpacity(isDark ? 0.4 : 0.2),
  blurRadius: 20,
  offset: Offset(0, 8),
)
```

### Inner Shadows (for depth)
Use gradient overlays starting from edges:
```dart
LinearGradient(
  colors: [Colors.black.withOpacity(0.15), Colors.transparent],
  begin: Alignment.topCenter,
  end: Alignment(0, 0.1),
)
```

---

## Border Radii

```dart
// Large containers (sheets, modals)
BorderRadius.circular(28)

// Cards & panels
BorderRadius.circular(20)

// Medium elements (buttons, toggles)
BorderRadius.circular(12-16)

// Small elements (chips, tags)
BorderRadius.circular(8)

// Tiny elements (drag handles)
BorderRadius.circular(2-4)
```

---

## Animation Guidelines

### Timing
```dart
// Quick interactions
Duration(milliseconds: 150-200)

// Standard transitions
Duration(milliseconds: 200-300)

// Complex animations
Duration(milliseconds: 300-500)
```

### Curves
```dart
// Default ease
Curves.easeOutCubic

// Bounce effects
Curves.easeOutBack

// Smooth transitions
Curves.easeInOut
```

---

## Accessibility Requirements

1. **Contrast**: Minimum 4.5:1 for normal text, 3:1 for large text
2. **Touch targets**: Minimum 44x44 logical pixels
3. **Labels**: All interactive elements must have descriptive text
4. **Focus states**: Visible focus indicators for keyboard navigation

---

## Code Organization

### Theme Usage
Always use `AppTheme` helper methods for colors:
```dart
// CORRECT
final cardBg = AppTheme.getCardBg(context);
final textPrimary = AppTheme.getTextPrimary(context);

// INCORRECT
final cardBg = Theme.of(context).brightness == Brightness.dark
    ? darkCardBg : cardBg;  // Don't inline this logic
```

### CustomPainter Structure
Organize paint methods in logical order:
1. Background/base layers
2. Static elements (frets, markers)
3. Interactive elements (notes)
4. Overlays and highlights

```dart
void paint(Canvas canvas, Size size) {
  _drawBackground(canvas, size);
  _drawMarkers(canvas, size);
  _drawFrets(canvas, size);
  _drawStrings(canvas, size);
  _drawNotes(canvas, size);
}
```

---

## File Naming

- Components: `snake_case.dart` (e.g., `guitar_fretboard.dart`)
- Screens: `_screen.dart` suffix (e.g., `home_screen.dart`)
- Utilities: Descriptive names (e.g., `note_utils.dart`)

---

## Testing Checklist

Before submitting visual changes:
- [ ] Tested in light mode
- [ ] Tested in dark mode
- [ ] Verified on small screen (375px width)
- [ ] Verified on large screen (428px+ width)
- [ ] Checked interval colors render correctly
- [ ] Validated shadow visibility in both themes
- [ ] Confirmed text readability at all sizes
