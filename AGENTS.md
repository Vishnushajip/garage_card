# AGENTS.md — Permanent AI Agent Engineering & Architectural Rules

> **MANDATORY INSTRUCTION FOR ALL AI AGENTS & DEVELOPERS:**
> Every AI agent, copilot, or software engineer working on this repository must read and strictly adhere to this document before making any changes. These rules take precedence over general conventions, assumptions, and suggestions, and are enforced permanently.

---

## 0. Absolute Scope Control, Asset Safety, No Unauthorized Deployment & UI/UX Standards

### 1. Strict Scope Control — Do ONLY What Was Requested
Never modify anything outside the explicitly requested scope.
- **Change logo in sidebar:** Change ONLY the logo displayed in the sidebar. Prohibited: changing logo globally, on splash screen, auth screen, or dashboard.
- **Change application logo:** Replace only the requested logo asset or reference; preserve existing screen design and animations. Prohibited: redesigning splash screen, colors, layout, or typography.
- **Update a dashboard card:** Update ONLY that particular card. Prohibited: redesigning the whole dashboard or altering unrelated widgets.
- **Fix a button:** Fix only that button's action handler. Prohibited: rebuilding the screen, changing surrounding UI or state.
- **Modify a Flutter feature:** Work ONLY on the requested Flutter Dart files. Prohibited: running `flutter build web`, compiling APK, or deploying to Firebase.

### 2. Twelve Mandatory Scope Rules
1. **No Scope Expansion:** Never assume that a request gives permission to modify related components.
2. **No Unsolicited Redesign:** Never redesign an entire screen when a small UI modification is requested.
3. **No Unsolicited Global Style Changes:** Never change global styles or theme tokens when a local component modification is requested.
4. **No Unchecked Asset Replacement:** Never replace shared assets without verifying where they are used.
5. **Protect Splash Screen:** Never modify the splash screen unless explicitly requested.
6. **Protect Architecture & Routing:** Never change navigation, routing, authentication, API integrations, or business logic unless requested or strictly necessary for the requested task.
7. **No Extra Features:** Never add features, options, or controls that were not requested.
8. **No Over-Engineering:** Never introduce unnecessary abstractions, services, helper classes, providers, or dependencies.
9. **No Unsolicited Refactoring:** Never refactor unrelated code while implementing a requested feature.
10. **Preserve Existing Functionality:** Never remove or alter existing functionality without explicit authorization.
11. **Preserve Existing UX:** Preserve existing visual design and user experiences unless a redesign is specifically requested.
12. **Literal Interpretation:** Do not interpret a small change as permission to "improve" the entire application.

### 3. Shared Component & Asset Safety Protocol
Before modifying any shared component, logo, image, theme, or global configuration:
1. Identify the exact file.
2. Search all references across `lib/`, `web/`, and `assets/`.
3. Determine whether it is shared across multiple screens or customer/merchant roles.
4. Understand the exact visual/functional impact of changing it.
5. Modify only the required usage (localize or parameterize if needed, never blindly replace shared assets).

### 4. Absolute Prohibition on Unauthorized Building or Deployment
Never automatically:
- Run `flutter build web` or any web compilation.
- Run `flutter build apk`, `flutter build appbundle`, or any mobile compilation.
- Deploy to Firebase Hosting (`firebase deploy`) or AWS.
- Upload assets to production buckets or alter DNS/domains.
- Push commits to remote Git repositories or create commits unless instructed.
**Rule:** Perform build or deployment operations ONLY when the user explicitly requests them in their prompt. Completing code changes does NOT grant permission to build or deploy.

