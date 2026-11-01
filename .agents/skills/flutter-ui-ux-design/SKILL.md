---
name: flutter-ui-ux-design
description: >-
  Expert instructions and patterns for designing and engineering professional,
  modern, multi-device responsive user interfaces in Flutter. Covers layout
  composition, design tokens, typography, card architecture, responsive button
  constraints, Riverpod MVVM integration, and zero-overflow handling across
  mobile, tablet, desktop, and ultra-wide viewports.
---

# Flutter UI/UX & Responsive Design System Skill

Use this skill whenever the user explicitly requests UI design, screen creation, screen refinement, visual polish, or responsive layout fixes.

---

## 1. Core Principles of Elite Flutter UI/UX

1. **Intentional Hierarchy**: Every screen must have a clear visual anchor (primary card, summary hero, or active action), followed by secondary context and supporting metadata.
2. **Balanced Density**: Generous breathing room without wasted space. Use consistent 8px/16px/24px grid spacing.
3. **Card & Surface Architecture**:
   - Backgrounds: Clean surfaces (`AppColors.cardBackground` or pure white `#FFFFFF` on light backgrounds).
   - Borders: Refined 1px outline (`AppColors.border` or `#E2E8F0`).
   - Shadows: Subtle, soft elevation:
     ```dart
     BoxShadow(
       color: Colors.black.withOpacity(0.04),
       blurRadius: 12,
       offset: const Offset(0, 4),
     )
     ```
   - Corner Radius: 12px–16px for cards, 8px for input fields, 24px–28px for action pills.
4. **Automotive Luxury Palette**:
   - Primary: Deep Slate / Midnight Indigo (`AppColors.primary`, `AppColors.primaryDark`).
   - Accents: Electric Cobalt (`#2563EB`) and Racing Amber (`#D97706`).
   - Semantics: Emerald for approved/active, Amber for pending/in-progress, Crimson for rejected/errors.

---

## 2. Multi-Device Responsive Architecture

### Viewport Breakpoints
- **Mobile (< 768px)**: Single column flow, thumb-zone bottom navigation, touch targets >= 44x44.
- **Tablet (768px - 1023px)**: 2-column grid, adaptive side rail, master-detail presentation.
- **Laptop & Desktop (1024px - 1920px+)**: Multi-column grids, sidebar navigation, centralized maximum content width limitation.

### Desktop Max-Width & Button Width Constraints (CRITICAL)
Never let action buttons or simple forms stretch across wide desktop viewports (e.g. 1200px - 1920px):
```dart
Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(
      maxWidth: AppResponsiveLayout.kMaxProjectWidth, // 960px
    ),
    child: content,
  ),
)
```

For primary action buttons:
```dart
Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(
      maxWidth: 400, // Prevent ultra-wide button stretching on desktop
    ),
    child: SizedBox(
      width: double.infinity,
      child: AppButton(
        text: 'View Packages & Book Service',
        onPressed: () {},
      ),
    ),
  ),
)
```

---

## 3. Zero-Overflow Engineering Standards

1. **Text Constraints**: Never place unbounded `Text` widgets inside a `Row`. Always wrap with `Expanded` or `Flexible` with `overflow: TextOverflow.ellipsis`.
2. **Dynamic Badges & Tags**: When rendering variable-length tags, chips, or badge rows, use `Wrap` with `spacing: 8` and `runSpacing: 8` instead of a horizontal `Row` that can overflow on narrow mobile screens (320px–360px).
3. **Adaptive Grids**: Use `LayoutBuilder` to compute crossAxisCount dynamically:
   ```dart
   LayoutBuilder(
     builder: (context, constraints) {
       final crossAxisCount = constraints.maxWidth > 900
           ? 3
           : constraints.maxWidth > 600
               ? 2
               : 1;
       return GridView.builder(...);
     },
   )
   ```

---

## 4. Typography Scale & Readability

Always maintain clear font contrast (minimum WCAG AA 4.5:1 ratio):
- **Page Titles**: 20px–24px, FontWeight.bold, `AppColors.textPrimary`.
- **Section Headers**: 16px–18px, FontWeight.w600, `AppColors.textPrimary`.
- **Body Text**: 14px–15px, FontWeight.normal, `AppColors.textSecondary`.
- **Badges & Micro-Labels**: 11px–12px, FontWeight.w600, uppercase letter-spacing.

---

## 5. Design System Alignment & Widget Decomposition

1. **Centralized Components**: Always use project design system primitives (`AppButton`, `AppTextField`, `AppDropdown`, `AppDialog`, `AppStatusBadge`, `AppSkeletonLoader`).
2. **File Size & Decomposition**: Keep UI files under 300–400 lines by breaking complex screens into cohesive widgets placed in `features/<feature>/widgets/`.
3. **MVVM Boundary**: The UI widget layer renders data from Riverpod and delegates user gestures to ViewModels. Zero Firestore queries, direct API calls, or business logic in views.

