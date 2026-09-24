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
| Google Play 1.0.0 (3) | resubmitted 24 Sep 2026 with sign-in details for the review account; in pre-review checks, then review |
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

12. **assistant — merge `feat/featured-channels` into `feat/podcast-core`**
    and set `featuredChannels: ['subclub', 'launched', 'catholic_futurist']`
    in `lib/brand.dart`.
13. **assistant — Play build 4** (real launcher icon) as the first Play
    update, together with item 12.
14. **assistant — check for English articles.** Featured English shows still
    have Croatian articles and chapter titles; the route `/v/:id/en` exists.
    Find which episodes already have English articles; producing them for
    English-language episodes is backend work in `domovina-api`.

15. **assistant — password sign-in for the review account.** A
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

## Known gaps, not blocking

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
- **Android TV** has no Leanback banner in the manifest; the TV form factor
  is not declared on Play yet.
- **Android release not run on a device.** Build 3 was not smoke-tested on a
  phone; the local emulator has no system image installed.
- **App icon and palette are placeholders** until decision D4.
- `widget_test.dart` in the core fails without network (pre-existing).
