---
name: flutter-animated-ui
description: >-
  Expert instructions and patterns for designing and engineering high-fidelity,
  state-of-the-art animated user interfaces in Flutter, including micro-interactions,
  choreographed staggered entrances, custom canvas shaders/painters, radial blooms,
  spring physics, and automotive luxury aesthetics. Use when designing, building,
  or polishing animated screens, transitions, and hero sections.
---

# Flutter Animated Best UIs Skill

## 1. Core Principles of Elite Animated UIs
- **Organic Motion Curves**: Never use standard linear curves for visible UI transitions. Always use `Curves.easeOutCubic`, `Curves.easeInOutCubic`, `Curves.easeOutBack`, or spring simulations for natural deceleration and bounce.
- **Choreographed Staggering**: Break multi-element screen entrances into sequenced intervals using `CurvedAnimation(parent: controller, curve: Interval(start, end, curve: ...))`.
- **Zero Shape Clipping Artifacts**: When implementing full-screen reveals or transitions, use smooth expanding radial circles or circular masks (`Path()..addOval(...)`) instead of shrinking rectangles or bounding boxes to eliminate jarring corner cuts.
- **Micro-Interactions on Interactive Elements**: Buttons, role selectors, and interactive cards must implement tactile feedback using `AnimatedScale`, `AnimatedContainer`, or dynamic shadow expansion on hover/tap.
- **Performance & Repaint Boundaries**: Wrap complex `CustomPainter` widgets with `RepaintBoundary` to prevent unnecessary canvas redraws during page scrolls.

## 2. Animated Entry & Exit Choreography
When a screen or hero section mounts, stagger elements sequentially:
1. **Background Atmosphere** (0.00 -> 0.40): Subtle gradient shift, glowing ambient aura, or breathing pulse.
2. **Hero Icon / Badge** (0.05 -> 0.35): Scale from 0.8 to 1.0 with `Curves.easeOutBack` and opacity fade.
3. **Typography & Value Propositions** (0.20 -> 0.55): Vertical slide up (16-24px to 0px) with alpha fade.
4. **Interactive Action Container** (0.35 -> 0.70): Smooth upward elevation slide with soft drop shadow.

## 3. Seamless Circular Canvas Reveals
To transition between splash screens and destination routes without rectangular box artifacts:
```dart
final center = Offset(size.width / 2, size.height / 2);
final maxRadius = math.sqrt(size.width * size.width + size.height * size.height) / 2 * 1.15;
final currentRadius = maxRadius * progress;
canvas.drawCircle(center, currentRadius, paint);
```
Ensure radial transitions cleanly envelope the screen using circular shockwave blooms and glowing corona rings.

## 4. Responsive Micro-Indicator Alignment
- Never let feature badges or summary chips wrap unevenly into jagged rows.
- Structure value propositions using balanced equal-width columns or fluid horizontal rows wrapped in safe constraints:
```dart
Row(
  children: [
    Expanded(child: FeatureStatCard(title: 'Fast', subtitle: 'Realtime updates')),
    const SizedBox(width: 8),
    Expanded(child: FeatureStatCard(title: 'Secure', subtitle: 'Verified garages')),
    const SizedBox(width: 8),
    Expanded(child: FeatureStatCard(title: 'Smart', subtitle: 'Live tracking')),
  ],
)
```
- Provide fixed proportions or responsive flex ratios to maintain perfect visual balance across mobile and desktop.
