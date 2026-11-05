# Mandatory Bilingual Localization (English & Malayalam) Rule

> **MANDATORY INSTRUCTION FOR ALL AI AGENTS & DEVELOPERS:**
> Every newly introduced feature, adding option, dialog, screen, form field, button, dropdown, and state indicator in this application MUST support complete, dynamic English (`en`) and Malayalam (`ml`) language switching. No new feature may be merged or marked complete without full bilingual localization.

---

## 1. Core Principles

1. **Dual Language Coverage at Conception:**
   - Every user-facing string added for a feature MUST have both an English (`en`) definition and an authentic Malayalam (`ml`) translation.
   - Half-implemented localization (e.g. adding English text and skipping Malayalam) is strictly prohibited.

2. **Single Source of Truth (`AppLocalizations`):**
   - All string entries must be registered in `lib/core/localization/app_localizations.dart`:
     - Inside `_localizedValues['en']` for English strings.
     - Inside `_localizedValues['ml']` for Malayalam translations.
     - Inside `_phraseToKeyMap` for lower-cased phrase fallbacks.

3. **Reactive State Rebuilding:**
   - Widgets rendering localized strings must watch the localization provider:
     ```dart
     @override
     Widget build(BuildContext context, WidgetRef ref) {
       ref.watch(localeProvider);
       // ...
     }
     ```
   - This guarantees that switching language in user settings or the profile view immediately reflects across the entire UI without requiring a reload or app restart.

4. **Zero Hardcoded User-Facing Strings:**
   - Never embed literal English or Malayalam strings in widgets, dialogs, buttons, tooltips, or `AppNotificationService` alerts.
   - Always resolve through `context.tr('key')` or `context.tr('phrase')`.
   - Dynamic user data (such as customer names, phone numbers, license plate numbers, or custom notes) must be preserved verbatim and never altered.

5. **Customer Notifications (WhatsApp / SMS):**
   - Any feature that generates messages to customers must provide a language selector (English / മലയാളം).
   - The message template must render 100% in the selected language, without mixing Malayalam and English sentences.

---

## 2. Checklist for Adding New Features & Options

Before completing any task that introduces new UI or operational flows:

- [ ] Identified all static strings (page title, app bar subtitle, section headers, form labels, hints, validation errors, button labels, empty states, notifications).
- [ ] Added keys and values to `_localizedValues['en']` in `app_localizations.dart`.
- [ ] Added accurate translations to `_localizedValues['ml']` in `app_localizations.dart`.
- [ ] Added lower-case mappings to `_phraseToKeyMap` in `app_localizations.dart`.
- [ ] Ensured `ref.watch(localeProvider)` is invoked in widget `build()` methods.
- [ ] Tested switching between English and Malayalam to verify all labels update dynamically.
- [ ] Ensured compliance with **Rule 10: Strict No Code Comments Policy in Dart Files** (0 comments in `lib/` and `test/`).

