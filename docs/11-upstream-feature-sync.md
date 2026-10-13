# 11 — Upstream feature sync after 1.0.3

State on 10 Oct 2026. What DOMOVINA.ai shipped since the core Podcasterium
builds from, which of it Podcasterium takes, in what order, and what the
Shipaton 2026 rules allow while judging runs.

## Status — 10 Oct 2026, evening (web updated 13 Oct 2026)

Steps 1, 2 and 5 of §4 are done, step 3 is half done:

- Core `b0539ef` (merge of upstream v2.0.178) and `e2c7272` (sponsor OG
  tags follow the brand) are on `feat/podcast-core`, pushed. New flags
  `homeSnapshot` and `youtubeWatch` are off for Podcasterium; sponsor
  routes and live sponsored moments follow `flags.pinka`.
- Shell 1.0.4+13 with the brand-neutral boot splash.
- Play internal: 1.0.4 (13). TestFlight: 1.0.4 (13) uploaded.
- Web: **production since 13 Oct 2026, 12:10 CEST**, on the owner's
  explicit decision, during the last hours of the Judging Period. The same
  `build/web` artifact that served the preview
  (`https://preview-1-0-4.podcasterium.pages.dev`) was deployed with
  `--branch=main` (deployment `762154c4`). `podcasterium.com/version.json`
  answers 1.0.4 (13); `/`, `assetlinks.json`, the AASA and `sitemap.xml`
  return 200, and the home screen renders in a real browser.
- **Open, deferred by the owner on 10 Oct 2026:** one real sign-in and one
  purchase on 1.0.4 (13), on TestFlight and on Play internal (§4 step 3).
  It needs a physical device and a sandbox account, so the assistant cannot
  do it. It must be done before 1.0.4 goes to either store's production.
- Waiting: the store releases (§4 step 4, after 13 Oct 21:00 CEST and the
  1.0.3 approval; on 13 Oct the owner chose to leave both stores untouched
  for now). The owner checked the
  preview and found it clearly faster than podcasterium.com.
- **Step 5 done the same evening:** upstream `main` was fast-forwarded to
  `feat/podcast-core` (`e2c7272`), so DOMOVINA.ai itself now builds from
  `packages/podcast_core`. Checked first in the core worktree: DOMOVINA
  shell test, `flutter build web --release --wasm` (2.0.178) and
  `flutter build apk --debug`; `scripts/deploy.sh` and
  `scripts/verify-doc-refs.sh` already used the package paths.

### How a sync works from now on

`feat/podcast-core` and upstream `main` are the same history. To take a new
DOMOVINA.ai release into Podcasterium:

```bash
cd ~/git/domovinatv/.podcast-core     # worktree, branch feat/podcast-core
git fetch origin && git merge --ff-only origin/main
cd ~/git/podcasterium/podcasterium-app
flutter pub get && flutter analyze    # pubspec_overrides.yaml points at the worktree
```

No more manual merges or moving files out of `lib/`. New upstream features
still need a brand check (new `FeatureFlags`, hard-coded brand strings) before
a Podcasterium release. Publishing the core under a git tag
(`podcast_core` `core-v0.1.0` in `pubspec.yaml`) is still open.

Known gap seen while checking, older than this sync: the episode loading
screen lists its steps (summary, chapters, article, transcript) in Croatian
in the English interface; the labels are hard-coded in core
`packages/podcast_core/lib/services/data_service.dart`.

## 0. Principle

DOMOVINA.ai is always equal to or ahead of Podcasterium in features. It is
the staging environment: a feature reaches Podcasterium only after it has run
in DOMOVINA.ai production. Podcasterium never gets a feature first and never
carries a feature fork (see `08-white-label-architecture.md`).

## 1. Where the two lines stand

| | commit / version | date |
|---|---|---|
| Upstream `main` | `df7c21a`, v2.0.178+200 | 10 Oct 2026 |
| Core branch `feat/podcast-core` (what Podcasterium builds from) | `a719d6e`, last main merged = v2.0.158 (`f4093c8`) | 1 Oct 2026 |
| Merge base | `4315358` | 26 Sep 2026 |

