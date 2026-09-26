# TODO — 1.0.0 launch and Shipaton 2026

Open work as of **24 Sep 2026, evening**. Shipaton deadline: **30 Sep 2026,
23:45 PDT** (1 Oct 2026, 08:45 CEST). The app must be *published* on at least
one store by then, with purchases running through RevenueCat. Submission copy
and the video script: `docs/shipaton/`.

Items marked **owner** need a human: account creation, passwords and keys,
or final store submissions that the assistant's permission layer blocks.
Items marked **assistant** can be done in a session.

## State at the time of writing

| Item | State |
| :-- | :-- |
| App Store 1.0.0 | **in review** since 24 Sep 2026 with build 4 (real app icon), release type MANUAL. Subscriptions `podcasterium_plus_monthly` / `_yearly` are READY_TO_SUBMIT and sit in a draft submission |
| Google Play 1.0.0 (5) | in review since 24 Sep 2026 (review restarted to replace build 3): Android shell wired for OAuth return, background audio, TV; review account has promotional Plus |
| RevenueCat | products, entitlement `podcasterium_plus`, offering `default`, store credentials for iOS and Android: all done and validated |
| Core (`feat/podcast-core`) | 6 white-label fixes committed, unpushed; `featuredChannels` on branch `feat/featured-channels` (worktree `~/git/domovinatv/.podcast-core-featured`), not merged |

## Blocking the launch — in this order

1. ~~**owner — RevenueCat store credentials.**~~ — done 24 Sep 2026; all three validated as `valid` through the RevenueCat MCP (the dashboard's own check had first flagged the In-App Purchase key; the MCP check passed). Dashboard:
   `https://app.revenuecat.com/projects/9b6e08d9/apps`. Three uploads; the
   key files never go into this repository.

   **a) iOS app `Podcasterium (iOS)` (`app634a98acce`) → In-App Purchase Key**
   - File: `~/.appstoreconnect/private_keys/SubscriptionKey_9H7HMZ4M53.p8`
     (team-wide In-App Purchase key of ITalk d.o.o., the same one DOMOVINA
     uses).
   - Key ID: `9H7HMZ4M53`
   - Issuer ID: `69a6de85-f7cc-47e3-e053-5b8c7c11a4d1`
   - If RevenueCat rejects it, create a new one in App Store Connect →
     Users and Access → Integrations → In-App Purchase, and download it once.

   **b) iOS app → App Store Connect API key** (lets RevenueCat import
   products and read prices)
   - File: `~/.appstoreconnect/private_keys/AuthKey_25KYCN22QD.p8`
   - Key ID: `25KYCN22QD`
   - Issuer ID: `69a6de85-f7cc-47e3-e053-5b8c7c11a4d1`
   - Vendor number is already set (`87530352`).

   **c) Android app `Podcasterium (Android)` (`app5625a06b17`) → Service
   Account Credentials JSON**
   - File: `~/.config/play-publisher/domovina-play-publisher.json`
     (service account `play-publisher@domovina-production.iam.gserviceaccount.com`).
   - Grant it access to the new app first: Play Console → Users and
     permissions → that service account → App permissions → add
     *Podcasterium* with **View app information**, **View financial data**,
     **Manage orders and subscriptions**. Without this RevenueCat's check
     fails even with the right JSON.
   - Google can take up to 36 hours before the credentials validate; a
     "credentials are not valid yet" warning right after upload is normal.

   **d) optional, recommended — Google real-time developer notifications**
   (renewals and cancellations reach RevenueCat immediately): RevenueCat
   Android app → *Google developer notifications* → copy the Pub/Sub topic
   → Play Console → Monetize with Play → Monetization setup → paste the
   topic → Send test notification.

   Without a) and c) no purchase is verified, and a reviewer who tests Plus
   sees an error.
2. ~~**assistant — verify the credentials**~~ — done 24 Sep 2026: with the RevenueCat MCP
   (`validate-app-credentials`) once they are uploaded.
