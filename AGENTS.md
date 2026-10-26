# AGENTS.md — Garage Management SaaS Architecture & Rules

## 1. Project Overview & Objectives
Garage Card is a production-oriented, multi-tenant Garage Management SaaS application built with Flutter (targeting Android and Web) and Firebase.
The application serves two distinct user experiences within a single unified Flutter codebase:
1. **Customer Experience:** Garage discovery, vehicle registry, live repair status tracking, estimate approvals/rejections, invoice viewing, payment history, notifications, service history, and smart service reminders.
2. **Merchant Experience (Garage Owners & Staff):** Customer and vehicle management, repair job tracking, digital inspections, estimate creation/revision, invoice issuance, manual payment recording, appointment/request management, staff roles, garage profile, branding, and subscription settings.

---

## 2. Core Architectural Principles

### 2.1 Feature-Based MVVM Architecture
Every feature in `lib/features/` must strictly adhere to the 4-tier MVVM structure:
```text
features/<feature_name>/
├── View/       # Page-level UI, routing endpoints, user action forwarding
├── ViewModel/  # Riverpod Notifier/AsyncNotifier, state, API calls, logic, validations
├── Model/      # Strongly-typed immutable data models (fromFirestore, toFirestore, copyWith)
└── Widgets/    # Feature-specific dumb presentation components
```

### 2.2 Strict ViewModel Ownership & Reactive State
- **Riverpod Only:** Riverpod (`flutter_riverpod`) is the exclusive state management library across the entire project.
- **No `setState` for Application State:** `setState` is strictly forbidden for application logic or cross-component state. Ephemeral animation controller state in isolated animation widgets is the only acceptable edge case.
- **Views are Pure Presentation:** Views must only read/watch Riverpod providers and forward UI events (taps, inputs) to ViewModels.
- **Zero Firebase in UI:** No Firestore queries, Auth calls, Storage uploads, or Cloud Functions calls may exist in `View` or `Widgets` layers. All interactions must be coordinated by ViewModels.
- **Immutable State:** All ViewModel states must be immutable models with comprehensive `AsyncValue` or dedicated state objects tracking loading, errors, pagination, and data.

### 2.3 Strict No Code Comments Policy
- **Zero Comments in Application Source Code:** Do not add inline comments (`//`), block comments (`/* ... */`), or docstrings to Dart source code files in `lib/` and `test/`.
- **Self-Explanatory Code:** Code must be completely self-documenting through clear, expressive naming, small single-responsibility functions, and strong typing.
- **Documentation Destination:** All architectural decisions, schemas, workflows, and specifications must reside in `AGENTS.md` and Markdown documentation files.

### 2.4 Strongly Typed Models
- Every Firestore document and API response must be parsed into a strongly-typed Dart model at the boundary.
- Models must provide explicit serialization: `fromFirestore`, `toFirestore`, `fromJson`, `toJson`, and `copyWith`.
- Safe handling of nullable fields, ISO dates / Firestore `Timestamp`, numeric conversions (e.g. integer cents/paise or double parsing), and enum mappings with safe fallbacks.
- Views and ViewModels must never manipulate raw maps (`Map<String, dynamic>`).

### 2.5 Mandatory Multi-Device Responsiveness (Desktop, Laptop, Tablet, Mobile)
- **100% Responsive Architecture:** Every screen, layout, component, and feature must adapt gracefully across Mobile (<768px), Tablet (768px-1023px), Laptop (1024px-1199px), and Desktop (1200px+).
- **Adaptive Layout Structures:** Desktop & Tablet form factors must utilize adaptive sidebars/navigation rails, multi-column cards, and maximum width content constraints (`1200px` max).
- **Mobile Ergonomics:** Mobile form factors must utilize thumb-zone navigation, floating adaptive navigation bars, and responsive bottom sheets.
- **Zero Overflow Policy:** Under no circumstance may any widget produce a `RenderFlex` overflow on any viewport width.

---

## 3. Directory & File Organization

