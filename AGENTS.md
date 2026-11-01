# AGENTS.md — Permanent AI Agent Engineering & Architectural Rules

> **MANDATORY INSTRUCTION FOR ALL AI AGENTS & DEVELOPERS:**
> Every AI agent, copilot, or software engineer working on this repository must read and strictly adhere to this document before making any changes. These rules take precedence over general conventions and are enforced permanently.

---

## 1. Ten Core Operational Rules

### Rule 1: Understand Before Modifying
- Always read `PROJECT_CONTEXT.md` at the beginning of any session.
- Inspect the relevant existing implementation, dependencies, and business logic before changing anything.
- Never make assumptions about existing functionality. Verify by reading the actual source code, models, and providers.
- When an issue or bug is reported, inspect the entire chain (UI -> ViewModel -> Repository -> Firestore/Backend -> Routing) to diagnose the root cause rather than patching surface symptoms.

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
  - **Zero Firebase in UI:** No Firestore queries, Auth calls, Cloud Functions, or Storage calls may exist in `View` or `Widgets` layers. All interactions must be mediated by ViewModels and repositories.
  - **No `setState` for Application State:** `setState` is strictly forbidden for application logic or cross-component state. Ephemeral animation controller state in isolated widgets is the only acceptable edge case.
  - **Single Repository Source:** Business logic coordinates through `GarageRepository` and specialized services (`FcmNotificationSender`, `PdfGeneratorService`, `WhatsAppShareService`).
  - Do not introduce another state management library (Bloc, Provider, GetX, MobX). Riverpod is the sole state management library.

### Rule 3: Customer and Merchant Separation
- Maintain complete, unambiguous separation between the **Customer** and **Merchant** user experiences:
  - **Customer Experience:** Lives under `/customer` routes. Focuses on garage discovery, service packages, repair tracking, invoices, service reminders, and messaging.
  - **Merchant Experience:** Lives under `/merchant` routes. Focuses on garage profile, job cards, digital inspections, estimate creation, invoice issuance, manual payments, and business analytics.
- **Data Protection:**
  - Never expose merchant-only operational data (mechanic costs, profit margins, other customer records, global garage revenue) to customers.
  - Never expose customer-private data to unrelated merchants.
  - Enforce tenant boundary checks: `request.auth.uid in get(/databases/$(database)/documents/garages/$(garageId)).data.memberUids`.
- **Account Switching:**
  - Facilitated exclusively through explicit selection in the **Profile** section via `AccountSwitcherListView`.
  - Switching must never trigger automatically upon opening the switcher; it requires an intentional user confirmation.

### Rule 4: Backend Integration & Data Integrity
- Connect all functional UI elements to the authentic backend (Cloud Firestore, Cloud Functions, and Firebase Auth).
- Never display hardcoded, placeholder, or fabricated garage or customer information in production or main user flows.
- If a customer or merchant record has no associated data, render an informative, beautifully designed empty state with an explicit call-to-action (e.g., complete profile, add first job).
- Implement robust error handling (`AppException.fromFirebase`) and graceful network retry mechanisms.
- Prevent duplicate form submissions by using disabled states or loading indicators during network mutations.

### Rule 5: Mandatory Multi-Device Responsiveness
- Every screen, layout, dialog, sheet, and widget must adapt flawlessly across:
  - **Mobile:** `< 768px` (single-column layouts, thumb-zone bottom navigation, responsive bottom sheets).
  - **Tablet:** `768px - 1023px` (adaptive 2-column grids, master-detail split views, side navigation rails).
  - **Laptop & Desktop:** `1024px+` (3-column responsive grids, full desktop sidebars, maximum width constraints `1200px`).
- **Zero Overflow Policy:** Under no circumstance may any widget produce a `RenderFlex` overflow (horizontal or vertical) on any screen width down to 320px. Use `Flexible`, `Expanded`, `LayoutBuilder`, and intrinsic row chunking where appropriate.

### Rule 6: State Management & Reactive UI
- Riverpod Notifiers must maintain immutable state objects using `.copyWith(...)`.
- Avoid synchronous state mutations or reading uninitialized state inside `build()`; schedule async side-effects via `Future.microtask(...)`.
- State must explicitly represent all phases of asynchronous operations:
  - Initial loading (`isLoading: true`).
  - Active data state (`items: [...]`).
  - Empty state (`items.isEmpty`).
  - Error state (`errorMessage != null`).
  - Background pagination (`isFetchingNextPage: true`).
