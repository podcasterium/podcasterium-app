# App Review rejection of 1.0.0 and the 1.0.3 resubmission — 1 Oct 2026

What App Review found on 30 Sep 2026, what caused it, what changed, and how
1.0.3 (build 12) went back into review through the App Store Connect API on
1 Oct 2026. Open launch work stays in [`TODO-launch.md`](TODO-launch.md).

## 1. The findings

Submission `3d19308b-c302-4afe-9218-b857812086c3`, version 1.0.0 (build 4),
reviewed on an iPad Air 11" (M3) and an iPhone 17 Pro Max.

| Guideline | Finding | Real cause |
| :-- | :-- | :-- |
| 5.1.1(v) | No option to initiate account deletion | Deletion existed (`account-delete` edge function, type-to-confirm dialog) but only at the bottom of the account screen, reachable after sign-in through the avatar menu |
| 2.1(b) | In-app purchases could not be located | The paywall opened only from the account screen; a signed-out reviewer had no path to it |
| 5.2.3 | Potentially unauthorized access to third-party audio/video, catalogs and discovery | The app streams processed copies of third-party YouTube podcasts (Sub Club, Launched, Croatian channels) from our own CDN, and the old review note named a `domovina.ai` CDN, which reads as a third-party service. No written permissions exist |

## 2. What changed

- **Discoverability (core `39961d9`, `bc73dc3`, `f33017f`).** A Plus button in
  the home header for everyone who is not Plus (`FeatureFlags.plusInHeader`,
  on for Podcasterium only); Plus and Delete account in the avatar menu;
  deletion extracted to `confirmAndDeleteAccount`. On a 402 pt phone the
  header row overflowed and pushed Sign in off screen, so with the flag the
  order is wordmark, search, Plus, Sign in, then the toggles.
- **Brand separation.** Every backend host has a `podcasterium.com` name:
  `cdn` is a second custom domain on the R2 bucket; `api`, `mcp`, `search`,
  `cutter` go through `infra/edge-proxy` (upstream zone in the Worker secret
  `UPSTREAM_ZONE`). Data JSON carries absolute CDN URLs, which the app
  (`CdnConfig.rebase`, core `8c71318`) and the web worker (`fetchJson`)
  rewrite to the brand host. Verified: auth, REST, edge functions, realtime
  WebSocket (101), RAG CORS for podcasterium.com, Meilisearch, cutter.
- **Legal pages.** The privacy and terms contact was hard-coded
  `ms@domovina.ai`; it now comes from `BrandConfig.contactEmail`
  (`hello@podcasterium.com`, Cloudflare Email Routing to the owner; core
  `a719d6e`).
- **Web.** Flutter's default favicon, PWA icons and `#0175C2` theme colour
  replaced with brand assets.

## 3. Resubmitting through the API

The App Store Connect web UI was not needed. In order:

1. Rename the rejected version (allowed while `REJECTED`):
   `PATCH /v1/appStoreVersions/{id}` with `versionString: "1.0.3"`.
2. Attach the processed build:
   `PATCH /v1/appStoreVersions/{id}/relationships/build`.
3. Update `appStoreReviewDetails.notes` (steps to the paywall and to
   deletion, the 5.2.3 statement).
4. Mark the rejected item resolved:
   `PATCH /v1/reviewSubmissionItems/{itemId}` with `resolved: true`.
   Without this, step 5 answers 409 *"Version is not ready to be submitted
   yet, please try again later"* indefinitely.
5. `PATCH /v1/reviewSubmissions/{id}` with `submitted: true` →
   `WAITING_FOR_REVIEW`.
6. Attach the screen recording: `POST /v1/appStoreReviewAttachments`
   (fileName, fileSize, relationship to the review detail), PUT each upload
   operation, then `PATCH` with `uploaded: true` and the MD5 checksum; poll
   until `assetDeliveryState.state` is `COMPLETE`.

Notes and attachments stay editable while the submission waits. The
**Reply** button on the rejection thread disappears once the submission is
resubmitted, so anything for the reviewer goes into the notes or an
attachment.

## 4. Pitfall: the deletion recording

Apple asks for a physical-device recording of creating or signing in to an
account and deleting it. The first take used the owner's own account; the
second deleted the **Play review account** (`podcasteriumsync@gmail.com`).
The backend is shared, so that deleted the review user and its promotional
Plus. The owner signed in again (new user `215f76d5-…`) and Plus was
re-granted until 1 Jan 2027 through the RevenueCat API (the customer has to
be created first with `GET /v1/subscribers/<uuid>`, because a web sign-in
never reaches RevenueCat). Record deletion only with a throwaway
Sign in with Apple "Hide My Email" account.

## 5. Open

- **5.2.3.** The notes say written consent from channel owners is being
  obtained. It does not exist yet. Expect App Review to ask for it; the
  alternative is to play third-party channels only through the official
  YouTube player on iOS.
- **Thumbnails.** Episodes of `subclub` and `launched` have no
  `images/<id>/thumbnail.png` on the CDN (404 on both hosts), so their cards
  show placeholders. Pipeline issue, not the hostname change.
- **Android.** Play 1.0.0 (5) is still in review and has none of these
  fixes; ship 1.0.3 as an update once it is approved.
- **Legal page date** is hard-coded in Croatian ("26. svibnja 2026.") in the
  English UI.

## Related documents

- [`TODO-launch.md`](TODO-launch.md) — launch state table
- [`store-listing-copy.md`](store-listing-copy.md) — listing and review notes
- [`06-backend-and-corpus.md`](06-backend-and-corpus.md) §5.3 — content rights