3. ~~**owner — review account.**~~ — done 24 Sep 2026: `podcasteriumsync@gmail.com`, Supabase user `aee8c846-3073-4a09-bf83-022764d8c6cb`. Create a dedicated Google account for store
   review (for example `podcasterium.review@gmail.com`), then sign in to the
   app once with "Sign in with Google" so the user exists.
4. ~~**assistant — grant Plus to the review account**~~ — done 24 Sep 2026, promotional `podcasterium_plus` until 1 Jan 2027. The customer had to be created first with `GET /v1/subscribers/<uuid>` (public SDK key), because a web sign-in never reaches RevenueCat. with the RevenueCat MCP
   (`grant-customer-entitlement`, entitlement `podcasterium_plus`, lifetime
   or until 31 Dec 2026). Google does not buy subscriptions or use trials
   during review.
5. ~~**owner — Play sign-in details.**~~ — done 24 Sep 2026; changes resubmitted, Play runs its pre-review checks and then the review. First make the review account
   usable by a stranger on a new device: remove the passkey and 2-step
   verification from `podcasteriumsync@gmail.com`, set a long unique
   password, and keep a recovery e-mail you control. Google's reviewers sign
   in with the credentials you give them; a passkey or a second factor on
   your device stops them, and the review fails. The account exists only for
   review, so the exposure is limited to this app's promotional Plus.
   Then: Play Console → App content → Sign in
   details → **Yes**; enter the review account's e-mail and password, with the
   instruction: *"Tap Sign in, choose Sign in with Google and use the account
   above. The account already has Podcasterium Plus."* Save, then Publishing
   overview → Submit changes for review.
6. ~~**assistant — attach build 4** to App Store version 1.0.0~~ — done
   24 Sep 2026 (replaced build 3, which had the Flutter icon).
7. ~~**owner — App Store submission.**~~ — done 24 Sep 2026: version 1.0.0 (build 4), both subscriptions and the group submitted together ("4 Items Submitted"). App Privacy and Play Data safety already declared Purchase History, so neither changed. In App Store Connect: optionally add
   the review account under App Review Information → Sign-in required. Then
   subscription group *Podcasterium Plus* → Add for Review → Draft
   Submission (1); version 1.0.0 → Add for Review into the same draft;
   Submit for Review. The subscriptions must go in with the version.
8. **owner — release on approval.** The App Store version is set to manual
   release: press "Release this version" when Apple approves. Play publishes
   by itself (managed publishing is off).

## Shipaton submission

9. **owner — register** on Devpost as ITalk d.o.o.
   (`https://revenuecat-shipaton-2026.devpost.com/`).
10. **owner — record the demo video** (< 2 min, public on YouTube) from
    `docs/shipaton/demo-video-script.md`. Scene 7 needs a sandbox tester and
    items 1–2 done.
