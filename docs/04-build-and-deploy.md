# 04 — Build and deploy pipeline

*What Podcasterium takes over from the DOMOVINA pipeline, what it
parameterizes, what it changes. Scripts are in `domovina.ai/scripts/` @ `cfb45aa`.*

---

## 1. Principle: nothing new, everything parameterized

DOMOVINA.ai has a scripted path from commit to TestFlight, Play internal and
the production web, plus a nightly build that drives it by itself.
Podcasterium **does not build a new pipeline** — it takes the same one and
pulls the identity out into one file.

```mermaid
flowchart LR
    ENV[".env<br/>secrets and environment"] --> S
    BR["brand/&lt;brand&gt;/brand.yaml<br/>+ release.env<br/>identity"] --> S
    subgraph S["scripts/ (same code, both brands)"]
        D["deploy.sh<br/>web"]
        M["build-mobile-release.sh<br/>AAB + IPA"]
        T["testflight-upload.sh"]
        P["play-upload.sh · play-promote.sh"]
        N["nightly-build.sh"]
        ST["store-status.rb"]
    end
    D --> CF["Cloudflare Pages<br/>project per brand"]
    T --> TF["TestFlight"]
    P --> PL["Play internal → production"]
```

Today the identity is hard-coded in the scripts:

| Script | Hard-coded |
| :-- | :-- |
| `scripts/deploy.sh` | `--project-name=domovina-ai`, `https://domovina.ai/` verification, AASA tripwire on `domovina.ai`, `=== DOMOVINA.ai v… ===` |
| `scripts/build-mobile-release.sh` | `ASC_KEY_ID=25KYCN22QD`, `ASC_ISSUER_ID` (have env overrides) |
| `scripts/testflight-upload.sh` | the same ASC defaults |
| `scripts/play-upload.sh`, `play-promote.sh` | `PKG=ai.domovina`, SA JSON path `domovina-play-publisher.json` |
| `scripts/store-status.rb` | `BUNDLE_ID = 'ai.domovina'` |
| `scripts/nightly-build.sh` | worktree `../.nightly-domovina`, launchd label, Telegram |
| `launchd/*.plist` | label, paths |

Proposal: `brand/<brand>/release.env` (committed, no secrets):

```bash
BRAND=podcasterium
APP_DISPLAY_NAME="Podcasterium"
BUNDLE_ID=com.podcasterium              # = Android applicationId (decided 10 Sep 2026)
SITE_URL=https://podcasterium.com
PAGES_PROJECT=podcasterium
ASC_KEY_ID=…                             # may equal DOMOVINA's if same team
ASC_ISSUER_ID=…
PLAY_SA_KEY=$HOME/.config/play-publisher/podcasterium-play-publisher.json
NIGHTLY_WORKTREE=../.nightly-podcasterium
LAUNCHD_LABEL=com.podcasterium.nightly-build
```

Every script starts with `source "brand/${BRAND:-domovina}/release.env"`, then
`.env`. Secrets (`CLOUDFLARE_PURGE_TOKEN`, `SUPABASE_ANON_KEY`, RC keys,
Telegram) stay in `.env`, which is per checkout — the fork has its own.

---

## 2. Web

Today's chain (`deploy.sh`): version bump → `flutter pub get` → `flutter analyze`
→ `flutter build web --release --wasm $DEFINES` → copy `robots.txt` →
`wrangler pages deploy build/web --project-name=…` → purge zone → HTTP 200
check → AASA tripwire.

For Podcasterium the input changes **and one file has to arrive from
somewhere**:

```bash
flutter build web --release --wasm \
  --dart-define=SUPABASE_URL=… --dart-define=SUPABASE_ANON_KEY=… \
  --dart-define=MEILI_URL=… --dart-define=RC_WEB_CHECKOUT_URL=…
cp <upstream>/web/{_worker.js,_headers,robots.txt} build/web/   # see below
wrangler pages deploy build/web --project-name=podcasterium
```

**The gap, found by doing it on 21 Sep 2026.** This shell's `web/` holds only
`index.html`, `manifest.json`, `favicon.png` and `icons/` — the Flutter
template. `_worker.js` and `_headers` live upstream, and Flutter copies
`web/` into `build/web` verbatim, so a plain `wrangler pages deploy` from
here ships a **bare SPA**: no SSR, no `/.well-known/*`, no sitemap, no cache
strategy. Everything `03-…` §4 and the upstream worker doc describe is
in that one file (upstream `docs/worker-env-bindings.md`, on the
`feat/podcast-core` branch — `verify-doc-refs.sh` flags it while the upstream
checkout sits on `main`).