- Prevent indefinite loading spinners by enforcing timeouts on network requests.

### Rule 7: Security & Least Privilege
- Enforce authentication on all private collections (`request.auth != null`).
- Validate data models before committing to Firestore: enforce required fields, string lengths, and numeric ranges.
- Customer updates to estimates must be restricted to status transition keys (`status`, `rejectionReason`, `approvedAt`) via Firestore Security Rules.
- Never commit private keys, API secrets, service account credentials, or auth tokens to Git. Use environment configurations or secure cloud backends.

### Rule 8: UI/UX & Automotive Design System
- Strictly adhere to the **Automotive Luxury Visual Identity**:
  - **Primary Colors:** Deep Slate / Midnight Indigo (`#0F172A`, `#1E293B`).
  - **Brand Accent:** Electric Cobalt (`#2563EB`) and Racing Amber (`#D97706`).
  - **Semantic Status Colors:** Emerald Green (Completed/Approved), Amber (In Progress/Pending), Crimson Rose (Rejected/Overdue), Slate (Draft).
- **Centralized Form Controls:** Never use raw, unstyled `TextFormField` or default Flutter dropdowns. Always use centralized components:
  - `AppTextField`
  - `AppDropdown<T>` / `AppSearchableDropdown<T>`
  - `AppButton`
  - `AppDialog`
  - `AppStatusBadge`
- Action buttons must be modern, styled pills with icons and micro-interactions rather than plain, unstyled buttons.

### Rule 9: Performance & Proactive Cursor Pagination
- Unbounded collections (jobs, invoices, estimates, notifications, customers, reviews) must use Firestore cursor-based pagination:
  - Initial page: `.orderBy(...).limit(pageSize)`.
  - Next page: `.startAfterDocument(lastDocSnapshot)`.
- Use `ProactiveScrollListener` to trigger pre-fetching when the user reaches 75% scroll depth, ensuring seamless infinite scrolling without lag.
- Always cancel stream subscriptions (`StreamSubscription.cancel()`) in Riverpod `ref.onDispose(...)` to prevent memory leaks.
- Compress and validate uploaded images (< 5MB) before transmission to Firebase Storage.

### Rule 10: Development Discipline & Code Integrity
- **STRICT NO CODE COMMENTS POLICY IN DART FILES:**
  - Do NOT add inline comments (`//`), block comments (`/* ... */`), or docstrings (`///`) to any Dart source code files under `lib/` and `test/`.
  - Code must be completely self-documenting through expressive naming, single-responsibility functions, and strong typing.
  - All architectural decisions, schemas, workflows, and specifications must reside in Markdown files in the project root.
- **Verification Gates:** Before declaring any task complete, you must execute and pass:
  1. `dart format --output=none --set-exit-if-changed .`
  2. `flutter analyze` (Must report 0 issues).
  3. `flutter test` (All unit, model, and widget tests must pass).
- Do not break existing working functionality. Do not delete existing features without explicit user authorization.

---

## 2. Notification & Messaging Rules

1. **Dual Notification Dispatch:**
   - Every service request, booking, estimate decision, and status transition must dispatch both:
     1. Persistent in-app notification to `users/{recipientUid}/notifications/{id}`.
     2. High-priority push notification to all active device FCM tokens.
2. **Device Token Management:**
   - User device tokens are stored in an array (`fcmTokens`) on `users/{uid}`, capped at the most recent 4 devices.
3. **Uninterrupted Background Dispatch:**
   - Push notifications must be sent via `FcmNotificationSender` using `unawaited(...)` background HTTP calls so the UI never stutters or freezes.
4. **OLX-Style Inquiry Chat Standard:**
   - When a customer inquires about a package or garage, the system automatically checks/prompts for the customer's phone number.
   - A conversation is created with `customerPhone` and `garagePhone`.
   - The opening message includes the customer's phone number.
   - The merchant's notification payload includes `customerPhone` and a deep link `/chat/{convId}?name=...&phone=...`.
   - Tapping opens the chat with prominent one-tap **Call** and **WhatsApp** action buttons.