```text
lib/
├── main.dart
├── app.dart
├── core/
│   ├── branding/
│   │   ├── app_logo.dart
│   │   └── app_branding.dart
│   ├── colors/
│   │   └── app_colors.dart
│   ├── fonts/
│   │   └── app_fonts.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── theme_controller.dart
│   ├── localization/
│   │   ├── app_localizations.dart
│   │   ├── app_en.arb
│   │   └── app_ml.arb
│   ├── routing/
│   │   ├── app_router.dart
│   │   └── route_paths.dart
│   ├── firebase/
│   │   ├── firebase_config.dart
│   │   ├── firestore_paths.dart
│   │   └── firebase_providers.dart
│   ├── notifications/
│   │   ├── notification_service.dart
│   │   └── push_notification_manager.dart
│   ├── location/
│   │   ├── location_service.dart
│   │   └── geohash_helper.dart
│   ├── pagination/
│   │   ├── paginated_state.dart
│   │   └── pagination_controller.dart
│   ├── errors/
│   │   ├── app_exception.dart
│   │   └── error_handler.dart
│   ├── formatting/
│   │   ├── currency_formatter.dart
│   │   └── date_formatter.dart
│   ├── constants/
│   │   └── app_constants.dart
│   └── shared_widgets/
│       ├── app_text_field.dart
│       ├── app_dropdown.dart
│       ├── app_searchable_dropdown.dart
│       ├── app_button.dart
│       ├── app_loading.dart
│       ├── app_empty_state.dart
│       ├── app_error_state.dart
│       ├── app_refresh.dart
│       ├── app_pagination_loader.dart
│       ├── app_dialog.dart
│       ├── app_status_badge.dart
│       └── app_responsive_layout.dart
├── features/
│   ├── authentication/
│   │   ├── View/
│   │   ├── ViewModel/
│   │   ├── Model/
│   │   └── Widgets/
│   ├── customer/
│   │   ├── dashboard/
│   │   ├── nearby_garages/
│   │   ├── garage_details/
│   │   ├── vehicles/
│   │   ├── service_jobs/
│   │   ├── estimates/
│   │   ├── invoices/
│   │   ├── payments/
│   │   ├── service_history/
│   │   ├── reminders/
│   │   ├── notifications/
│   │   ├── appointments/
│   │   ├── profile/
│   │   └── settings/
│   ├── merchant/
│   │   ├── dashboard/
│   │   ├── garage_profile/
│   │   ├── customers/
│   │   ├── vehicles/
│   │   ├── service_catalog/
│   │   ├── service_jobs/
│   │   ├── inspections/
│   │   ├── estimates/
│   │   ├── invoices/
│   │   ├── payments/
│   │   ├── reminders/
│   │   ├── notifications/
│   │   ├── appointments/
│   │   ├── staff/
│   │   ├── subscriptions/
│   │   └── settings/
│   └── shared/
│       ├── documents/
│       ├── models/
│       └── widgets/
└── firebase_options.dart
```

---

## 4. Multi-Tenant Authorization & Roles

### 4.1 Role Selection vs. Authorization
- **Login Role Selector:** At login/registration, users select an intended experience (Customer vs. Merchant).
- **Zero Client Trust:** The role selector merely sets the target landing intent. Server-side Firestore profile data (`users/{uid}` and `garages/{garageId}/members/{uid}`) determines actual permissions.
- **Tenant Isolation:** A merchant can only access collections belonging to their authorized `garageId`. Customers can only access their owned vehicles, service jobs, estimates, and invoices.
- **Account Switching:** If a single Firebase Auth user owns a garage and also registers their personal vehicle as a customer, controlled switching is facilitated through verified memberships.

### 4.2 Security Rules Standards
- All reads and writes enforce `request.auth != null`.
- Multi-tenant boundary checks verify `request.auth.uid in get(/databases/$(database)/documents/garages/$(garageId)).data.memberUids` or specific sub-collection membership.
- Customer documents check `resource.data.customerId == request.auth.uid`.
- Financial balance adjustments, status transition validation, and subscription tier writes must be restricted to authorized roles and server functions.

---

## 5. UI Design System & Reusable Form Components

### 5.1 Centralized Custom Form Controls
No screen or feature may implement raw, ad-hoc `TextFormField` or default Flutter `DropdownButton`.
1. **`AppTextField`:**
   - Centralized borders, focus outlines, error styling, and label typography.
   - Built-in support for prefix/suffix icons, obscure text toggle, input formatters, validator functions, and multiline descriptions.
   - Responsive sizing and automatic light/dark theme adaptation.
2. **`AppDropdown<T>`:**
   - Custom styled bottom-sheet or popup selector matching the automotive design system.
   - Searchable filtering for long lists (e.g. vehicle makes, services, customers).
   - Clear error states, disabled states, loading indicators, and keyboard accessibility.

### 5.2 Automotive Visual Identity
- **Primary Color:** Deep slate / midnight indigo `#0F172A` / `#1E293B`.
- **Accent Brand Color:** Electric cobalt / racing amber `#2563EB` / `#D97706`.
- **Status Colors:** Semantic emerald (Completed/Approved), amber (In Progress/Pending), rose (Rejected/Overdue), slate (Draft).
- **Responsive Container:** Max width 1200px on desktop web, responsive grids, mobile-optimized bottom navigation, desktop drawer/sidebar.

