# PROJECT_ROADMAP.md — Phased Implementation Roadmap & Engineering Plan

## 1. Roadmap Overview & Strategic Horizon
This roadmap organizes the prioritized enhancements from `FEATURE_GAP_ANALYSIS.md` into five cohesive implementation phases. Each phase is self-contained, testable, and delivers immediate operational value to garage owners and vehicle owners.

```mermaid
flowchart LR
    P0[Phase 0:\nDynamic Services & Smart Search\n(COMPLETED)] --> P1[Phase 1:\nCore Job Lifecycle & Gate Pass]
    P1 --> P2[Phase 2:\nParts Inventory & Stock Engine]
    P2 --> P3[Phase 3:\nPayment Gateway & Tax Export]
    P3 --> P4[Phase 4:\nRich Media Chat & AMC Contracts]
    P4 --> P5[Phase 5:\nAI Dictation & Smart OCR]
```

---

## Phase 0: Dynamic Services Engine, Smart Search & Zero-Cost Geocoding (COMPLETED)
- **Dynamic Service Management:** Workshops manage dynamic services with multi-vehicle compatibility chips under `garages/{garageId}/services/{serviceId}` supporting Fixed, Range, Vehicle-Specific tiers, and Contact for Quote.
- **Smart Dynamic Pricing Engine:** Real-time resolution via `SmartPricingEngine.evaluate` taking vehicle type, engine displacement, and attributes into account.
- **Dedicated Automotive Search (`/customer/search`):** Real-time multi-filter sheet (Distance, Vehicle compatibility, Category, Budget Range, Sorting) with responsive layout adapting from 320px mobile to 1440px desktop.
- **Zero-Cost Geocoding & Open Maps:** Extracting coordinates from Google Maps URLs via regex and resolving addresses via free OpenStreetMap Nominatim without paid Google Maps APIs.
- **Database-First Integrity:** Direct Cloud Firestore DB integration with automatic seeding (`seedInitialFirestoreDataIfNeeded`) and 0 local fake data fallbacks.

---

## Phase 1: Core Job Lifecycle Integrity & Digital Gate Pass (Immediate Priority)

### 1.1 Objectives
Eliminate unauthorized vehicle release, customer estimate disputes over surprise work, and un-indexed Firestore query risks.

### 1.2 Features to Implement
1. **Supplemental Repair Approval Workflow:**
   - Enables mechanics to submit supplementary line items mid-job without destroying the initial approved estimate.
   - Customers receive an instant push alert: *"Additional work required on brake caliper (₹1,200). Approve / Reject."*
2. **Digital Gate Pass & OTP Vehicle Release:**
   - Generates a cryptographically secure 4-digit OTP or QR code when an invoice balance reaches zero.
   - Gate security or garage lead verifies the OTP before releasing the keys and vehicle.
3. **Formal Quality Control (QC) Sign-off Checklist:**
   - 8-point workshop checklist (Fluid levels, Tire pressure, Torque check, Cleanliness, Road test) mandatory before triggering `readyForCollection`.
4. **Firestore Indexes Manifest (`firestore.indexes.json`):**
   - Pre-build all composite indexes for queries filtering by `garageId`, `status`, and sorting by `createdAt`.

### 1.3 Technical Modifications
- **Frontend Changes:**
  - Add `SupplementalEstimateDialog` in `lib/features/merchant/estimates/`.
  - Add `QCChecklistModal` in `lib/features/merchant/service_jobs/Widgets/`.
  - Add `DigitalGatePassCard` with QR code view in `lib/features/customer/service_jobs/` and merchant job details.
- **Backend & Database Modifications:**
  - Add `supplementalEstimates` subcollection: `garages/{gId}/serviceJobs/{jId}/supplementalEstimates/{id}`.
  - Add `qcChecklist` field to `ServiceJobModel` (`Map<String, bool>`).
  - Add `gatePassCode` and `isGatePassVerified` to `ServiceJobModel`.
  - Add composite index definitions in `firestore.indexes.json`.
- **Testing Requirements:**
  - Unit tests for supplemental estimate balance calculations.
  - Widget tests for QC checklist mandatory validation before status advancement.
  - End-to-end mock test for gate-pass OTP verification.
- **Expected Outcome:** 100% elimination of payment drive-aways and zero disputes over unapproved mid-repair work.

---

## Phase 2: Spare Parts Inventory & Auto-Stock Deduction (Operational Efficiency)

### 2.1 Objectives
Automate workshop inventory tracking so garage owners know their exact physical stock of lubricants, filters, pads, and fluids without manual counting.

### 2.2 Features to Implement
1. **Parts Inventory Registry:**
   - SKU, Part Name, Category, OEM/Aftermarket tag, Cost Price, Selling Price, Min Stock Alert Level, and Current Stock.
2. **Automatic Stock Deduction on Invoicing:**
   - When a service job or invoice is finalized, line items matching inventory SKUs automatically deduct physical quantity.
3. **Low Stock Dashboard Alerts:**
   - Highlight items falling below reorder threshold on the Merchant Dashboard pipeline.
4. **Counter Sale / OTC Quick Invoicing:**
   - Allows billing walk-in customers for engine oil or spare parts without opening a full service job card.