---

## 3. Multi-Tenant SaaS Data Isolation & Security Rules

### Rule 11: Absolute Tenant Boundary & Zero Cross-Tenant Leakage
1. **Default Deny Policy:**
   - Access to all private collections, documents, subcollections, and APIs is denied by default unless an explicit authenticated ownership, garage membership, or authorized counterparty relationship is cryptographically or rule-validated.
2. **Merchant Data Isolation:**
   - Every merchant may access, view, and manage ONLY data scoped to their authorized garage (`request.auth.uid in get(/databases/$(database)/documents/garages/$(garageId)).data.memberUids`).
   - Under no circumstance may Merchant A view or query Merchant B's jobs, invoices, estimates, customers, mechanics, analytics, or messages.
3. **Customer Data Isolation:**
   - Customers may access only their own private records (`users/{uid}/vehicles`, `customerId == request.auth.uid`, `recipientUid == request.auth.uid`).
   - Discovering a garage grants access only to public catalog info (services, public profile, verified badge). It never grants access to that garage's internal customer lists, mechanic rosters, or other customers' repair orders.
4. **Un-scoped Query Prohibition:**
   - Frontend repositories (`GarageRepository`) must NEVER execute global un-scoped queries (e.g., `collectionGroup` without tenant ID or customer ID). If neither `garageId` nor `customerId`/`userEmail` is provided, queries must immediately return empty collections `[]` or `PaginatedResult.empty()`.
5. **Firestore Security Hardening:**
   - `users/{userId}` documents are strictly restricted to `request.auth.uid == userId` to prevent scraping of phone numbers, emails, and device FCM tokens.
   - Estimate status updates by customers are strictly limited to decision keys (`status`, `rejectionReason`, `approvedAt`); customers cannot manipulate line items, pricing, or tax calculations.
   - Garage creation requires `request.resource.data.ownerUid == request.auth.uid`; updates cannot alter `ownerUid`; only the garage owner can delete the garage.
6. **Cloud Function & API Authorization:**
   - Serverless triggers and callable HTTP endpoints must authenticate the caller and verify that the caller is an active member/owner of the target garage or a verified customer counterparty before modifying data or dispatching push notifications.
7. **Session Cache Clearance:**
   - Logging out or switching accounts must immediately purge all in-memory repository caches (`_notifications`, `_conversations`, `_messages`) and session storage to prevent stale tenant data leakage across sessions.

---

## 4. Database-First Data & Location Engineering Rules

### Rule 12: DATABASE-FIRST DATA RULE — MANDATORY
1. **Zero Fake/Local Dummy Data Fallbacks:**
   - Never embed hardcoded mock items or return fake fallback lists when Firestore collections return empty.
   - If a Firestore query returns no records, repositories must return an empty list (`[]`) or `PaginatedResult.empty()`.
   - The UI must render authentic empty state views with clear calls-to-action (e.g. "Add your first service", "No garages found").
   - Foundational seed data must be saved directly into Cloud Firestore (`garages` and subcollection `garages/{garageId}/services`) via `GarageRepository.seedInitialFirestoreDataIfNeeded()`.

2. **Dynamic Service Catalog Architecture:**
   - Services are dynamically persisted under subcollection `garages/{garageId}/services/{serviceId}`.
   - Pricing models must support:
     - `fixed`: Single fixed price for all compatible vehicles.
     - `range`: Minimum and maximum price bounds (`minPrice`, `maxPrice`).
     - `vehicle_specific`: Custom price tiers per vehicle type (`List<VehiclePricingTier>`) supporting fixed or range pricing per tier.
     - `contact`: Contact for price / custom quote inspection model.
   - Real-time price resolution must use `SmartPricingEngine.evaluate(...)` taking vehicle type and specifications into account.

3. **Zero-Cost Geocoding & Open Maps Integration (No Google Maps API):**
   - Garages store `googleAddress`, `googleMapsUrl`, `latitude`, and `longitude` in their Firestore document without invoking paid Google Maps APIs.
   - Coordinate extraction uses URL regex patterns (`@lat,lng` or `?q=lat,lng`) and free OpenStreetMap Nominatim forward geocoding (`https://nominatim.openstreetmap.org/search?q=...&format=json`).
   - Customer navigation and test map links launch standard Google Maps URLs via `url_launcher`.

