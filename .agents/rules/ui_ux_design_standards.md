# Professional UI/UX & Responsive Design Standards

> **MANDATORY INSTRUCTION FOR ALL AI AGENTS & DEVELOPERS:**
> When UI design, screen creation, or visual refinement is explicitly requested, you must act as a Senior UI/UX Designer and Frontend Architect adhering to these standards.

---

## 1. Modern Aesthetics & Visual Hierarchy
- **Visual Balance:** Clean, uncluttered layouts with intentional whitespace and balanced information density.
- **Card Architecture:** Subtle, elegant card elevations (`BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4))`), delicate 1px borders (`Colors.grey.shade200` or theme outline), and rounded corners (typically 12px–16px).
- **Prohibited Aesthetics:** Never generate generic, flat, low-effort AI layouts. Avoid heavy, muddy drop shadows, saturated full-screen gradient backgrounds, or clashing vibrant accents.
- **Automotive Luxury Theme:** Deep slate/midnight indigo neutrals (`#0F172A`, `#1E293B`), electric cobalt accents (`#2563EB`), racing amber accents (`#D97706`), and crystal-clear emerald badges for approved states.

---

## 2. Mandatory Multi-Device Responsiveness (320px to 1920px+)
Every layout must adapt seamlessly across screen sizes:

### Breakpoint Matrix
- **Mobile (< 768px):**
  - Single-column flow with thumb-friendly bottom sheets and bottom navigation bars.
  - Padding: 16px horizontal margins.
  - Full-width tap targets with minimum 44x44 touch targets.
- **Tablet (768px – 1023px):**
  - Adaptive 2-column grids or master-detail split views.
  - Side navigation rail or collapsible drawer.
  - Padding: 20px–24px margins.
- **Laptop & Desktop (1024px – 1920px+):**
  - Persistent left sidebar navigation and structured multi-column dashboard grids.
  - **Maximum Content Width Constraints:** Centralized max width `AppResponsiveLayout.kMaxProjectWidth = 960px` and form width `kMaxFormWidth = 840px`.
  - **No Stretched UI:** Never stretch action buttons, single input fields, or single cards across wide desktop screens (e.g. 1400px+). Buttons must have intrinsic, sensible max-widths (`max-width: 320px-400px` or centered action rows) or fit within constrained container widths.
  - Padding: 24px–32px content margins.

### Zero Overflow Policy
- Zero `RenderFlex` overflow errors (horizontal or vertical) on any screen down to 320px width.
- Wrap dynamic horizontal content in `Expanded`, `Flexible`, or `Wrap`.
- Wrap label-value rows with `TextOverflow.ellipsis` or responsive wrapping.
- Use `LayoutBuilder` or `MediaQuery` to switch column counts rather than hardcoding fixed element widths.

---

## 3. Typography & Information Hierarchy
- **Contrast Ratios:** Ensure WCAG AA accessibility compliance (minimum 4.5:1 for standard body text, 3:1 for large headlines).
- **Type Scale:**
  - Screen Titles / Page Headlines: Bold, 20px–24px.
  - Section Headers / Card Titles: Semi-Bold, 16px–18px.
  - Body Text / Key Descriptions: Regular/Medium, 14px–15px (`AppColors.textSecondary` or `#475569`).
  - Captions / Metadata / Badges: Medium/Bold, 11px–12px with uppercase letter spacing for status tags.
- **Hierarchy:** Always provide immediate visual priority to the primary state, title, and action before secondary metadata.

---

## 4. Consistent Color System
- Always utilize tokens from `lib/core/colors/app_colors.dart` (e.g. `AppColors.primary`, `AppColors.primaryDark`, `AppColors.accentAmber`, `AppColors.cardBackground`, `AppColors.border`).
- **Semantic Status Palette:**
  - Success / Approved / Completed: Emerald Green (`#10B981` / `#059669`).
  - In Progress / Pending: Amber / Honey Gold (`#F59E0B` / `#D97706`).
  - Rejected / Cancelled / Error: Crimson / Cherry Red (`#EF4444` / `#DC2626`).
  - Draft / Archived: Slate Muted Grey (`#64748B`).
- Avoid arbitrary hardcoded color hex values inside view files.

---

## 5. Micro-Interactions, Feedback & Motion
- **Desktop/Web Hover States:** Add subtle hover effects (`onHover`, animated elevation, or highlight tint) to cards, list items, and clickable tiles.
- **Touch Feedback:** Use `InkWell` / `AppButton` with responsive ripples on mobile.
- **Loading States:** Use `AppSkeletonLoader` with shimmering placeholders matching card shapes instead of jarring blank screens or sudden layout jumps.
- **Performance:** Ensure all animations run at 60 FPS without jank. Support `MediaQuery.of(context).disableAnimations` / reduced motion.

---

## 6. Design System Alignment & Component Reusability
- Never use unstyled raw `TextFormField`, raw default Flutter `DropdownButton`, or unstyled `ElevatedButton`.
- Always use centralized design system widgets:
  - `AppTextField`
  - `AppDropdown<T>` / `AppSearchableDropdown<T>`
  - `AppButton` (styled pills with icon support, loading indicators, and tactile feedback)
  - `AppDialog`
  - `AppStatusBadge`
- Maintain consistent border radiuses (12px for cards, 8px for inputs, 24px–28px for pill buttons) across all screens.

---

## 7. Riverpod MVVM Architecture Integration
- **Zero Business Logic in UI:** Views and widgets are purely presentational. They receive data from Riverpod providers and forward user events to ViewModels.
- **No `setState` for Application State:** All application, filter, search, and form state lives in Riverpod Notifiers.
- **Component Decomposition:** Decompose complex screens into small, maintainable widget files under `widgets/` (each under ~300 lines).

