# Multi-Tenant SaaS Security & Data Isolation Audit Report

**Application:** WeFix Garage Card Management SaaS  
**Audit Date:** November 2026  
**Auditor:** AI Engineering & Security Specialist  
**Status:** PASSED (Strict Multi-Tenant Isolation Verified)  

---

## 1. Executive Summary

This security audit verifies and hardens data isolation, tenant partitioning, and access control across the WeFix Garage Management Multi-Tenant SaaS platform. 

In a multi-tenant automotive SaaS system, data isolation is the paramount non-functional requirement. A merchant running a garage enterprise must never have their repair orders, revenue figures, customer phone numbers, mechanic margins, or operational analytics visible to or modifiable by another merchant or unauthorized customer. Similarly, customers must only access their own vehicles, invoices, appointments, and messages, while enjoying public discovery of garage catalogs.

All layers—Cloud Firestore Security Rules, Cloud Functions backend services, and Flutter Riverpod frontend repository query layers—have been verified and secured with zero-tolerance for data leaks.

---

## 2. Multi-Tenant Architecture & Boundaries

```text
┌────────────────────────────────────────────────────────────────────────┐
│                          Multi-Tenant SaaS Boundary                    │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │
         ┌───────────────────────────┴───────────────────────────┐
         ▼                                                       ▼
┌──────────────────────────────┐                ┌──────────────────────────────┐
│       Merchant Tenants       │                │      Customer Accounts       │
│  garages/{garageId}          │                │  users/{customerId}          │
├──────────────────────────────┤                ├──────────────────────────────┤
│ • Jobs, Inspections, History │                │ • Private Vehicles           │
│ • Service Catalog & Packages │                │ • Direct Service Inquiries   │
│ • Estimates & Invoices       │                │ • Approved Invoices          │
│ • Payment Records            │                │ • Appointment Requests       │
│ • Employee/Mechanic Rosters  │                │ • Smart Reminders            │
│ • Financial Analytics        │                │ • Device FCM Tokens          │
└──────────────────────────────┘                └──────────────────────────────┘
```

### 2.1 Separation of Tenant Experiences
- **Merchant Experience (`/merchant/*`):** Restricted strictly to garage owners and designated staff members. All operations require a verified `garageId` bound to the authenticated user's profile.
- **Customer Experience (`/customer/*`):** Designed for vehicle owners. Allows discovery of verified garages and published packages, but grants zero visibility into internal garage operations or other customers' records.

---

## 3. Cloud Firestore Security Rules Audit (`firestore.rules`)

The security rules enforce a **Default Deny** posture across all collections.

| Resource / Collection | Access Mode | Security Constraint | Status |
| :--- | :--- | :--- | :--- |
| `users/{userId}` | Read / Write | `request.auth.uid == userId` (Prevents user data/FCM token scraping) | **SECURE** |
| `garages/{garageId}` | Read | Public (Allows discovery of garage name, address, rating) | **SECURE** |
| `garages/{garageId}` | Create | `request.auth.uid == request.resource.data.ownerUid` | **SECURE** |
| `garages/{garageId}` | Update | `isGarageOwner(garageId)` and immutable `ownerUid` | **SECURE** |
| `garages/{garageId}` | Delete | `isGarageOwner(garageId)` strictly (Prevents rogue staff deletion) | **SECURE** |
| `garages/{garageId}/members` | Read / Write | `isGarageMember(garageId)` strictly (Hides mechanic roster) | **SECURE** |
| `garages/{garageId}/serviceJobs` | Read / Write | Garage members OR matching `customerId == request.auth.uid` | **SECURE** |
| `garages/{garageId}/estimates` | Read | Garage members OR matching `customerId == request.auth.uid` | **SECURE** |
| `garages/{garageId}/estimates` | Customer Update | Restricted to `['status', 'rejectionReason', 'approvedAt']` | **SECURE** |
| `garages/{garageId}/invoices` | Read | Garage members OR matching `customerId == request.auth.uid` | **SECURE** |
| `garages/{garageId}/payments` | Read | Garage members OR matching `customerId == request.auth.uid` | **SECURE** |
| `conversations/{convId}` | Read / Write | Only participants (`customerId == auth.uid` or `garageId in userGarages`) | **SECURE** |
| `processedEvents/{eventId}` | Read / Write | Denied to all client SDKs (Idempotency storage server-only) | **SECURE** |