That contradicts nothing in `08-…`, but it is not covered by it either: the
worker is not Dart, so it cannot ride along in `podcast_core`, and copying it
into this repo would be the copy the architecture forbids. Until it is
decided, the deploy copies the three files out of the upstream checkout. The
candidates:

| Option | Cost |
| :-- | :-- |
| `podcast_core` ships them as package assets, the shell's build copies them out | Keeps one source; needs a build step that reaches into the package |
| Upstream publishes them with the core tag, the shell vendors them on release | Explicit, versioned; a second thing to remember per tag |
| The shell keeps its own copy | Simple; two workers drift, which is exactly what `08-…` exists to prevent |

**Measured 21 Sep 2026**, first deploy of this shell (48 files, 48 MB;
`main.dart.wasm` 4.47 MB, `main.dart.js` 5.07 MB fallback), with the three
files copied in by hand:

- `https://podcasterium.com/` → HTTP 200
- `/.well-known/assetlinks.json` → `com.podcasterium` with the upload key's
  SHA-256, and **no** airKUNA entry (`FEATURE_AIRKUNA=false` works)
- `/.well-known/apple-app-site-association` → `6SCK58757K.com.podcasterium`
- `/.well-known/webauthn` → only the two podcasterium origins
- `/sitemap.xml` → `podcasterium.com` URLs built from the shared DOMOVINA CDN
- `/c/abbacast` and `/v/O4TArTY954o` → SSR with `og:site_name = Podcasterium`
  over `cdn.domovina.ai` images, i.e. phase-1 corpus sharing works end to end
- `/glasanje` → SPA fallback, not the voting SSR (`FEATURE_VOTING=false`)

Not yet right: `og:image` points at `/og-image.png`, which this shell does not
have (brand assets are placeholders until D4), so link previews 404 on the
image.

### Static pages on the same domain (`/roadmap`, `/features`, …)

The worker already has the seam. Before the SPA fallback it does a
**pretty-URL lookup**: for a path with no extension and no route match it
fetches `<path>.html` from the Pages asset tree and serves it if present.
So a separately built static site (Astro or anything else) needs only to land
in `build/web` as flat files — `roadmap.html`, not `roadmap/index.html`,
because the trailing-slash branch 301s `/roadmap/` → `/roadmap` and the
lookup then asks for `roadmap.html`. In Astro that is
`build: { format: 'file' }`.

Proven on the `routing-probe` preview deployment, 21 Sep 2026:

| Request | Result |
| :-- | :-- |
| `/roadmap`, `/features` | 200, the static HTML |
| `/roadmap/` | 301 → `/roadmap` |
| `/nepostojeca-ruta` | 200, SPA fallback |
| `/c/abbacast` | 200, still SSR |

**Chosen 22 Sep 2026: the separate Worker.** The seam above stays available,
but `/roadmap` and `/features` are served by a Worker bound to zone routes,
from the sibling repo `podcasterium-landing`. A Worker route takes precedence
over the Pages custom domain, so the landing deploys on its own schedule and a
broken build there cannot take the app down. What it costs is a route list
that has to stay in sync by hand.

Two details that were measured rather than assumed:

- The routes are **two patterns per page** — `podcasterium.com/roadmap` and
  `podcasterium.com/roadmap/*` — not one `…/roadmap*`. A single trailing
  wildcard also matches `/roadmapX`, and a static-assets Worker with no `main`
  has no fallthrough: it answered **404** on a path the app would have served.
  With the pair, `/roadmapX` reaches the SPA again.
- The landing pulls in **no external URLs** (Astro `build.format: 'file'` plus
  `inlineStylesheets: 'always'`, no client JavaScript). That is what keeps the
  route list to the page paths themselves. A stylesheet, font or image added
  later will 404 until its prefix is routed to that Worker too.

