# Override Inventory — `layouts/` vs Blowfish v2.82.0 vendor

Date: 2026-07-17
Method: Recursively diff every `layouts/**/*.html` against the same relative path in `_vendor/github.com/nunocoracao/blowfish/v2/layouts/`.
Rule: identical → delete (falls back to theme); different or no counterpart → keep.

## Counts

- Deleted: 85 files during the v2.82.0 audit, plus 4 additional files removed after the v2.104 rebase check (see below)
- Kept: 19 files (modified, rebased, or custom)

## Kept Overrides

| File | Status | Customization Intent / Rebase Summary |
|------|--------|---------------------------------------|
| `404.html` | Modified | Plucky-branded 404 layout with Home / Archive links. |
| `_default/baseof.html` | Rebased | Added `plucky-page`, `plucky-kind-*`, `plucky-home-page`/`plucky-inner-page` classes; updated deprecated `.Site.LanguageCode` to `.Site.Language.Locale`. |
| `_default/list.html` | Rebased | Plucky page-hero header, plucky- classes, empty state; removed obsolete `js/page.js` reference that no longer exists in v2.104.0. |
| `_default/simple.html` | Modified | Plucky- classes and page-hero header for simple pages. |
| `_default/single.html` | Rebased | Plucky- classes, restructured content shell; updated `.Site.Data.authors` → `hugo.Data.authors`; removed obsolete `js/page.js` reference. |
| `_default/term.html` | Rebased | Plucky header/empty states; removed obsolete `js/page.js` reference. |
| `index.html` | Modified | Fixed `templates.Exists` path and fallback partial path. |
| `partials/article-link/card.html` | Modified | Custom Plucky card layout (image background, ambient fallback, kicker, footer). |
| `partials/article-link/simple.html` | Modified | Custom Plucky row layout (index number, kicker, summary, external marker). |
| `partials/comments.html` | Custom | Utterances configuration: repo, issue-term, label, color-scheme theme. |
| `partials/head.html` | Rebased | Rebased onto v2.104.0 asset pipeline (slice/append instead of newScratch); preserved Google Fonts, git meta, theme-color, Firebase config. |
| `partials/header/basic.html` | Rebased | Rebased onto v2.104.0 component-based header; preserved `plucky-main-menu` and `plucky-brand` classes. |
| `partials/header/fixed-fill-blur.html` | Rebased | Rebased onto v2.104.0 sticky header with background-blur.js; preserved `plucky-header-shell` class. |
| `partials/home/custom.html` | Custom | Fully custom homepage; removed Teaching tile (now Archive + About only). |
| `partials/term-link/card.html` | Modified | Custom Plucky term card layout (INDEX ENTRY label, count badge). |
| `shortcodes/alert.html` | Modified | Plucky-branded alert classes. |
| `shortcodes/button.html` | Modified | Plucky-branded primary button classes. |
| `shortcodes/figure.html` | Modified | Custom responsive srcset breakpoints. |
| `shortcodes/lead.html` | Modified | Plucky-branded lead class. |

## Deleted as Obsolete after v2.104.0 Rebase

The following files were kept after the v2.82.0 audit but were removed after rebasing because the v2.104.0 theme no longer references them:

- `partials/header/header-option.html`
- `partials/header/header-option-nested.html`
- `partials/header/header-option-simple.html`
- `partials/header/header-mobile-option-nested.html`
- `partials/header/header-mobile-option-simple.html`
- `partials/translations.html` (replaced by `partials/header/components/translations.html` in the theme)

## Non-HTML Overrides Also Touched During Rebase

- `layouts/_default/rss.xml`: fixed deprecated `site.LanguageCode` → `site.Language.Locale`.
- `layouts/_default/sitemap.xml`: fixed deprecated `.Language.LanguageCode` → `.Language.Locale`.

## Rebase Risk Notes (v2.82.0 → v2.104.0)

The v2.104.0 header was restructured into `partials/header/components/` and the resource pipeline switched from `newScratch` to `slice/append`. The following overrides were rebased to match:

- `partials/head.html`
- `partials/header/basic.html`
- `partials/header/fixed*.html`

The following obsolete references were removed:

- `js/page.js` (removed from v2.104.0; Firebase view tracking no longer loaded).
- `header/header-option*.html` and `header/header-mobile-option*.html` (replaced by inline templates in `components/desktop-menu.html` and `components/mobile-menu.html`).
- `partials/translations.html` (replaced by `header/components/translations.html`).

All remaining overrides are expected to work with v2.104.0; build passes with zero errors and zero warnings.

## Post-Check Removals (performed by check agent)

After comparing against the v2.104.0 vendor, the following files were removed:

- `layouts/partials/header/fixed-fill.html` — identical to v2.104.0 vendor original
- `layouts/partials/header/fixed-gradient.html` — identical to v2.104.0 vendor original
- `layouts/partials/header/fixed.html` — identical to v2.104.0 vendor original
- `layouts/_default/taxonomy.html` — not used in v2.104.0; the vendor's `terms.html` handles taxonomy list pages, and this override was never selected