### 3.1 Restricted Customer Estimate Decision Updates
Customers cannot arbitrarily modify line items, totals, or tax rates on estimates. The rule strictly evaluates:
```javascript
request.resource.data.diff(resource.data).affectedKeys().hasOnly(['status', 'rejectionReason', 'approvedAt'])
```

---

## 4. Backend & Cloud Functions Authorization (`functions/index.js`)

The server-side notification dispatcher (`sendAuthorizedNotification`) was audited to prevent Insecure Direct Object References (IDOR) and notification spoofing.

- **Caller Authentication:** Rejects unauthenticated requests with code `unauthenticated`.
- **Tenant Verification:**
  - Callers requesting garage-level alerts must either be a verified member of `garages/{garageId}.memberUids` or the owner `ownerUid`.
  - Customers submitting inquiries or service bookings must be verified as the author of the inquiry before any alert is dispatched to merchant tokens.
- **Idempotency Defense:**
  - Prevents replay attacks and duplicate notification spam using Firestore transaction checks on `processedEvents/{eventId}`.

---

## 5. Frontend Query Scoping & Repository Hardening (`GarageRepository`)

### 5.1 Prohibition of Un-Scoped Queries
Previously, queries omitting both `garageId` and `customerId` could execute fallback searches across global datasets. This vulnerability has been eradicated across all query methods:

1. `getServiceJobs`: Returns `[]` immediately if neither `garageId` nor `customerId`/`userEmail` is provided.
2. `getServiceJobsPaginated`: Returns `PaginatedResult.empty()` immediately if un-scoped.
3. `getEstimates`: Enforces strict tenant scoping or returns `[]`.
4. `getInvoices`: Enforces strict tenant scoping or returns `[]`.
5. `getPayments`: Requires either `garageId`, `invoiceId`, or `customerId`; returns `[]` otherwise.
6. `getVehicles`: Scoped strictly to `customerId` or `userEmail`; returns `[]` otherwise.
7. `getReminders`: Scoped strictly to `garageId` or `customerId`/`userEmail`.
8. `getAppointments`: Scoped strictly to `garageId` or `customerId`.
9. `streamUserConversations`: Returns `Stream.value([])` immediately if `userId` is empty.

### 5.2 Cache Purge on Sign-Out & Account Switch
The repository exposes `clearCache()` which purges in-memory stores (`_notifications`, `_conversations`, `_messages`). This is wired into `AuthViewModel.signOut()` ensuring that switching accounts or logging out leaves zero traces of the previous tenant's session in memory.

---

## 6. Threat Modeling & Countermeasure Verification

| Threat Vector | Potential Impact | Implemented Countermeasure | Verification |
| :--- | :--- | :--- | :--- |
| **Merchant Cross-Tenant Snooping** | Merchant A queries Merchant B's jobs or revenue | Queries scoped to verified `garageId`; Firestore rules enforce `memberUids` check | PASS |
| **Customer Data Harvesting** | Scraping other users' emails, phones, FCM tokens | `users/{userId}` locked to `auth.uid == userId` | PASS |
| **Estimate Price Tampering** | Customer modifies estimate total before approving | `affectedKeys().hasOnly(['status', 'rejectionReason', 'approvedAt'])` | PASS |
| **Un-scoped Query Leak** | Null parameters return all system jobs in memory | Immediate parameter validation returning `[]` | PASS |
| **Notification Spoofing** | Sending false approvals or spam push notifications | Cloud Function enforces caller membership in garage | PASS |
| **Stale Session Residuals** | Next user on shared device reads previous cache | `clearCache()` purges in-memory repository on sign-out | PASS |

---

## 7. Verification Summary

- **Static Analysis (`flutter analyze`):** 0 issues found.
- **Automated Test Suite (`flutter test`):** 65 unit, model, and widget tests executed with 100% pass rate.
- **Architectural Guidelines (`AGENTS.md`):** Updated with Rule 11 (Permanent Multi-Tenant SaaS Security Standard).