Verified live on 22 Sep 2026: `/roadmap` and `/features` serve the pages,
`/roadmap/` redirects to `/roadmap` (307 from the assets Worker, where the
app's worker uses 301), `/roadmapX` and `/` reach the app, and `/c/abbacast`
still server-renders. The routing contract is in that repo's `README.md`.

What to know, paid for by experience (CLAUDE.md + `docs/web-delivery-and-rendering.md`):

- `--wasm` (skwasm) requires COOP/COEP headers — the worker emits them.
  Conditional imports are gated on `dart.library.js_interop`, not
  `dart.library.html`.
- The service worker is **deliberately active** (iOS PWA background audio).
  Cache strategy in `_headers`: bootstrap files `no-cache`, hashed assets
  `immutable`, SW `no-store`.
- Purging the zone after deploy is not optional.
- Fonts: `google_fonts` on all platforms; the `<link>` in `index.html` only
  serves the HTML boot-intro. New family → `AppTypography._usedVariants`.
- `SharedPreferences` does not exist on the web (`localStorage` via `package:web`).
- `flutter_svg` does not go on the web — PNG.

**Worker env bindings** (Pages → Settings → Variables): `SITE`, `CDN`,
`PERSON_API`, `PERSONS_API`, `APPLE_TEAM_ID`, `IOS_BUNDLE_ID`,
`ANDROID_PACKAGE`, `ANDROID_SHA256`, `FEATURE_VOTING=false`, `FEATURE_CAL=false`,
`FEATURE_AIRKUNA=false`,
`CAL_API_KEY` (secret, only if cal is on). The worker reads `env.X ?? default`.

Local dev: `scripts/run-local.sh` — port 5173 is in the GoTrue allow-list;
for Podcasterium add another port or use the same (same GoTrue).

---

## 3. iOS

The chain (`build-mobile-release.sh ios`), which **does not use
`flutter build ipa`** because it fails at the export step without a cert in
the keychain:

```
flutter clean  (or FAST_CLEAN=1: rm -rf build .dart_tool ios/Flutter/ephemeral)
flutter pub get
flutter build ios --config-only --release $DEFINES $VERSION_ARGS
xcodebuild archive -workspace ios/Runner.xcworkspace -scheme Runner \
  -configuration Release -destination 'generic/platform=iOS' \
  -archivePath build/ios/archive/Runner.xcarchive \
  -allowProvisioningUpdates -authenticationKeyPath … -authenticationKeyID … -authenticationKeyIssuerID …
xcodebuild -exportArchive -archivePath … -exportPath build/ios/ipa \
  -exportOptionsPlist ios/ExportOptions.plist -allowProvisioningUpdates -authentication…
xcrun altool --upload-app -f build/ios/ipa/*.ipa --type ios --apiKey … --apiIssuer …
```

For Podcasterium: the same chain. `-allowProvisioningUpdates` + the API key
registers the distribution cert and profile for the new bundle ID at the
first archive. `$DEFINES` gets `--dart-define=BRAND=podcasterium`.

Gotchas that remain (from `docs/mobile-release-pipeline.md`):
- a simulator build leaves an x86_64 slice in `objective_c.framework` → altool
  409; hence `flutter clean` before a release archive.
- `flutter clean` under launchd can hang (`xcodebuild clean`) → the nightly
  uses `FAST_CLEAN=1`.
- `manageAppVersionAndBuildNumber=false` in `ExportOptions.plist`, otherwise
  Xcode overwrites `CFBundleVersion` by itself.
- `TARGETED_DEVICE_FAMILY = "1,2"` → iPad screenshots are mandatory in ASC.
- Apple processes builds asynchronously; ITMS rejections arrive minutes
  later — the nightly polls `processingState` for up to 45 min.

---

## 4. Android

```
flutter build appbundle --release $DEFINES $VERSION_ARGS
# → build/app/outputs/bundle/release/app-release.aab (signed with the upload key from key.properties)
./scripts/play-upload.sh internal     # edits.insert → bundles.upload → tracks.update → commit
./scripts/play-promote.sh <vc> production "release notes"
```

`build.gradle.kts` already falls back to the debug signature when
`key.properties` is missing — the script catches that and refuses a store
build. For Podcasterium: a new `key.properties` points at the new keystore;
`PKG` from `release.env`.

Gotchas: Play rejects a repeated `versionCode` (the nightly computes
`max(ASC, Play, pubspec)+1`); `hr-HR` is not a Play locale (`hr`); for
Podcasterium the default locale in the Play Console is `en-US`.

---

## 5. Nightly

`scripts/nightly-build.sh` (launchd 01:00): if HEAD ≠ last built → detached
worktree `../.nightly-domovina` → `pub get` → `analyze` → tests (hard gate,
baseline in `.nightly/test-baseline.txt`) → build number → iOS → Android →
TestFlight → Play internal → verification → Telegram.

For Podcasterium:
- its own worktree (`../.nightly-podcasterium`) — a **sibling of the repo**,
  not anywhere else (the `flutter_certilia` path dependency resolves
  relatively; if Certilia is removed from the fork, the constraint goes away).
- its own launchd label and **another time** (e.g. 02:30) — two `xcodebuild`
  archives in parallel on the same Mac mini are slow and unreliable.
- the same `telegram-notify.rb` (secret redaction), another group or a prefix.
- `BUILD_DERIVED_DATA` on its own path so DerivedData does not grow.
- The Gradle home stays on the APFS sparsebundle (`/Volumes/DOMOVINA_BUILD`) —
  the exFAT 512 KB block was measured as a 3× bloat.

Both nightlies (DOMOVINA and Podcasterium) **can share** the same `.p8` key
and Play service account if the Apple team and Play organization are the same.

---

## 6. Versioning

DOMOVINA.ai is at `2.0.148+170`. Podcasterium starts at **`1.0.0+1`** — a new
product, a new history in the stores. `deploy.sh` bumps patch and build on
every web deploy; the nightly does not touch pubspec. The fork inherits that
mechanism and only resets the starting value.

The build number must increase monotonically **per application**; DOMOVINA
and Podcasterium do not share a counter. `store-status.rb --max-build` already
works per `BUNDLE_ID`.

---

## 7. Cloud CI — recommendation, not a blocker

Everything is built on one Mac mini under launchd. For a second product with
its own rhythm that is a single point of failure. When Podcasterium gets its
first external contributor:

- A GitHub Actions `macos-latest` runner can drive the same
  `build-mobile-release.sh` (ASC `.p8` and keystore as encrypted secrets;
  `-allowProvisioningUpdates` works there too).
- Web deploy to Pages from Actions is trivial (`wrangler-action`).
- The nightly can stay local until the need shows.

Not before phase 2; written down so the risk is known.

---

## 8. Commands that must work at the end of phase 1

```bash
# web
BRAND=podcasterium ./scripts/deploy.sh                 # → https://<domain>/ 200, AASA OK
# mobile
BRAND=podcasterium ./scripts/build-mobile-release.sh   # AAB + IPA, both signed with the new identity
BRAND=podcasterium ./scripts/testflight-upload.sh
BRAND=podcasterium ./scripts/play-upload.sh internal
BRAND=podcasterium ./scripts/store-status.rb           # sees the new bundle on both stores
# sanity
bundletool dump manifest --bundle build/app/outputs/bundle/release/app-release.aab | grep package
unzip -p build/ios/ipa/*.ipa 'Payload/*.app/Info.plist' | plutil -p - | grep -i bundleid
```

---

## 9. How build 6 (1.0.1) was actually shipped — 24 Sep 2026

The scripted chain in §8 does not exist in this repo yet; build 6 went out by
hand, in this order, and each step is repeatable:

1. **Defines.** A JSON with the five build-time keys from `.env`
   (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `MEILI_URL`,
   `RC_PUBLIC_SDK_KEY_IOS`, `RC_PUBLIC_SDK_KEY_ANDROID`), kept outside the
   repo and passed as `--dart-define-from-file=<file>` to every build.
2. **Android.** `flutter build appbundle --release …` (87 MB AAB, 55 s of
   Gradle). Before upload, check the merged manifest
   (`build/app/intermediates/merged_manifest/release/…/AndroidManifest.xml`)
   for the `com.podcasterium` scheme, `AudioService`, `BILLING`,
   `LEANBACK_LAUNCHER`, and that `keytool -printcert -jarfile` matches the
   SHA-256 in `/.well-known/assetlinks.json`. Upload with a copy of the
   upstream `play-upload.sh` where `PKG=com.podcasterium`; the internal-track
   commit went through while 1.0.0 (5) was still in production review, and
   production stayed untouched.
3. **iOS.** The §3 chain after `rm -rf build/ios .dart_tool/flutter_build
   ios/Flutter/ephemeral` (a simulator run in between leaves the x86_64
   slice), then `xcrun altool --upload-app` with key `25KYCN22QD`.
4. **Web.** `flutter build web --release --wasm …`, copy `_worker.js`,
   `_headers`, `robots.txt` from the core checkout's `web/`, `wrangler pages
   deploy build/web --project-name=podcasterium --branch=main`. Check
   `https://podcasterium.com/version.json`. The zone purge fails until
   `.env` has a podcasterium.com purge token.

Do not run two Flutter builds of this project at the same time; they share
`build/` and `.dart_tool/`.
