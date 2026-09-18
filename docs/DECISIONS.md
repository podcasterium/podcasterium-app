# Decision log

Short, dated records of decisions that shape this repository. Newest last.
Each entry says what was decided, why, and where the detail lives. The git
history has the diffs; this file has the reasoning that a diff cannot show.

| Date | Decision | Why | Detail |
| :-- | :-- | :-- | :-- |
| 2026-09-10 | Podcasterium is derived from DOMOVINA.ai, not written from scratch | Measured: ≈ 96 % of the upstream code is domain-neutral; the release pipeline is done | `docs/00-source-app-analysis.md` |
| 2026-09-10 | Everything persisted in this repository is English only; the owner converses in Croatian | The project will be fully open source for a global audience; upstream is Croatian throughout | `CLAUDE.md` |
| 2026-09-10 | **No fork.** Development stays in `domovina.ai`; Podcasterium must follow it without a second git history | Owner decision; a fork diverges within weeks at upstream's ≈ 3 commits/day | `docs/01-…` (superseded), `docs/08-…` |
| 2026-09-10 | Architecture: `podcast_core` package extracted upstream + thin app shells; this repo holds no application code | Compiler-enforced white-label boundary; DOMOVINA.ai becomes the staging environment of the core; upstream CI builds the Podcasterium shell as a tripwire | `docs/08-white-label-architecture.md` |
| 2026-09-10 | Brand layer (`BrandConfig`, `Endpoints`, `FeatureFlags`, `DomainScore`) is built upstream before anything ships here | It is tested on the live app with real users and the nightly gate | `docs/02-brand-layer-and-rebranding.md` |
| 2026-09-10 | Phase 1 shares the DOMOVINA backend and corpus; Certilia, voting, Pinka, channel ownership, domain score and Cal booking are flagged off | Proves build, identity and stores first; the corpus problem is a pipeline problem, not a client problem | `docs/06-backend-and-corpus.md` |
| 2026-09-10 | Positioning: open-source, white-label podcast *reader* engine for vertical communities and long-tail languages — not a generic consumer AI podcast app | Market research: consumer niche held by Snipd/Podwise, platforms absorbing features (Huxe shutdown); nobody offers article + person graph + TV + open source + white-label | `docs/09-market-research.md` §7 |
| 2026-09-10 | Evaluate buying the global corpus (Podscan API and peers) instead of transcribing the world | Podscan already covers 4.8 M shows; our value is article, chapters, person graph and domain score above the transcript; also dissolves the "article in source language" blocker | `docs/09-…` §7.3, `docs/06-…` §5.1 |
| 2026-09-10 | Nothing is developed until the owner confirms D1–D7 (domain, bundle ID, Apple team, colours/logo, architecture, operator, pricing) | Each blocks identities and accounts that cannot be changed after first store upload | `docs/07-roadmap-and-estimates.md` §0 |

| 2026-09-10 | Domain: `podcasterium.com`; bundle ID and Android applicationId: `com.podcasterium` | Owner decision (D1, D2). Two-segment reverse-domain id is valid on both stores; purchase of the domain pending | `docs/03-identities-and-platforms.md` §1 |
| 2026-09-10 | Source hosted publicly at `github.com/podcasterium/podcasterium-app` | Open-source from day one; the GitHub organization `podcasterium` was created by the owner the same day | `README.md` |

| 2026-09-10 | License: MIT | Maximum adoption for a white-label engine; instances need not publish their changes. Applies to this repository; the upstream `domovina.ai` remains under its own terms until the `podcast_core` package is published | `LICENSE` |
| 2026-09-11 | Stack stays Flutter for iOS, Android and Android TV; the public web reader gets a separate server-rendered front (Next.js or Astro on Cloudflare) over the same CDN contract; no rewrite, tvOS skipped | Nothing in the feature set needs native code except tvOS; the only real weakness is Flutter web (SEO, text, first load), which is fixed at the web seam, not by rewriting 58.6 k lines (estimate 8–14 person-months) | `docs/10-tech-stack-review.md` |
| 2026-09-18 | Upstream extraction started, boundary first: A3 (`main.dart` split) and A6 (`packages/podcast_core`, pub workspace) landed before the brand layer A1, on branch `feat/podcast-core` in `domovina.ai` | With the package boundary in place every later brand step is verified by building a second shell instead of by grep; measured behaviour-preserving (analyze clean, 368 tests, web build) | upstream `CLAUDE.md` section "Raspored", `docs/08-…` §4 |
| 2026-09-18 | Asset contract: the core loads brand images (logo, splash) from the **shell's** bundle at the paths in `BrandConfig`; Google "G" stays with the core | Brand images must not ship inside the core; core package tests use a fake asset bundle until `BrandConfig` wiring is complete | upstream `CLAUDE.md` section "Raspored" |
| 2026-09-18 | The shell depends on `podcast_core` by git tag from a repo to be published under the `podcasterium` GitHub organization; local development uses a git-ignored `pubspec_overrides.yaml` pointing at the upstream monorepo | `domovina.ai` is private, so the package must be published separately (subtree split per tag); a committed path dependency would only build on the owner's machine | `pubspec.yaml`, `pubspec_overrides.example.yaml` |
| 2026-09-18 | Custom URL scheme `com.podcasterium://` (mirrors the bundle ID, like upstream); placeholder colours seed `#2B4C7E` / accent `#D97706` until D4 | Assumption by the assistant pending owner confirmation; both are single-line changes in `lib/brand.dart` | `lib/brand.dart`, `docs/03-…` §1 |

## How to add an entry

One row, one decision, past tense, with the document that carries the
argument. If a decision is reversed, add a new row that says so and link the
old one; do not edit history.