---

## 6. Proactive Cursor-Based Pagination

### 6.1 Cursor Pagination Rules
- Unbounded lists (jobs, invoices, estimates, notifications, customers, vehicles, garages) must query Firestore using `.orderBy(...).limit(pageSize)`.
- Subsequent pages use `.startAfterDocument(lastDocumentSnapshot)`.
- Never use memory-only pagination for entire remote collections.

### 6.2 Proactive Prefetching
- Pre-fetch threshold: Trigger the next page fetch when the user reaches ~75% of the current list (e.g., item index 15 in a 20-item page).
- Duplicate request prevention: Maintain a boolean `isFetchingNextPage` guard and suppress simultaneous triggers.
- Filter/Search resets: Any search query or filter change immediately clears the cursor, resets the list, and triggers a fresh page 1 query.

---

## 7. Service Jobs, Status Workflow & Notifications

### 7.1 Authoritative Status Workflow
Jobs progress through defined status transitions:
1. `draft` -> `received`
2. `received` -> `inspectionPending` -> `estimatePending`
3. `estimateApproved` -> `inProgress`
4. `inProgress` -> `readyForCollection`
5. `readyForCollection` -> `completed` -> `closed`

### 7.2 Idempotent Notification Dispatch
- Status transitions write an audit entry to `garages/{garageId}/serviceJobs/{jobId}/history/{historyId}`.
- Corresponding persistent in-app notifications are written to `users/{customerId}/notifications/{notificationId}`.
- FCM push dispatch uses an idempotency key (`${jobId}_${newStatus}`) to prevent repeated alerts on network retries.

---

## 8. Financial Integrity, Estimates, Invoices & PDF

### 8.1 Money & Calculations
- Store currency codes (INR, AED, USD) per garage and snapshot them on each document.
- Subtotals, taxes, discounts, and grand totals are calculated using consistent rounding.
- Invoices reference their parent estimate and lock in the snapshot.

### 8.2 Document Generation & Sharing
- Estimates and invoices generate high-fidelity PDF documents using the `pdf` package.
- Documents include garage branding (name, contact, tax number, logo), customer details, vehicle registration, itemized labor & parts, and payment instructions.
- Instant prefilled WhatsApp message sharing for estimates, invoice links, and status updates.

---

## 9. Smart Service Reminders

### 9.1 Calculation Rules
- On job completion, the system calculates the next recommended service date based on the recorded service interval (e.g. 6 months or 10,000 km) and current odometer reading.
- Customers can also record external services, explicitly tagged as `customerReported`.
- Reminders update dynamically without creating duplicate alerts.

---

## 10. Localization & Multi-Currency

- Full support for English (`en`) and Malayalam (`ml`).
- Dynamic language switcher in user settings.
- Dates and currencies formatted according to garage configuration and active locale.

---

## 11. Testing & Quality Gates

Every implementation phase must pass:
1. `flutter pub get`
2. `dart format --output=none --set-exit-if-changed .`
3. `flutter analyze`
4. `flutter test`
5. Release builds verification (`flutter build apk`, `flutter build web`).

---

## 12. Phased Implementation Roadmap

- **Phase 0:** Project inspection, AGENTS.md creation, environment validation.
- **Phase 1:** Core dependencies, branding, colors, typography, theme, localization, centralized form components (`AppTextField`, `AppDropdown`).
- **Phase 2:** Strongly-typed core models, Firebase config, mock/emulator providers, authentication feature with custom role selector and session routing.
- **Phase 3:** Multi-tenant Firestore schema definitions and security rules.
- **Phase 4:** Merchant operations: Garage profile, customer management, vehicle registry, service catalog, service jobs, digital inspections.
- **Phase 5:** Customer experience: Dashboard, vehicle management, live repair tracking, estimate review & approval, invoices, service history.
- **Phase 6:** Nearby garages discovery: Location permissions, geohash spatial queries, fallback search, quick contact (Call, WhatsApp, Directions, Help request).
- **Phase 7:** Notifications: In-app persistent notification center, FCM token management, status trigger events.
- **Phase 8:** Financials: Estimates, invoices, payment recording, PDF generation, WhatsApp sharing.
- **Phase 9:** Smart service reminders: Next service scheduling, external service logging, due reminders.
- **Phase 10:** Subscriptions, garage settings, currency selection, and theme preferences.
- **Phase 11:** Proactive cursor pagination audit across all large lists.
- **Phase 12:** Comprehensive unit, ViewModel, and widget test suites.
- **Phase 13:** Static analysis, release build verification, and final handoff documentation.
