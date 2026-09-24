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
| App Store 1.0.0 | build 4 (real app icon) attached, release type MANUAL. Subscriptions `podcasterium_plus_monthly` / `_yearly` are READY_TO_SUBMIT and sit in a draft submission |
| Google Play 1.0.0 (3) | production release saved, 177 countries, **not in review**: the pre-review check failed on "Missing sign in details" |
| RevenueCat | products, entitlement `podcasterium_plus`, offering `default` done; **no store credentials** |
| Core (`feat/podcast-core`) | 6 white-label fixes committed, unpushed; `featuredChannels` on branch `feat/featured-channels` (worktree `~/git/domovinatv/.podcast-core-featured`), not merged |

## Blocking the launch — in this order

1. **owner — RevenueCat store credentials.** In the RevenueCat dashboard,
   project Podcasterium:
   - iOS app: In-App Purchase Key (`.p8` + Key ID + Issuer ID) and the App
     Store Connect API key.
   - Android app: the Play service account JSON; that service account needs
     access to `com.podcasterium` in Play Console → Users and permissions
     (financial data, orders).
   Without them no purchase is verified, and a reviewer who tests Plus sees
   an error.
2. **assistant — verify the credentials** with the RevenueCat MCP
   (`validate-app-credentials`) once they are uploaded.
3. **owner — review account.** Create a dedicated Google account for store
   review (for example `podcasterium.review@gmail.com`), then sign in to the
   app once with "Sign in with Google" so the user exists.
4. **assistant — grant Plus to the review account** with the RevenueCat MCP
   (`grant-customer-entitlement`, entitlement `podcasterium_plus`, lifetime
   or until 31 Dec 2026). Google does not buy subscriptions or use trials
   during review.
5. **owner — Play sign-in details.** Play Console → App content → Sign in
   details → **Yes**; enter the review account's e-mail and password, with the
   instruction: *"Tap Sign in, choose Sign in with Google and use the account
   above. The account already has Podcasterium Plus."* Save, then Publishing
   overview → Submit changes for review.
6. ~~**assistant — attach build 4** to App Store version 1.0.0~~ — done
   24 Sep 2026 (replaced build 3, which had the Flutter icon).
7. **owner — App Store submission.** In App Store Connect: optionally add
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

## Known gaps, not blocking

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
