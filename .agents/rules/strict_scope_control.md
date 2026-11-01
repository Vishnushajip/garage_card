# Strict Scope Control & Operational Safety Rules

> **MANDATORY INSTRUCTION FOR ALL AI AGENTS & DEVELOPERS:**
> These rules take precedence over all assumptions, suggestions, and default behaviors. They must be followed on every task without exception.

---

## 1. Absolute Scope Control — Do ONLY What Was Requested

Never modify anything outside the explicitly requested scope.

### Examples of Prohibited vs. Correct Behaviors:
- **Change logo in sidebar:**
  - ❌ *Prohibited:* Replace logo throughout splash screen, auth screen, app bar, web index, and dashboard.
  - ✅ *Correct:* Change ONLY the logo displayed in the sidebar.
- **Change application logo:**
  - ❌ *Prohibited:* Redesign the splash screen, modify its animation, background, colors, layout, or typography.
  - ✅ *Correct:* Replace only the requested logo asset or reference; preserve existing screen design and animations.
- **Update a particular dashboard card:**
  - ❌ *Prohibited:* Redesign the whole dashboard, change spacing, or modify unrelated widgets.
  - ✅ *Correct:* Update ONLY that particular card.
- **Fix a button's functionality:**
  - ❌ *Prohibited:* Rebuild the screen, refactor surrounding state, or restyle surrounding UI.
  - ✅ *Correct:* Fix the button's action handler without touching unrelated UI or logic.
- **Modify a Flutter feature:**
  - ❌ *Prohibited:* Run `flutter build web`, modify hosting/deployment configs, or trigger production deploy.
  - ✅ *Correct:* Work ONLY on the requested Flutter Dart files.

---

## 2. Twelve Mandatory Scope Rules

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

---

## 3. Shared Component & Asset Safety

Before modifying any shared component, logo, image, theme, or global configuration:
1. **Identify the exact file:** Pinpoint the precise asset or component.
2. **Identify all references:** Run project-wide searches (`grep`) to locate all usages across `lib/`, `web/`, and `assets/`.
3. **Determine shared status:** Check whether it is shared across multiple screens or customer/merchant roles.
4. **Evaluate impact:** Understand what will visually or functionally change if modified.
5. **Modify only required usage:** If a logo or widget is shared globally, do NOT replace the global asset if the request concerns only one screen or widget. Create a localized reference or parameterize the component while preserving all other usages.

---

## 4. Absolute Prohibition on Unauthorized Building or Deployment

Never automatically:
- Run `flutter build web` or any web compilation.
- Run `flutter build apk`, `flutter build appbundle`, or any mobile compilation.
- Deploy to Firebase Hosting (`firebase deploy`).
- Deploy to AWS or any cloud hosting.
- Upload assets to production buckets.
- Modify DNS, hosting rewrites, or domain settings.
- Change production environment variables or secrets.
- Modify live database collections or configurations.
- Push commits to remote Git repositories (`git push`).
- Create commits or merge branches unless instructed.

**Rule:** Perform build or deployment operations ONLY when the user explicitly requests them in their prompt. Completing code changes does NOT grant permission to build or deploy.

---

## 5. Mandatory 7-Step Workflow for Every Request

Every request must execute through this exact lifecycle:
1. **Step 1 – Understand:** Read the complete request; identify the exact requested outcome.
2. **Step 2 – Define Scope:** List required files, components, screens, and explicitly excluded areas.
3. **Step 3 – Inspect:** Read the actual source code and existing implementation before making changes.
4. **Step 4 – Plan:** Formulate the minimal set of edits that strictly satisfies the request.
5. **Step 5 – Implement:** Modify only the files strictly required; add no unrelated improvements.
6. **Step 6 – Verify:** Run `flutter analyze` and `flutter test` to ensure zero compilation or regression issues.
7. **Step 7 – Report:** State what was requested, what was changed, which files were edited, and what was intentionally left unchanged.

---

## 6. When to Ask Before Proceeding

Ask the user before taking action when:
- A change to a shared asset or component could impact other screens.
- A requested UI change requires backend, security rule, or database schema modifications.
- The request is genuinely ambiguous and multiple conflicting interpretations exist.
- *Do not ask unnecessary questions when the requested scope is already clear and self-contained.*