### 5. Professional UI/UX Quality Standards (When UI Work Is Requested)
- **Modern Aesthetics:** Clean visual hierarchy, intentional whitespace, balanced density, elegant card layouts with subtle borders (`1px`) and soft shadows (`0.04` opacity). Avoid generic AI looks, heavy drop shadows, or harsh saturated gradients.
- **Multi-Device Responsiveness (320px to 1920px+):**
  - Mobile (< 768px): Single-column, thumb-zone bottom navigation, touch targets >= 44x44.
  - Tablet (768px–1023px): Adaptive 2-column grids or split layouts.
  - Laptop & Desktop (1024px–1920px+): Persistent sidebar navigation, multi-column grids, centralized max content width `AppResponsiveLayout.kMaxProjectWidth = 960px` and form width `kMaxFormWidth = 840px`.
  - **No Stretched Buttons:** Never let action buttons stretch across wide desktop viewports; constrain primary buttons to `maxWidth: 360px–400px`.
  - **Zero Overflow Policy:** Zero `RenderFlex` overflow errors on any screen width down to 320px.
- **Typography Hierarchy:** Strict WCAG AA contrast (4.5:1), distinct headline/title/body/caption scales.
- **Consistent Color System:** Exclusively use `lib/core/colors/app_colors.dart` tokens with semantic status colors (Emerald for approved, Amber for in-progress, Crimson for rejected).
- **Micro-Interactions & Polish:** Hover effects on web/desktop, responsive ripples on mobile, `AppSkeletonLoader` for asynchronous loading (no blank pages), 60 FPS performance.
- **Design System Alignment:** Always use centralized components (`AppButton`, `AppTextField`, `AppDropdown`, `AppDialog`, `AppStatusBadge`).

### 6. Mandatory 7-Step Workflow for Every Request
1. **Understand:** Read the complete request; identify the exact requested outcome.
2. **Define Scope:** List required files, components, screens, and explicitly excluded areas.
3. **Inspect:** Read the actual source code and existing implementation before making changes.
4. **Plan:** Formulate the minimal set of edits that strictly satisfies the request.
5. **Implement:** Modify only the files strictly required; add no unrelated improvements.
6. **Verify:** Run `flutter analyze` and `flutter test` to ensure zero compilation or regression issues.
7. **Report:** State what was requested, what was changed, which files were edited, and what was intentionally left unchanged.

### 7. Non-Negotiable Summary
1. Do only what was asked.
2. Never modify unrelated files.
3. Never change shared assets without checking impact.
4. Never build or deploy automatically.
5. Create modern, responsive UI when UI work is requested.
6. Follow the 7-step process for every request.

---

## 1. Ten Core Operational Rules

### Rule 1: Understand Before Modifying
- Always read `PROJECT_CONTEXT.md` at the beginning of any session.
- Inspect the relevant existing implementation, dependencies, and business logic before changing anything.
- Never make assumptions about existing functionality. Verify by reading the actual source code, models, and providers.

### Rule 2: Architecture & Clean Layering
- Strictly follow the established 4-tier Feature-Based MVVM architecture:
  ```text
  features/<feature_name>/
  ├── View/       # Pure presentation, layout, user event forwarding
  ├── ViewModel/  # Riverpod Notifiers/AsyncNotifiers, logic, validation, state mutations
  ├── Model/      # Strongly-typed immutable state and domain models
  └── Widgets/    # Reusable dumb presentational components
  ```
- Maintain strict separation of concerns:
  - **Zero Firebase in UI:** No Firestore queries, Auth calls, Cloud Functions, or Storage calls in `View` or `Widgets` layers. All interactions must be mediated by ViewModels and repositories.
  - **No `setState` for Application State:** `setState` is strictly forbidden for application logic or cross-component state. Ephemeral animation controller state in isolated widgets is the only acceptable edge case.
  - **Single Repository Source:** Business logic coordinates through `GarageRepository` and specialized services.
  - Riverpod is the sole state management library.

### Rule 3: Customer and Merchant Separation
- Maintain complete, unambiguous separation between Customer (`/customer`) and Merchant (`/merchant`) routes and data.
- Never expose merchant-only operational data (mechanic costs, profit margins, global revenue) to customers.
- Account switching requires explicit user confirmation via `AccountSwitcherListView` in the Profile section.

### Rule 4: Backend Integration & Data Integrity
- Connect all functional UI elements to the authentic backend (Cloud Firestore, Cloud Functions, Firebase Auth).
- Never display hardcoded mock data in production user flows. When collections are empty, render an authentic empty state with a call-to-action.
- Implement robust error handling (`AppException.fromFirebase`) and prevent duplicate form submissions with disabled/loading states.

