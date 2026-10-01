# Podcasterium

**Watch, listen to and read podcasts.**

Podcasterium turns a two-hour podcast into something you can read in ten
minutes, and then play from exactly the right second. Every processed
episode gets chapters, a transcript that knows who is speaking, an
AI-written article chapter by chapter, and a page for every person who
appears or is mentioned.

[podcasterium.com](https://podcasterium.com) ·
[Google Play](https://play.google.com/store/apps/details?id=com.podcasterium) ·
[App Store](https://apps.apple.com/app/id6815415892) ·
License: [MIT](LICENSE)

## Features

- **Watch or listen** with a chapter list next to the player, background
  audio and speed control.
- **Read** an article that retells the episode chapter by chapter, with the
  timestamp of every section one tap away.
- **Speakers everywhere.** Diarized speaker labels in the player and the
  transcript.
- **Search** the whole archive by keyword or by meaning.
- **Person pages** with every episode someone speaks in or is talked about,
  and the minute of each mention.
- **One app** on iPhone, iPad, Android, Android TV and the web.
- **Podcasterium Plus**, an optional subscription through RevenueCat
  (monthly or yearly, 7-day free trial).

## Architecture

This repository is a thin Flutter shell. All application code lives in
`podcast_core`, an open white-label podcast engine; the shell holds only
what makes the app Podcasterium:

| Path | Contents |
| :-- | :-- |
| `lib/main.dart` | Entry point: starts the core with the Podcasterium brand |
| `lib/brand.dart` | `BrandConfig`: name, colours, endpoints, feature flags, store IDs |
| `android/`, `ios/`, `web/` | Platform projects with Podcasterium identities |
| `assets/brand/`, `store-assets/` | Icons, splash, store screenshots and graphics |
| `infra/edge-proxy/` | Cloudflare Worker that serves the backend under podcasterium.com names |
| `prototypes/ios/` | A SwiftUI experiment, not part of the shipping app |

Backend: Supabase (accounts, sync, edge functions), Cloudflare (R2 CDN for
processed episodes, Pages and Workers for the web), Meilisearch (keyword
search) and a retrieval service for semantic search and person pages. The
app addresses all of them through `*.podcasterium.com` hosts.

## Building

```bash
# against the pinned core tag (once it is published)
flutter pub get && flutter run

# against a local checkout of the core
cp pubspec_overrides.example.yaml pubspec_overrides.yaml   # git-ignored
flutter pub get && flutter run
```

Build-time configuration (Supabase, Meilisearch and RevenueCat keys) comes
from `.env`; see `.env.example`. `flutter analyze` and `flutter test` must be
clean; `test/brand_test.dart` checks that no foreign brand identity leaks
into this one.

Everything in this repository is written in English; see `CLAUDE.md`.

## Engineering notes

`docs/` holds the engineering record behind the app: how the white-label
engine was extracted, the identities and platform setup, the build and
deploy pipeline, the store launch, backend and corpus, the roadmap, market
research and the technology stack review. Open launch work is tracked in
[`docs/TODO-launch.md`](docs/TODO-launch.md) and decisions in
[`docs/DECISIONS.md`](docs/DECISIONS.md).
