# Podcasterium iOS prototype (SwiftUI)

**Status: experiment, not the plan.** The recorded decision
(`docs/DECISIONS.md`, 2026-09-11) keeps Flutter for mobile. This directory
answers a narrower question: *what does a native SwiftUI client over the same
CDN contract look like, and how much of the product does it reach in a day?*
It is also the candidate shape for the tvOS client mentioned in
`docs/10-tech-stack-review.md` section 5, since Flutter cannot target tvOS.

No third-party dependencies. iOS 17+, Xcode 26.

## What it does

- **Home**: channel index from the CDN, a "latest episodes" rail, channel
  search (local filter), pull to refresh.
- **Channel**: header, description, tags, episode list with thumbnails
  (WebP variant first, PNG fallback), date, duration, abstract.
- **Episode**: everything loaded in parallel from the static contract
  (`info`, `summary`, `outline`, `article`, `diarized.srt`, the English
  overlays, and the three media probes in the contract's mandatory order).
  - Video via `AVKit.VideoPlayer` (fullscreen, PiP, AirPlay come with it);
    audio-only episodes get cover art and a transport.
  - Tabs: **Article** (Markdown sections with screenshot and "play from
    here"), **Chapters** (AI outline, or platform chapters as fallback,
    current chapter highlighted), **Summary** (abstract, key points, topics,
    speakers, mentions), **Transcript** (diarized cues with speaker names
    from the summary, tap to seek, follows playback).
  - Source / EN toggle when the `.en.json` overlays exist.
  - Background audio with lock-screen info and remote commands
    (play, pause, skip 15 s, scrub).
- **Mini player**: one app-wide `PlaybackSession`; leaving the episode
  screen keeps playing and shows a bar above the tab area (tap to reopen,
  long-press to stop). Reopening the playing episode is instant.
- **Resume**: local "continue where you left off" per episode
  (`UserDefaults`, saved every 5 s and on pause; dropped near start or end).
- **Deep links** (`DeepLink.parse`): `podcasterium://episode/<id>[?t=754]`,
  `podcasterium://channel/<id>`, the upstream web routes on any host
  (`/v/:id`, `/v/:id/en`, `/m/:id/t/:seconds`, `/episode/:id`, `/c/:slug`)
  and YouTube links (`watch?v=`, `youtu.be/`, `shorts/`). A timestamp
  autoplays from there; `/en` or `lang=en` opens the English overlay.

## What it does not do

Sign-in, favorites, progress sync, subscription (all Supabase-side),
keyword and semantic search (Meilisearch and the person hub), clips, the
person hub, Android TV. Universal links (`https://podcasterium.com/...`
opening the app) need the associated-domains entitlement and an AASA file
on the server; the parser is ready, the registration is not. Nothing here
is brand-specific except `BrandConfig`.

## Build and run

```bash
cd prototypes/ios
xcodegen generate                    # writes Podcasterium.xcodeproj (git-ignored)
xcodebuild -project Podcasterium.xcodeproj -scheme Podcasterium \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath build build
xcodebuild -project Podcasterium.xcodeproj -scheme Podcasterium \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath build test
```

Any installed simulator works; pick one from
`xcrun simctl list devices available` if `iPhone 17` is not present. Verified
on 12 Sep 2026: 15 tests pass on iPhone 17 (iOS 26.3.1) — 14 unit tests and
one UI test that drives the real app against the live CDN (needs network).

Debug launch arguments: `-url <any accepted link>` (repeatable),
`-episode <youtubeId>`, `-channel <id>`. Example:

```bash
xcrun simctl launch booted com.podcasterium -url "podcasterium://episode/e4aPRlJ04fc?t=754"
```

Or open the generated project in Xcode and press Run.

## Layout

```
Podcasterium/
  App/        entry point, navigation routes, deep-link dispatch, BrandConfig
  Core/       CDN URL builder, HTTP client, models, EpisodeData loader,
              DeepLink parser, ProgressStore
  Features/   Home, Channel, Episode (player, tabs), Player (session, mini player)
  Shared/     load state, cached image view, chips, Markdown text
PodcasteriumTests/
  SRT parser, model decoding, deep-link parsing
PodcasteriumUITests/
  mini player survives leaving the episode screen (live CDN)
```

The models mirror upstream `lib/models/*.dart` field by field; the wire keys
keep their upstream names (`title_hr`, `avg_magisterium_score`) while the
Swift properties use the neutral names from `docs/02-brand-layer-and-rebranding.md`.