### 2.3 Technical Modifications
- **Frontend Changes:**
  - Create new feature folder `lib/features/merchant/inventory/` (View, ViewModel, Model, Widgets).
  - Add inventory picker dropdown inside `EstimateFormDialog` line item rows.
  - Add Quick OTC Bill button to Merchant Dashboard action bar.
- **Backend & Database Modifications:**
  - New Firestore subcollection: `garages/{garageId}/inventory/{partId}`.
  - Cloud Functions trigger on invoice creation to batch-decrement stock and alert garage when quantity < threshold.
- **Testing Requirements:**
  - Concurrency tests for stock decrement.
  - Negative quantity prevention tests.
  - Stock valuation report math verification.
- **Expected Outcome:** Workshop owners save 5+ hours weekly on parts reconciliation and eliminate stockouts during active jobs.

---

## Phase 3: Digital Payment Gateway & Accounting Tax Export (Financial Health)

### 3.1 Objectives
Enable in-app customer payments via UPI / Cards / NetBanking and provide one-click GST/VAT export for garage accountants.

### 3.2 Features to Implement
1. **In-App Payment Gateway Integration:**
   - Integrated Razorpay / Stripe checkout inside `CustomerInvoicesScreen`.
   - Webhook automatically marks invoice as `paid` and records a `PaymentModel` entry in real-time.
2. **Partial & Split Payment Recording:**
   - Support paying split amounts (e.g. ₹3,000 cash advance + ₹7,500 UPI balance).
3. **GST / Tax Export for Tally & Zoho Books:**
   - Export monthly invoices into standardized CSV / Excel format with HSN/SAC codes, CGST, SGST, IGST, and Taxable Value.

### 3.3 Technical Modifications
- **Frontend Changes:**
  - Add "Pay Now" button in `lib/features/customer/invoices/Widgets/invoice_card_item.dart`.
  - Add Export Tax Report button and date-range selector in `lib/features/merchant/analytics/`.
- **Backend & Database Modifications:**
  - Cloud Functions: `createPaymentOrder`, `verifyPaymentWebhook`.
  - Secure webhook listener writing verified payments to `garages/{gId}/payments/`.
- **Dependencies:**
  - `razorpay_flutter` or web checkout script.
  - `csv: ^6.0.0` for spreadsheet generation.
- **Testing Requirements:**
  - Webhook cryptographic signature verification tests.
  - Financial rounding tests across split payment sums.
- **Expected Outcome:** 80% reduction in aged accounts receivable and 10x faster monthly tax filing for garage owners.

---

## Phase 4: Rich Media In-App Messaging & Annual Service Packages (Retention)

### 4.1 Objectives
Elevate customer-mechanic communication with visual proof and secure predictable recurring workshop revenue through service contracts.

### 4.2 Features to Implement
1. **Rich Media in Instant Chat:**
   - Upload and stream damaged part photos, short engine noise voice clips, and PDF estimates directly inside `ChatScreen`.
2. **Annual Maintenance Contracts (AMC) & Service Packs:**
   - Sell bundled packages (e.g., 3 general periodic services + 2 dry washes for 1 year at ₹4,999).
   - Tracks remaining package entitlements on the customer dashboard.
3. **Automated 48-Hour WhatsApp Post-Service Follow-up:**
   - Sends automated service satisfaction check and Google Maps review prompt 48 hours after vehicle collection.

### 4.3 Technical Modifications
- **Frontend Changes:**
  - Add camera/image picker action button in `lib/features/chat/Widgets/chat_input_bar.dart`.
  - Add AMC / Package subscription card on `CustomerDashboardScreen` and `CustomerGarageDetailScreen`.
- **Backend & Database Modifications:**
  - Add `mediaUrl` and `mediaType` (`image`, `audio`, `pdf`) to `ChatMessageModel`.
  - New subcollection: `garages/{garageId}/amcSubscriptions/{subId}`.
- **Testing Requirements:**
  - Cloud Storage media upload permission tests.
  - AMC redemption decrement tests.
- **Expected Outcome:** 30% increase in repeat customer retention and higher customer trust through photographic repair evidence.

---

## Phase 5: Voice-to-Text Dictation & Smart AI Vehicle Scanner (Future Frontier)

### 5.1 Objectives
Empower workshop technicians to create complete job cards hands-free and eliminate manual data entry errors.

### 5.2 Features to Implement
1. **Voice-to-Job-Card Dictation (AI Mechanic Assistant):**
   - Transcribes spoken mechanic notes directly into structured line items using local speech recognition.
2. **Camera License Plate OCR Scanner:**
   - Reads vehicle license plates on camera check-in, automatically searching existing customer records or pre-populating vehicle data.
3. **Predictive Service Mileage Engine:**
   - Learns vehicle driving patterns to alert customers when brake pads or fluids are expected to wear out based on average daily mileage.

### 5.3 Technical Modifications
- **Dependencies:**
  - `speech_to_text: ^6.6.0`
  - `google_mlkit_text_recognition`
- **Testing Requirements:**
  - Audio permission handling and offline speech-to-text fallback tests.
  - Plate regex validation across state formats.
- **Expected Outcome:** Check-in time reduced from 5 minutes to under 45 seconds per vehicle.