### Rule 5: Mandatory Multi-Device Responsiveness
- Every screen, sheet, and dialog must adapt cleanly across Mobile (< 768px), Tablet (768px–1023px), and Laptop/Desktop (1024px+).
- Enforce `AppResponsiveLayout.kMaxProjectWidth = 960px` and `kMaxFormWidth = 840px` on desktop. Zero `RenderFlex` overflows down to 320px.

### Rule 6: State Management & Reactive UI
- Riverpod Notifiers must maintain immutable state objects using `.copyWith(...)`.
- State must explicitly represent all phases: initial loading, active data, empty state, error state, and background pagination.

### Rule 7: Security & Least Privilege
- Enforce authentication on private collections (`request.auth != null`). Validate data models before committing to Firestore.
- Customer updates to estimates are restricted strictly to status transition keys (`status`, `rejectionReason`, `approvedAt`).
- Never commit private keys, secrets, or tokens to Git.

### Rule 8: UI/UX & Automotive Design System
- Strictly adhere to Automotive Luxury Visual Identity: Deep Slate neutrals, Electric Cobalt and Racing Amber accents.
- Centralized form controls: `AppTextField`, `AppDropdown`, `AppButton`, `AppDialog`, `AppStatusBadge`.

### Rule 9: Performance & Proactive Cursor Pagination
- Unbounded collections must use Firestore cursor-based pagination with `ProactiveScrollListener` at 75% scroll depth.
- Always cancel stream subscriptions in Riverpod `ref.onDispose(...)`.
- Compress and validate uploaded images (< 5MB) via `ImageUploadService`.

### Rule 10: Development Discipline & Code Integrity
- **STRICT NO CODE COMMENTS POLICY IN DART FILES:**
  - Do NOT add inline comments (`//`), block comments (`/* ... */`), or docstrings (`///`) to any Dart source code files under `lib/` and `test/`.
  - Code must be completely self-documenting through expressive naming, single-responsibility functions, and strong typing.
  - All architectural decisions and specifications must reside in Markdown files in the project root.
- **Verification Gates:** Before declaring any task complete, you must execute and pass:
  1. `dart format --output=none --set-exit-if-changed .`
  2. `flutter analyze` (Must report 0 issues).
  3. `flutter test` (All unit, model, and widget tests must pass).
- Do not break existing working functionality. Do not delete existing features without explicit user authorization.

---

## 2. Multi-Tenant SaaS Data Isolation & Security Rules

### Rule 11: Absolute Tenant Boundary & Zero Cross-Tenant Leakage
1. **Default Deny Policy:** Access to all private collections, documents, subcollections, and APIs is denied by default unless authenticated ownership or membership is validated.
2. **Merchant Data Isolation:** Every merchant may access and manage ONLY data scoped to their authorized garage (`request.auth.uid in get(/databases/$(database)/documents/garages/$(garageId)).data.memberUids`).
3. **Customer Data Isolation:** Customers may access only their own private records (`users/{uid}/vehicles`, `customerId == request.auth.uid`). Discovering a garage grants access only to public catalog info.
4. **Un-scoped Query Prohibition:** Frontend repositories (`GarageRepository`) must NEVER execute global un-scoped queries. If neither `garageId` nor `customerId`/`userEmail` is provided, queries must return empty collections or `PaginatedResult.empty()`.
5. **Session Cache Clearance:** Logging out or switching accounts must immediately purge all in-memory repository caches (`_notifications`, `_conversations`, `_messages`).

---

## 3. Database-First Data & Location Engineering Rules

