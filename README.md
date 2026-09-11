# Podcasterium — application

**Status: documentation and plan only. There is no code in this repository yet.**

Source: <https://github.com/podcasterium/podcasterium-app> · License: [MIT](LICENSE) · Domain (pending purchase): `podcasterium.com` · Bundle ID: `com.podcasterium`

Podcasterium is the global version of [DOMOVINA.ai](https://domovina.ai)
(`/Users/ms/git/domovinatv/domovina.ai`, GitHub `domovinatv/ai.domovina.tv`) —
a Flutter client for watching, listening to and **reading** podcasts: video
plus an AI-written article by chapter, diarized speakers, a person hub
(speaks / is mentioned), keyword and semantic search, Android TV, background
audio.

DOMOVINA.ai is finished and in production on the web, the App Store and
Google Play, serving a niche of Croatian Catholic and patriotic podcasts.
Podcasterium is the **same product without that context**, under a new
brand, bundle ID and package name, for any podcast in the world.

This repository currently holds the analysis of the source application and
the proposals for reaching a standalone iOS/Android/web app **without a
rewrite**.

Everything persisted in this repository is in English — see `CLAUDE.md`.

## Documents

| # | Document | Answers |
| :-- | :-- | :-- |
| 00 | [Source app analysis](docs/00-source-app-analysis.md) | What DOMOVINA.ai is, how domain-bound it is, what ports over — measured on `cfb45aa`, 10 Sep 2026 |
| 01 | [Strategy: fork or flavor](docs/01-strategy-fork-vs-flavor.md) | How to get two apps out of one codebase, and why the brand layer goes upstream before the fork |
| 02 | [Brand layer and rebranding](docs/02-brand-layer-and-rebranding.md) | Exact inventory of everything carrying a name, colour or logo, and how to centralize it |
| 03 | [Identities and platform configuration](docs/03-identities-and-platforms.md) | Bundle ID, package name, URL scheme, App Links / AASA, Supabase OAuth, RevenueCat, passkeys |
| 04 | [Build and deploy pipeline](docs/04-build-and-deploy.md) | Web (Cloudflare Pages), iOS (ASC API-key signing), Android (keystore + Play API), nightly |
| 05 | [Store launch](docs/05-store-launch.md) | App Store and Google Play checklists, compliance forms, screenshots, lessons from the first launch |
| 06 | [Backend and corpus](docs/06-backend-and-corpus.md) | What Podcasterium shares with the DOMOVINA backend, what is flagged off, where the real cost of a global product is |
| 07 | [Roadmap and estimates](docs/07-roadmap-and-estimates.md) | Phases, order, days, risks, definition of done |
| 08 | [White-label architecture](docs/08-white-label-architecture.md) | **Current recommendation.** Core package + thin app shells: DOMOVINA.ai as the development/staging environment of Podcasterium, with no diverging git history |
| — | [Decision log](docs/DECISIONS.md) | Dated record of every decision that shapes this repository, with the reasoning and the document behind it |
| 09 | [Market research](docs/09-market-research.md) | Who else builds "YouTube for podcasts with an AI layer" (platforms, Snipd, Podwise, Podscan, Radar, Podchaser…), what the 5 M-podcast TAM really is, and where the gap is — web research, 10 Sep 2026 |
| 10 | [Technology stack review](docs/10-tech-stack-review.md) | Whether Flutter is still the right choice given the feature set (yes for mobile and Android TV), where it is weak (web reader), and what a greenfield stack would look like in 2026 |

## Rules for these documents

Inherited from the upstream repository (`CLAUDE.md`, rule *documentation is
verified, not trusted*):

- Every `lib/…`, `android/…`, `ios/…`, `web/…`, `scripts/…` path refers to the
  upstream repository `domovina.ai` and **exists** at that location on the day
  of writing (checked 10 Sep 2026: 93 of 93 existing paths). Verification, run
  from the upstream repo:

  ```bash
  cd /Users/ms/git/domovinatv/domovina.ai
  ./scripts/verify-doc-refs.sh /Users/ms/git/podcasterium/podcasterium-app/docs/*.md
  ```

  Expected "missing" hits are deliberate: future paths (`lib/brand/`,
  `assets/brand/`, `docs/podcasterium/`), the intentionally absent
  `web/_redirects`, line-number suffixes (`file.dart:12`) the script does not
  strip, and this repository's own documents.
- Every number with a decimal or a count has a command that reproduces it
  (`docs/00-source-app-analysis.md` §9).
- Effort estimates are labelled as estimates.

## Upstream repositories — quick pointers

| What | Where |
| :-- | :-- |
| Client | `/Users/ms/git/domovinatv/domovina.ai` |
| Pipeline (episode processing) | `/Users/ms/git/domovinatv/fetch.domovina.tv` |
| Database, auth, edge functions | `/Users/ms/git/domovinatv/domovina-api` |
| Semantic search, person hub | `/Users/ms/git/domovinatv/domovina-rag` |
| Clip cutting | `/Users/ms/git/domovinatv/domovina-cutter` |
| Earlier Podcasterium analyses (Croatian) | `domovina.ai/docs/podcasterium_*.md` (14 Aug 2026) |