58 upstream commits are not in the core yet; the core has 42 commits of its
own (brand layer, legal, account deletion) that are not on `main`.

```bash
# run in the upstream repo
git fetch origin
W=../.podcast-core
MB=$(git merge-base origin/main $(git -C $W rev-parse HEAD))
git rev-list --count $MB..origin/main                              # 58
git rev-list --count origin/main..$(git -C $W rev-parse HEAD)      # 42
git log --no-merges --oneline $MB..origin/main
```

**The structural problem.** DOMOVINA.ai itself does not run on
`podcast_core` yet. Every sync is a manual merge of `main` into
`feat/podcast-core`, and new files land in `lib/` instead of
`packages/podcast_core/lib/` and must be moved by hand. The diff since the
merge base already touches 77 files under `lib/` (+11,544 / −923):

```bash
git diff --stat 4315358 origin/main -- lib | tail -1
```

The longer the core branch stays off `main`, the more expensive each sync
gets. Landing `feat/podcast-core` on upstream `main` (docs/08, phase 0) is
what turns "DOMOVINA.ai is staging" from a manual merge into a tag bump.

## 2. What upstream shipped since v2.0.158

### 2.1 Take — episode experience (batch A)

| Upstream | Feature |
|---|---|
| v2.0.166–167 | Episode screen in three columns instead of a drawer, immersive landscape, full subtitles; chapter title placed under the real header in landscape |
| v2.0.168 | Word-by-word subtitle highlighting from `words.json`, caption under the player in portrait (`lib/widgets/subtitle_caption.dart`) |
| v2.0.170 | "Find in episode": transcript search that jumps to the exact second |
| v2.0.171 | Article scrolls along with playback; section title on its own line |
| v2.0.172 | Article ticker advancing in 15 s steps with a progress bar |

`words.json` exists only for part of the archive (upstream
`docs/2026-10-06-titlovi-rijec-po-rijec.md`); the caption falls back to
segment-level subtitles, which is acceptable for Podcasterium.

### 2.2 Take — speed and robustness (batch B)

| Upstream | Feature | Podcasterium note |
|---|---|---|
| v2.0.172 | Guest without a session instead of anonymous sign-ins | Same Supabase project, so this also stops Podcasterium creating anonymous users |
| v2.0.173 | Home renders without waiting for the catalogue; disk cache for CDN JSON | **Brand gate needed.** `channels/data/home.json` (`lib/models/home_snapshot.dart`) is the DOMOVINA.ai home selection and is already served through `cdn.podcasterium.com`. Podcasterium has its own featured channels, so it must either ignore `home.json` (use the existing fallback path) or get a per-brand file from the pipeline. Default: a `BrandConfig` switch, off for Podcasterium |
| v2.0.174 | `episode.json` bundle per episode, prefetch on intent, article before subtitles (`lib/models/episode_bundle.dart`) | Pipeline does not produce `episode.json` yet; the client falls back, so it is safe to take |
| v2.0.177 | Deterministic order of the "Latest episodes" rail | — |
| v2.0.175–176 | Web boot splash stays until the first Flutter frame | Lives in each shell's `web/index.html`. Podcasterium's `web/index.html` has no boot splash at all, so port the mechanism with a brand-neutral splash |

### 2.3 Hold — needs a product decision

| Upstream | Feature | Why hold |
|---|---|---|
| v2.0.169 | Standalone `/yt/:videoId` screen with the official youtube-nocookie embed (`lib/screens/youtube_watch/`) | Plays any YouTube video in the app. Podcasterium was questioned under App Review 5.2.3 (third-party media); add it behind a brand flag, off, and decide after 1.0.3 is approved |

### 2.4 Do not take — DOMOVINA.ai only