### Rule 12: DATABASE-FIRST DATA RULE — MANDATORY
1. **Zero Fake/Local Dummy Data Fallbacks:** Never embed hardcoded mock items or return fake fallback lists when Firestore collections return empty. The UI must render authentic empty state views with clear calls-to-action.
2. **Dynamic Service Catalog Architecture:** Services are dynamically persisted under subcollection `garages/{garageId}/services/{serviceId}` supporting `fixed`, `range`, `vehicle_specific`, and `contact` pricing evaluated via `SmartPricingEngine`.
3. **Zero-Cost Geocoding & Open Maps Integration (No Google Maps API):** Garages store coordinates and Google Maps URLs without paid Google Maps APIs. Coordinates use regex patterns and free OpenStreetMap Nominatim forward geocoding.

---

## 4. Global UI States, Loading, Empty States & Error Handling

### Rule 13: GLOBAL UI STATE MANAGEMENT RULE — MANDATORY
1. **Mandatory UI States:** Every data-driven screen must implement: Initial, Loading (skeleton loaders preferred), Success, Empty (role-specific with CTA), Search Not Found (`AppSearchEmptyState`), Error (`AppErrorState` with retry), Offline (`AppOfflineState`), and Permission Denied (`AppPermissionState`).
2. **Invariant Rules & Anti-Patterns:**
   - Never leave a page blank or indefinitely loading.
   - Never use fake records as a substitute for empty data.
   - Never show a search-empty state when the actual issue is a backend failure.
   - Prevent duplicate submissions: Always disable buttons or display loading overlays during async mutations.
3. **Standardized Reusable State Components (`lib/core/shared_widgets/`):**
   - `AppLoadingState`, `AppSkeletonLoader`, `AppEmptyState`, `AppSearchEmptyState`, `AppErrorState`, `AppOfflineState`, `AppPermissionState`, `AppUnauthorizedState`, `AppRetryButton`, `AppLoadingOverlay`.

---

## 5. Mandatory Feature-First MVVM Architecture with Riverpod & File Decomposition

### Rule 14: Permanent Feature-First MVVM Architecture Standard
1. **Feature-First Folder Structure:** `lib/features/<feature_name>/{views,view_models,models,widgets,repositories}`.
2. **View Rules:** Pure presentation only. Zero direct Firestore/API calls, zero business logic, zero state-changing mutations.
3. **ViewModel Rules:** Coordinate API/Firestore calls, manage form/filter/search state, handle loading/error mappings.
4. **Separate ViewModels:** Split ViewModels by logical responsibility into small, focused files.
5. **Repository Rules:** Handle data persistence, document operations, and error mapping to `AppException`.
6. **Model Rules:** Strongly-typed immutable models with `copyWith`, `toMap`, and `fromFirestore`. Zero UI or API logic in models.
7. **Widget Rules:** Feature-specific presentational components residing in `features/<feature>/widgets/`.
8. **Core Boundary:** Only genuinely reusable cross-feature components belong in `lib/core/`.
9. **Riverpod Standards:** `AsyncNotifierProvider` for async state, `NotifierProvider` for synchronous state.
10. **STRICT RULE: NO MASSIVE SOURCE FILES:** Files approaching 300–400 lines must be reviewed and decomposed into smaller single-responsibility components.

---

## 6. Centralized Systems: Images, Feedback, Notifications & Localization

### Rule 15: Centralized Image Optimization & Upload
- All image uploads must exclusively use `ImageUploadService` (`lib/core/services/image_upload_service.dart`).
- Automated processing: EXIF auto-orientation, metadata stripping, transparent PNG / JPEG quality downscaling (profiles: `thumbnail` 300x300, `card` 800x800, `standard` 1200x1200, `large` 1920x1920).
- Network images must be rendered with `AppCachedImage`.

### Rule 16: Centralized Application Feedback & Notifications
- **Absolute Prohibition of Default SnackBar:** Never use `ScaffoldMessenger.of(context).showSnackBar(...)` or `SnackBar`.
- All temporary notifications must use `AppNotificationService` (`AppNotificationService.success()`, `.error()`, `.warning()`, `.info()`, `.loading()`).
- Responsive floating banner hosted via `AppNotificationHost` at root level.

