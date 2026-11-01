# V-Fix Technical SEO Implementation Reference

> **Documentation Type:** Engineering & Technical SEO Architecture  
> **Platform Version:** 1.0.0  
> **Last Verified:** November 2026  

---

## 1. Directory & File Manifest

The V-Fix technical SEO implementation comprises the following files:

```text
web/
├── robots.txt                                  # Crawl directives & sitemap location
├── sitemap.xml                                 # Canonical XML index of all public URLs
├── manifest.json                               # Web app manifest with V-Fix branding
├── index.html                                  # App entry with meta, OpenGraph, JSON-LD, crawlable fallback
├── assets/
│   └── css/
│       └── seo-site.css                        # Shared responsive luxury styling for static pages
├── about/
│   └── index.html                              # Company mission, values, and story
├── features/
│   ├── garage-management/index.html            # Workshop operations & multi-bay scheduling
│   ├── repair-job-management/index.html        # Digital job cards & status workflows
│   ├── invoice-management/index.html           # GST invoicing, estimates, and payment tracking
│   └── vehicle-maintenance/index.html          # Maintenance intelligence & service reminders
├── solutions/
│   └── garage-owners/index.html                # Dedicated B2B garage owner landing page
├── customers/
│   └── find-garages/index.html                 # Dedicated B2C customer service discovery page
├── pricing/
│   └── index.html                              # Transparent pricing tiers
├── faq/
│   └── index.html                              # Knowledge base with Schema.org FAQPage JSON-LD
├── contact/
│   └── index.html                              # Support channels and operations hubs
├── privacy-policy/
│   └── index.html                              # Multi-tenant data isolation & privacy policy
├── terms-and-conditions/
│   └── index.html                              # Terms of service and platform agreements
└── garages/
    └── index.html                              # Public garage directory and service discovery
```

---

## 2. Technical Indexing Controls

### Robots.txt Configuration (`/robots.txt`)
- **Publicly Allowed:** `/`, `/about`, `/features/`, `/solutions/`, `/customers/`, `/pricing`, `/faq`, `/contact`, `/privacy-policy`, `/terms-and-conditions`, `/garages/`, `/icons/`, `/assets/`, `/sitemap.xml`.
- **Crawling Denied (Private App Boundaries):**
  - `Disallow: /customer/`
  - `Disallow: /merchant/`
  - `Disallow: /messages/`
  - `Disallow: /chat/`
  - `Disallow: /auth`
- **Sitemap Directive:** `Sitemap: https://vfix.app/sitemap.xml`

### XML Sitemap Architecture (`/sitemap.xml`)
- Strict conformity to the `sitemaps.org` schema (`http://www.sitemaps.org/schemas/sitemap/0.9`).
- Exclusively includes canonical HTTPS URLs with accurate `priority` and `changefreq` indicators.
- Automatically excludes private user dashboards, internal invoice views, and authenticated routes.

---

## 3. Schema.org Structured Data Specifications

| Page | Structured Data Type | Key Properties Included |
| :--- | :--- | :--- |
| `index.html` | `Organization`, `WebSite`, `SoftwareApplication` | `@id`, `name`, `url`, `logo`, `slogan`, `contactPoint`, `operatingSystem`, `offers`, `featureList` |
| `/solutions/garage-owners` | `SoftwareApplication` | `name`, `applicationCategory: BusinessApplication`, `operatingSystem`, `offers` |
| `/customers/find-garages` | `Service` | `serviceType`, `provider`, `description` |
| `/features/*` | `SoftwareApplication` | `name`, `applicationCategory`, `description` |
| `/pricing` | `Product`, `AggregateOffer` | `name`, `lowPrice: 0`, `highPrice: 2499`, `priceCurrency: INR` |
| `/faq` | `FAQPage` | `mainEntity: [ { Question, acceptedAnswer: { text } } ]` |
| `/about` | `AboutPage` | `name`, `url`, `description` |
| `/contact` | `ContactPage` | `name`, `url` |
| `/garages/` | `ItemList` | `name: V-Fix Verified Automotive Repair Network` |

---

## 4. Hosting, Caching & Performance Architecture

In `firebase.json`:
- Exact static files in `public` (`build/web`) take precedence over SPA rewrites.
- `/sitemap.xml`: Served with `Content-Type: application/xml; charset=utf-8` and `Cache-Control: public, max-age=3600`.
- `/robots.txt`: Served with `Content-Type: text/plain; charset=utf-8` and `Cache-Control: public, max-age=3600`.
- Static CSS & Image assets: Served with `Cache-Control: max-age=31536000, immutable`.
- Core Web Vitals targets:
  - **LCP (Largest Contentful Paint):** $< 1.0\text{s}$ for all static landing pages.
  - **CLS (Cumulative Layout Shift):** $0.00$ (zero dynamic reflow).
  - **INP (Interaction to Next Paint):** $< 50\text{ms}$ (pure CSS navigation).

---

## 5. Search Console & Verification Readiness

- Prepared for Google Search Console domain and URL-prefix verification.
- Meta tags and Open Graph cards verified for WhatsApp, Facebook, LinkedIn, and Twitter/X previews with `Icon-512.png`.

