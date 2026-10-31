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