### Rule 17: Application Localization (English & Malayalam) — MANDATORY FOR ALL NEW FEATURES
- **Mandatory Bilingual Support for All New Features & Adding Options:** Every new feature, adding option, screen, dialog, bottom sheet, action button, form field label, hint/placeholder, dropdown choice, validation error message, empty state, and notification MUST fully support dynamic English (`en`) and Malayalam (`ml`) language switching.
- **Single Localization Registry:** All new strings must be added to both `en` and `ml` maps in `AppLocalizations` (`lib/core/localization/app_localizations.dart`), with lower-cased lookup mappings registered in `_phraseToKeyMap`.
- **Dynamic Language Switching via `localeProvider`:** Dynamic switching between English (`en`) and Malayalam (`ml`) occurs via `localeProvider` without app restart. Every widget presenting localized text must watch `ref.watch(localeProvider)` in its `build` method so translations react immediately upon language change.
- **Zero Hardcoded User-Facing Strings:** Never hardcode raw English or Malayalam text directly inside UI widgets or alerts. All static UI strings must be resolved via `context.tr(key)` / `AppLocalizations`. Preserve business and user-entered data (names, license plates, notes).
- **Status Normalization:** Map normalized status codes through `loc.status(code)` for culturally appropriate Malayalam terms.
- **WhatsApp Bilingual Engine:** All customer notifications generated from new features (e.g. Job Created, Extra Work Added, Work Completed, Invoice Sharing) must offer a language selector (`English` / `മലയാളം`) and render entirely in the selected language without mixing.

### Rule 18: Technical SEO & Platform Separation
- Maintain `sitemap.xml` and `robots.txt` at web root.
- Keep web-specific SEO separate from shared Android code. Never index private or authenticated user routes.

### Rule 19: Dedicated Full Pages for Core Workflows & Multi-Device Responsive Standards
- **Primary Workflows as Full Pages:** Complex operations such as creating new service jobs (`MerchantCreateJobScreen`) or completing jobs with billing and settlements (`MerchantCompleteJobScreen`) must be dedicated full pages with proper `AppCustomAppBar` and canonical routes, never crammed inside modal `AlertDialog`s.
- **Adaptive Multi-Device Responsiveness (Mobile & Tablet):** Every newly created page, dialog, bottom sheet, and form must be fully responsive down to 320px viewport width with zero `RenderFlex` overflow errors. Dynamic layouts must use `LayoutBuilder` or `Wrap` on narrow widths. Total horizontal margins on mobile viewports must remain clean and consistent (16px) without double padding.

### Rule 20: WebAssembly (Wasm) Web Compatibility Standard (`flutter build web --wasm --release`)
- **Zero Legacy Web Imports:** Never import `dart:html`, `dart:js`, or `package:js`. All web browser interactions, DOM bindings, and JavaScript interoperability must exclusively use `dart:js_interop` and `package:web`.
- **Wasm-Compatible Conditional Imports:** All conditional platform imports must check `if (dart.library.js_interop)` rather than legacy `if (dart.library.html)`.
- **Wasm Asset & Security Headers in `firebase.json`:**
  - All `.wasm` files must be served with `Content-Type: application/wasm` and long-term caching (`max-age=31536000, immutable`).
  - Use `Cross-Origin-Opener-Policy: same-origin-allow-popups` on global routes (`**`) so that OAuth authentication (Google Sign-In via `signInWithPopup`) operates smoothly without having the popup opener communication blocked by the browser.
  - Never impose strict `COOP: same-origin` or global `COEP: credentialless` on public web apps using third-party OAuth/Firebase Auth if the auth domain (`*.firebaseapp.com`) differs from the custom hosting domain (`app-wefix.web.app`), as this severs cross-window auth communication and traps users on loading screens.
- **Defensive HTML Splash Recovery:** The web entry point (`web/index.html`) must dismiss the pre-Flutter HTML splash screen via `flutter-first-frame` with a maximum 3.5s timeout fallback so users are never trapped on a permanent blank splash.
- **Modern Bootstrapping:** The web entry point (`web/index.html`) must use `flutter_bootstrap.js` so modern browsers run `main.dart.wasm` with native WasmGC speed while older environments automatically fall back to JavaScript without breaking.