| Upstream | Feature | Why |
|---|---|---|
| v2.0.159–165 | Pinka support wall: SEPA Instant via Monerium, OG images on the wall | Croatian/EU bank-transfer support for creators; Podcasterium monetises through RevenueCat. Stays disabled in the brand flags |
| `4603170` | Self-serve sponsor moments (store, checkout, display; `lib/screens/sponsor/`) | Built on the Pinka SEPA flow for the DOMOVINA TV channel, not deployed upstream yet. Possible later as a B2B white-label offer, not now |
| v2.0.178 | Gospel quotes in the boot splash | Brand content. The splash mechanism is taken (2.2), the quotes are not |

### 2.5 Planned upstream — take once shipped there

| Upstream plan | Why it matters for Podcasterium |
|---|---|
| Continue-watching sync across devices (`docs/plans/2026-10-10-nastavi-gledati-sinkronizacija.md`, plan only) | Buying Plus requires sign-in, so Podcasterium's paying users are exactly the multi-device users this fixes |
| AI chat assistant (`docs/plans/2026-08-01-ai-chat-asistent.md`) | Candidate for real Plus value beyond search results and a badge |

## 3. Shipaton 2026 rules that apply now

Source: `https://revenuecat-shipaton-2026.devpost.com/rules`, read 10 Oct
2026.

- **Judging Period: 1 Oct 2026 00:00 PDT – 13 Oct 2026 12:00 PDT (21:00
  CEST).** Winners are announced 21 Oct 2026 09:00 PDT.
- The project must stay available free of charge to the sponsor and the
  judges for testing until the Judging Period ends.
- It must install, run consistently and "function as depicted in the video
  and/or expressed in the text description".
- After the Submission Period the **Devpost submission** may not be changed;
  the project page in the Devpost portfolio may still be updated.
- Nothing forbids continuing development. The judging criteria ask for the
  iterations run after launch, so post-launch work counts in favour.

What that means in practice:

| Channel | Until 13 Oct 21:00 CEST | After |
|---|---|---|
| Feature branches, core merges | free | free |
| TestFlight, Play internal | free (judges do not see them) | free |
| podcasterium.com web | allowed, but it is the "Try it out" link on Devpost: deploy only after the change is verified, never anything that removes or breaks a feature shown in the video | free |
| App Store / Play production | only the approval of 1.0.3 already in review; no new production build | normal releases |
| Plus contents and price | unchanged; the submission text describes them | free, but keep the paywall honest (list only what exists) |

Eligibility caveat, for awareness: the rules require the first public version
to be released during the Submission Period (ended 1 Oct 2026). Play went live
around 2–3 Oct (IARC live-rating notice on 3 Oct) and the App Store version is
still in review. Nothing in this plan changes that.

## 4. Order of work

1. **Sync branch.** Merge upstream `main` (v2.0.178) into
   `feat/podcast-core`, the same way as `f4093c8` (v2.0.158). Move new files
   from `lib/` into `packages/podcast_core/lib/`. Add the two brand switches:
   `home.json` snapshot (off) and the `/yt` screen (off). Estimate: 1–2
   working days, mostly conflict resolution in the episode screen.
2. **Shell.** Brand-neutral web boot splash in `web/index.html`. Version
   1.0.4+13.
3. **Test tracks.** TestFlight, Play internal and a preview web deploy, with
   one real sign-in and one purchase per platform
   (see the end-to-end rule from the 1.0.0 launch).
4. **After 13 Oct 21:00 CEST and once 1.0.3 is approved:** production
   web deploy, then 1.0.4 to both stores. iOS metadata must never mention
   Android or Google Play (rejection under 2.3.10 on 9 Oct 2026).
5. **Structural:** land `feat/podcast-core` on upstream `main`, so that
   every DOMOVINA.ai release is also a core release and Podcasterium follows
   by bumping the core tag.

From then on the cycle is fixed: a feature ships in DOMOVINA.ai, proves
itself in production, gets a core tag, and Podcasterium takes it through test
tracks, then web, then the stores.