4. **Zero-Overflow Responsive Standards:**
   - Every screen, sheet, card, and dialog must render without `RenderFlex` overflows from 320px mobile screens up to 1920px desktop viewports.
   - Label rows and action groups must wrap flexible text in `Flexible` or `Expanded`, use `Wrap` for buttons/chips, and constrain dialogs appropriately.

---

## 5. Global UI States, Loading, Empty States & Error Handling Rules

### Rule 13: GLOBAL UI STATE MANAGEMENT RULE — MANDATORY
1. **Mandatory UI States:**
   - Every data-driven screen and asynchronous operation must implement appropriate loading, success, empty, search-not-found, error, offline, and permission states.
   - Supported states:
     1. Initial State.
     2. Loading State (prefer skeleton loaders for cards/lists/profile sections; progress indicators for actions; enforce timeouts).
     3. Success State.
     4. Empty State (contextual, role-specific, e.g. "You haven't registered a garage yet" -> "Add Your Garage"; "No repair jobs found"; "No invoices available yet"; "You haven't added any services yet" -> "Add Service").
     5. Search Not Found State (dedicated `AppSearchEmptyState`; query display; Clear Filters action; never confuse zero results with a backend error).
     6. Error State (`AppErrorState`; clear user message; retry action; error type categorization; debug details without exposing internal stack traces).
     7. No Internet / Offline State (`AppOfflineState`; distinguish live vs cached data with sync/retry actions; never report unsynced actions as successful).
     8. Offline Cached Data State (banner/tag indicating cached data with last sync timestamp).
     9. Permission Denied State (`AppPermissionState`; location, notification, camera, storage with clear explanation and settings link).
     10. Unauthorized Access State (`AppUnauthorizedState`; access restricted vs session expired).
     11. Session Expired State (token expiration handled securely, redirecting to authentication).
     12. Partial Data State.

2. **Invariant Rules & Anti-Patterns:**
   - **Never leave a page blank or indefinitely loading.**
   - **Never use fake records as a substitute for empty data.**
   - **Never show a search-empty state when the actual issue is a backend failure.**
   - **Never show a success message before the backend confirms success.**
   - **Prevent duplicate submissions:** Always disable buttons or display `AppLoadingOverlay` / progress spinners during async mutations.

3. **Standardized Reusable State Components (`lib/core/shared_widgets/`):**
   - `AppLoadingState`
   - `AppSkeletonLoader` (`card`, `list`, `grid`, `profile`, `line`, `circle`)
   - `AppEmptyState`
   - `AppSearchEmptyState`
   - `AppErrorState`
   - `AppOfflineState`
   - `AppPermissionState`
   - `AppUnauthorizedState`
   - `AppRetryButton`
   - `AppLoadingOverlay`
   All state widgets support configurable title, description/message, icon/illustration, primary action, secondary action, layout size (`compact`, `standard`, `fullScreen`), light/dark themes, and zero-overflow responsive adaptability from 320px mobile to 1920px desktop.

---

## 6. Mandatory Feature-First MVVM Architecture with Riverpod & File Decomposition Rules

### Rule 14: Permanent Feature-First MVVM Architecture Standard

Every future development task, feature implementation, bug fix, UI modification, API integration, and refactoring must strictly follow this feature-first MVVM architecture with Riverpod.

#### 1. Feature-First Folder Structure
Every application section must maintain its own independent feature folder under `lib/features/<feature_name>/`:
```text
lib/
├── core/
│   ├── constants/
│   ├── config/
│   ├── network/
│   ├── services/
│   ├── exceptions/
│   ├── utils/
│   ├── theme/
│   └── widgets/
│       ├── app_text_field.dart
│       ├── app_dropdown.dart
│       ├── app_button.dart
│       ├── app_loading_state.dart
│       ├── app_empty_state.dart
│       └── app_error_state.dart
│
├── features/
│   ├── garage/
│   │   ├── views/          # Pure presentation, layout, user event forwarding
│   │   ├── view_models/    # Riverpod Notifiers/AsyncNotifiers, logic, validation
│   │   ├── models/         # Strongly-typed immutable state and domain models
│   │   ├── widgets/        # Reusable presentational components for the feature
│   │   └── repositories/   # Feature-specific Firestore queries & API communication
│   ├── jobs/
│   ├── invoices/
│   ├── analytics/
│   └── customers/
│
└── main.dart
```