11. **owner — submit** with the copy in `docs/shipaton/submission.md`
    (Design Award, Peace Prize; optionally #BuildInPublic and HAMM). Re-read
    the archive numbers in the app on the day and update the text.

## After 1.0.0 is approved (1.0.1)

**Build 6 (1.0.1)** — built 24 Sep 2026 from core `2aa6f07`: Play internal
track (production still 1.0.0 (5) in review), TestFlight, podcasterium.com.
Promote to production only after 1.0.0 is approved on that store.

12. ~~**assistant — merge `feat/featured-channels` into `feat/podcast-core`**
    and set `featuredChannels: ['subclub', 'launched', 'catholic_futurist']`
    in `lib/brand.dart`.~~ — done 24 Sep 2026 (core `be6409f`), in build 6.
13. ~~**assistant — Play build 4**~~ — superseded: build 5 (real launcher icon and the Android shell fixes) replaced build 3 in the first review.
14. ~~**assistant — check for English articles.**~~ — checked 24 Sep 2026
    from the channel JSON on the CDN (`pipeline.has_article_en`):
    `subclub` 0 of 181, `launched` 0 of 116, `catholic_futurist` 14 of 20,
    `domovina_tv` 1 of 7 (`fO7iltytw0I`). Sub Club and Launched articles are
    Croatian retellings of English shows. **Still open (backend,
    `domovina-api`):** generate `article.en.json` for the English-language
    channels, starting with `subclub` — it is RevenueCat's own show and the
    judges will open it first.

15. **Password sign-in for the review account** — code done 24 Sep 2026
    (core `2aa6f07`, in build 6): email step → "Sign in with password".
    The existing review user `aee8c846-…` got a Supabase password (not the
    Google one), so it keeps its promotional Plus; the password is in
    `~/.config/podcasterium/review-account.env` on the owner's Mac, and a
    live password grant returned that user. **owner, once 1.0.1 is live on
    both stores:** change Play's Sign in details and Apple's demo account to
    "Sign in → Continue with email → Sign in with password", then the Google
    account may get its passkey and 2-step verification back.
    Original item: **assistant — password sign-in for the review account.** A
    low-key "Sign in with password" path in the auth sheet (Supabase
    `signInWithPassword`) for one account such as `review@podcasterium.com`,
    with promotional Plus. Then Play's Sign in details and Apple's demo
    account use it, and `podcasteriumsync@gmail.com` can get its passkey and
    2-step verification back. Until then that Google account must stay
    password-only, and its password must match the Play declaration: Google
    re-reviews every update and may re-check at any time.
16. **owner — renew the review account's promotional Plus** before
    1 Jan 2027 (RevenueCat → customer
    `aee8c846-3073-4a09-bf83-022764d8c6cb` → grant entitlement).

17. **Plus cold-start fix** — in build 6 (1.0.1). Original item:
    **assistant — ship the Plus cold-start fix in 1.0.1.** Core commit
    `31f5f51` on `feat/podcast-core`: `EntitlementService.init()` now seeds
    from `RevenueCatService.optimisticPlus`. The builds in review (iOS 4,
    Android 5) show "Get Podcasterium Plus" to a Plus user after a cold start
    with a restored session; a fresh sign-in (the reviewer's path) shows Plus
    correctly. Verified fixed in the simulator on 24 Sep 2026.
18. ~~Passkey hint~~ — done 24 Sep 2026 (core `3020f66`, in build 6):
    `FeatureFlags.passkeys` (off for Podcasterium) hides the passkey tile
    and the account section; the hint names the brand's domain. Original
    item: **assistant — passkey hint names DOMOVINA.** The account screen's
    passkey help text says "turn it off for domovina.ai"
    (`authPasskeyHintBody`); make it brand-driven. Passkeys have no Corbado
    project for Podcasterium yet (`docs/03` §8), so "Add a passkey" may fail —
    hide the section until it exists.

**Build 7 (1.0.2)** — built 26 Sep 2026 from core `f4093c8`, the first
merge of upstream `main` (DOMOVINA.ai `v2.0.158`) into the core, see
`docs/04-build-and-deploy.md` §10. Play internal (versionCode 7), TestFlight
(processing `VALID`), podcasterium.com (`version.json` 1.0.2+7). Production
untouched: Play 1.0.0 (5), iOS 1.0.0 (4) still waiting for review. New for
Podcasterium users:

- **Sponsors in the recording** ("With support from" section, a marker in the
  article, "Listen" in the player panel). Verified with Playwright on the local
  build and on podcasterium.com at 1400 px and 390 px on `aue1GuuMsbA`: seek to
  5963 s, "message ended" at 6008 s, playback continues, no console errors. A
  Sub Club episode with `sponsors: []` shows no section. On 26 Sep none of the
  37 latest episodes of `subclub`, `launched`, `catholic_futurist` and
  `domovina_tv` has sponsors, so the section stays hidden in practice until
  the pipeline finds some.
- Magisterium badge fix (core `1eeee2a`), which build 6 did not have.

Builds 6 and 7 are both on the test tracks; 1.0.1 was never submitted, so
the next store submission should be 1.0.2 (7).

19. **assistant — upload the regenerated screenshots with 1.0.1.** Frames in
    `store-assets/marketing/out/{iphone,ipad,android}/` (26 Sep 2026, from
    `scripts/store-screenshots.sh`). Apple locks screenshots while a version is
    in review, so they go into the new 1.0.1 version before it is submitted
    (ASC API `appScreenshotSets`); Play takes them through `edits.images` once
    1.0.0 is live, since a listing edit now would join the running review.
    Android `02-player` is still the 24 Sep frame (emulator captures video as
    black, `docs/05-store-launch.md` §6).

## Known gaps, not blocking

- ~~**Person pages and semantic search fail on the web.**~~ — fixed
  24 Sep 2026: `mcp.domovina.ai` (`domovina-rag` `b8f0063`) now reflects
  CORS for `https://podcasterium.com` and `https://www.podcasterium.com`;
  it used to return 200 without `Access-Control-Allow-Origin`, and
  `/p/<slug>` showed "Person not found". Native apps were never affected.
- **Magisterium score badge leaked** onto the channel episode list (church
  icon with a score), because the shared corpus sends `magisterium_score`
  in the channel and person JSON. Fixed in core `1eeee2a`, shipped in
  build 7 (1.0.2).
- **Missing thumbnails.** Recent non-YouTube episodes of `subclub` (3 of the
  latest 15) and `launched` (8 of 15) have no
  `cdn.domovina.ai/images/<id>/thumbnail.png` (404), so the home carousel
  and the "Featured shows" rail show empty cards. Backend work.
- **English UI shows translated titles.** With the EN toggle on, Sub Club
  episodes are titled in Croatian ("Skaliranje Meta oglasa…"), the
  translation, instead of their English originals.
- **iPad episode screen:** the "Contents" side panel draws under the status
  bar; player chapters stay Croatian when the article is switched to EN.
- **Cache purge fails.** `CLOUDFLARE_PURGE_TOKEN` in `.env` is still the
  DOMOVINA zone token (`"success":false` on 24 Sep 2026); create a token
  scoped to the podcasterium.com zone.

- ~~**Web is stale.**~~ — redeployed 24 Sep 2026: `podcasterium.com` serves 1.0.0+4 with the core fixes; `/`, `assetlinks.json` and the AASA return 200.
- **No purchase on the web.** The RevenueCat SDK runs only in the iOS and
  Android apps; the web paywall falls back to indicative tiles because
  `RC_WEB_CHECKOUT_URL` (RevenueCat Web Billing) is not configured.

- **Web Plus.** `EntitlementService.isPlus` is the Supabase subscription
  row OR the RevenueCat CustomerInfo on mobile. The RevenueCat webhook is
  not connected to `domovina-api` for this project, so a subscriber sees Plus
  on iOS and Android but not on `podcasterium.com`.
- **Push the commits.** This repository and the core branch are unpushed;
  the core is still to be published under a tag (upstream step A7).
- **Android TV** is supported by build 5 (Leanback entry, banner), but the TV
  form factor is not opted in on Play (Advanced settings → Form factors);
  that needs TV screenshots and triggers a separate TV review.
- **Android release not run on a device.** Build 5 was not smoke-tested on a
  phone (sign-in, purchase, background audio); the local emulator has no
  system image installed. Do it from the internal track before the Play
  review ends.
- **Sign-in was broken until 24 Sep 2026 22:00 CEST** on every platform: the
  GoTrue allow-list for Podcasterium was committed but never deployed
  (`docs/03` §8). Now live; iOS build 4 in review works without a rebuild.
- **App icon and palette are placeholders** until decision D4.
- `widget_test.dart` in the core fails without network (pre-existing).
