# Mandatory Responsive Full Pages & Multi-Device Adaptive Modals Rule

> **MANDATORY INSTRUCTION FOR ALL AI AGENTS & DEVELOPERS:**
> Every newly added page, modal, alert dialog, bottom sheet, and form in this application MUST be fully multi-device responsive across Mobile (< 768px), Tablet (768px–1023px), and Desktop/Laptop (1024px+). Complex operational workflows MUST be dedicated full pages rather than alert dialogs. Zero `RenderFlex` overflow errors down to 320px viewport width is strictly enforced.

---

## 1. Primary Workflows Must Be Dedicated Full Pages

1. **Complex Workflows Require Dedicated Full Pages:**
   - Operational workflows involving multiple form fields, dynamic calculations, line items, or multi-step logic (e.g. Creating a New Job, Completing a Job & Generating Bill, Invoice Settlement) MUST be implemented as dedicated full-screen `Scaffold` pages.
   - Prohibited: Cramming multi-field forms, line-item tables, or billing calculations into modal `AlertDialog`s.

2. **Full Page Structure & Routing:**
   - Must use `AppCustomAppBar` with localized `title` and descriptive `subtitle`.
   - Must register canonical routes in `RoutePaths` (`lib/core/routing/route_paths.dart`) and `app_router.dart`.
   - Content forms must be constrained to `AppResponsiveLayout.kMaxFormWidth` (840px) on desktop viewports and scrollable via `ListView` or `SingleChildScrollView`.

---

## 2. Multi-Device Responsiveness Across All Form Factors

1. **Viewport Form Factors:**
   - **Mobile (< 768px):** Single-column layouts, full-width touch targets (minimum 44x44px), scrollable containers with automatic keyboard padding.
   - **Tablet (768px–1023px):** Adaptive 2-column or split layouts where appropriate.
   - **Desktop (1024px+):** Centered max content width (`AppResponsiveLayout.kMaxProjectWidth = 960px`, `kMaxFormWidth = 840px`), constrained button widths (`maxWidth: 360px–400px`).

2. **Zero Overflow Policy (Down to 320px):**
   - No `RenderFlex` horizontal or vertical overflow errors are permitted on any screen width down to 320px.
   - Avoid rigid `Row` layouts where child titles, tags, and action buttons fight for space. Use `LayoutBuilder` to stack items on narrow mobile screens (< 360px) and wrap text with `Expanded` + `overflow: TextOverflow.ellipsis`.

3. **Gutter & Padding Harmony:**
   - Avoid double horizontal padding on mobile. If a child widget applies 16px horizontal margins or padding, wrap with `AppResponsiveLayout(padding: EdgeInsets.zero, ...)`. Total horizontal gutter on mobile viewports must remain consistent (16px).

---

## 3. Modal Dialog & Bottom Sheet Standards

1. **When Modals & Sheets Are Permitted:**
   - Alert dialogs and bottom sheets are reserved strictly for concise, single-purpose interactions: quick confirmations, simple single-input entries, customer selection, mechanic assignment, or WhatsApp message dispatch.
2. **Sheet Constraints:**
   - All bottom sheets must wrap contents in `SafeArea`, support keyboard inset awareness (`MediaQuery.of(context).viewInsets.bottom`), and limit max height on mobile to `0.85 * MediaQuery.of(context).size.height`.