#### 2. View Rules
The `views/` folder must contain presentation/UI logic only:
- Responsible for rendering UI and observing Riverpod providers.
- Display data received from ViewModels.
- Forward user interactions to ViewModel methods.
- Render loading, success, empty, search-not-found, offline, and error states.
- Handle screen navigation.
- **Strictly Forbidden in Views:** Direct API calls, direct Firestore queries, business logic, database operations, complex data transformations, authentication logic, or state-changing mutations.

#### 3. ViewModel Rules — State Management & Logic
All feature-specific state management and business operations must be handled inside the corresponding ViewModels using Riverpod:
- Coordinate API calls, Firestore operations, and state changes.
- Manage form state, field validation, and submission states.
- Manage search, filtering, sorting, and pagination.
- Perform data transformations and business validations.
- Handle loading states, request timeouts, and error mappings.
- **Forbidden:** Never put feature-specific state management in Views, Widgets, or unrelated global providers. Riverpod is the sole state management solution. Never use `setState()` for application state or business logic.

#### 4. Separate ViewModels Into Small Files
Do not create one massive ViewModel handling every operation of an entire feature:
- Split ViewModels according to logical responsibility (e.g. `garage_list_view_model.dart`, `garage_details_view_model.dart`, `garage_form_view_model.dart`, `garage_search_view_model.dart`).
- Each ViewModel must have a clear, single responsibility.

#### 5. Repository Rules
Each feature must have its own repository (or domain repository delegate) when it needs data access:
- Firestore queries, document operations, and batch/transaction updates.
- API communication and data persistence.
- Mapping raw database responses into strongly-typed domain models.
- Handling data-access errors and mapping to `AppException`.
- **Architectural Flow:**
  ```text
  View
    |
    v
  Riverpod ViewModel
    |
    v
  Feature Repository
    |
    v
  Core API / Firebase Services
    |
    v
  Firestore / Backend API
  ```
- Views and Widgets must NEVER directly access the repository or database.

#### 6. Model Rules
Each feature must maintain its own models:
- Define strongly-typed data structures, JSON serialization, and Firestore serialization.
- Enforce immutability and null safety (`copyWith`, `toMap`, `fromFirestore`).
- Zero UI widgets, business logic, or API request execution inside model classes.

#### 7. Widget Rules
All feature-specific UI components must reside inside that feature's `widgets/` folder:
- Focused on UI presentation and reusable within their feature.
- Receive data through constructors or read appropriate Riverpod providers.
- Delegate state-changing user actions to ViewModels.
- Zero direct database or API calls.

#### 8. Core and Shared Components Boundary
Only genuinely reusable components may exist in `core/`:
- `core/widgets/`: Centralized text fields, dropdowns, buttons, search fields, loading overlays, empty states, error states, responsive wrappers.
- `core/services/`: Firebase initialization, push notification infrastructure, connectivity monitoring, PDF/file upload infrastructure.
- `core/network/`: HTTP clients, interceptors, network error handlers.
- **Rule:** Never place feature-specific widgets or business logic into `core/`. Only components genuinely shared across multiple independent features belong in `core/`.

#### 9. Riverpod Implementation Standards
- Riverpod is the exclusive state management library across Customer, Merchant, and Admin modules.
- Use `AsyncNotifier` / `AsyncNotifierProvider` for asynchronous state.
- Use `Notifier` / `NotifierProvider` for synchronous state management.
- Keep provider definitions scoped close to their feature.
- Never use `setState()`, Bloc, Cubit, GetX, or separate Provider packages.

#### 10. STRICT RULE: NO MASSIVE SOURCE FILES
- Do not create unnecessarily lengthy source files.
- Files approaching approximately 300–400 lines must be reviewed for logical decomposition.
- One primary responsibility per file.
- Extract complex subwidgets, dialogs, sheets, and reusable components into dedicated files in `widgets/`.
- Extract multi-domain repository operations into dedicated feature repositories.
- Keep functions concise, readable, and self-documenting.

