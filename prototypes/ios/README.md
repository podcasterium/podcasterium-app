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

## What it does not do

Sign-in, favorites, progress sync, subscription (all Supabase-side),
keyword and semantic search (Meilisearch and the person hub), clips, the
person hub, deep links, a mini player that survives leaving the episode
screen, Android TV. Nothing here is brand-specific except `BrandConfig`.

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
on 12 Sep 2026: 9 tests pass on iPhone 17 (iOS 26.3.1).

Or open the generated project in Xcode and press Run.

## Layout

```
Podcasterium/
  App/        entry point, navigation routes, BrandConfig
  Core/       CDN URL builder, HTTP client, models, EpisodeData loader
  Features/   Home, Channel, Episode (player, tabs)
  Shared/     load state, cached image view, chips, Markdown text
PodcasteriumTests/
  SRT parser, model decoding, URL builders
```

The models mirror upstream `lib/models/*.dart` field by field; the wire keys
keep their upstream names (`title_hr`, `avg_magisterium_score`) while the
Swift properties use the neutral names from `docs/02-brand-layer-and-rebranding.md`.
