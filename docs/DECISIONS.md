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

## How to add an entry

One row, one decision, past tense, with the document that carries the
argument. If a decision is reversed, add a new row that says so and link the
old one; do not edit history.