#### 11. Mandatory Architecture Compliance Checklist
Before completing any task, verify:
1. Feature-specific UI resides in the correct feature folder.
2. Feature-specific ViewModels reside within that feature.
3. All feature-specific state transitions occur through Riverpod ViewModels.
4. Views and presentational widgets contain zero direct Firestore or API calls.
5. Repositories handle data persistence and Firestore communication.
6. Models are strictly typed and immutable.
7. Feature widgets are cleanly extracted; no oversized files (> 300-400 lines without review).
8. Only genuinely reusable components reside in `core/`.
9. Zero `setState()` for application logic.
10. All three verification gates pass: `dart format`, `flutter analyze` (0 issues), `flutter test` (100% pass).

---

## 7. Permanent Technical SEO & Platform Separation Rules

### Rule 15: SEO AND PLATFORM SEPARATION RULE — MANDATORY
1. Every public web page must have appropriate SEO metadata.
2. Public website content must be crawlable and indexable where appropriate.
3. Maintain valid `sitemap.xml` and `robots.txt` files at the web root.
4. Generate page-specific titles, descriptions, and canonical URLs.
5. Use structured data (JSON-LD Schema.org) only when the underlying information is accurate.
6. Never expose private merchant or customer information through SEO pages.
7. Never index authenticated dashboards, invoices, payment records, private profiles, or private repair tracking.
8. Never create fake business records or fake SEO content.
9. SEO implementation must not negatively affect Android functionality.
10. Keep web-specific SEO dependencies and functionality separate from shared Android code.
11. Prefer lightweight, performant SEO solutions.
12. Use actual database records for dynamic public garage pages.
13. Update SEO documentation whenever public routes or page content change.
14. Verify crawler accessibility and page performance before marking SEO implementation complete.

---

## 8. Permanent Multi-Language Localization Rules (English & Malayalam)

### Rule 16: APPLICATION LOCALIZATION RULE — MANDATORY
1. **Dynamic Language Switching:**
   - The application supports English (`en`) and Malayalam (`ml`).
   - Switching language via `localeProvider` must immediately and dynamically re-render all visible presentation strings throughout the entire app without needing an app restart.
2. **Strict Separation of Static UI vs Database Values:**
   - **Translate Static Content:** Screen titles, descriptions, navigation labels, button pills, form labels, helper hints, empty states, error states, and system dialogs must use `context.tr(keyOrPhrase)` or `AppLocalizations`.
   - **Preserve Business & User Data:** Merchant garage names (e.g. "Vishnu Auto Care"), customer names (e.g. "Vishnu Shaji"), vehicle license plates ("KL 07 AB 1234"), mechanic notes, and custom line item descriptions must NEVER be translated or modified.
3. **Predefined Status Code Localization:**
   - Database documents store normalized alphanumeric status codes (`in_progress`, `completed`, `received`, `waiting_for_parts`, `ready_for_collection`, `paid`, `unpaid`, `overdue`, `due_soon`).
   - UI status components (including `AppStatusBadge`, timeline step views, and filter chips) must pass raw status codes through `loc.status(rawStatus)` or `loc.repairStatus(rawStatus)` to display natural, culturally appropriate Malayalam and English labels.
4. **Natural, Culturally Appropriate Malayalam:**
   - Use standard Malayalam automotive terminology familiar to Kerala users (e.g. 'അക്കൗണ്ട് പ്രൊഫൈൽ', 'വാറന്റി വോൾട്ട്', 'പുരോഗമിക്കുന്നു', 'പൂർത്തിയായി', 'പണം അടച്ചു', 'അടയ്ക്കാനുണ്ട്', 'കൈപ്പറ്റാൻ തയ്യാറാണ്').
5. **Universal Fallback and Typography:**
   - Any unknown string defaults cleanly to English or the raw input.
   - All Malayalam text must use the configured `AppFonts.fontFallbacks` (`['Manjari', 'Gayathri', 'Noto Sans Malayalam', 'sans-serif']`) and maintain zero `RenderFlex` overflows down to 320px screen width.
