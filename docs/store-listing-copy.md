# Store listing copy — App Store and Google Play

Canonical listing text for both stores. The consoles are copies of this file:
when one changes, the other changes the same day (rule inherited from
upstream `docs/payments/store-listing-copy.md`).

Written for **version 1.0 (phase 1)**: the DOMOVINA corpus under a new brand,
English interface, with Plus as an optional subscription (decided 24 Sep 2026,
`DECISIONS.md`). `06-backend-and-corpus.md` §6 limits what phase 1 may
promise, and `05-store-launch.md` §5 lists the words that must not appear. In
particular the text says plainly that today's archive is mostly
Croatian-language podcasts; it does not promise "any podcast" or "any
language", and it names only the two Plus benefits that exist.

---

## 1. Shared facts

| Field | Value |
| :-- | :-- |
| App name | `Podcasterium` |
| Primary language | en-US |
| Price | Free; Plus subscription monthly or yearly, 7-day free trial (App Store USD 3.99 / 34.99, EUR 4.99 / 39.99; Play converted from USD with DOMOVINA's euro prices) |
| Age rating | Apple 12+ (third-party podcasts may touch mature topics); Play target audience 13+ |
| Apple category | Primary: Entertainment · Secondary: Education |
| Play category | Entertainment |
| Privacy policy | https://podcasterium.com/privacy |
| Terms | https://podcasterium.com/terms |
| Marketing / website | https://podcasterium.com |
| Support URL | https://podcasterium.com (a dedicated support page is still missing) |
| Copyright | 2026 ITalk d.o.o. |

---

## 2. App Store

**Subtitle** (≤30)

```
Watch, listen, read podcasts
```

**Keywords** (≤100, comma-separated, no spaces)

```
podcast,transcript,chapters,summary,speakers,article,search,archive,episodes,video,audio,reader
```

**Promotional text** (≤170; changes without review)

```
Every processed episode comes with chapters, a transcript that knows who is speaking, and an article you can read instead of listening.
```

**Description** (≤4000)

```
Podcasterium turns long podcast episodes into something you can watch, listen to, or read.

Each processed episode comes with chapters and timestamps, a transcript that marks who is speaking, and an article that retells the episode section by section. When you do not have an hour, read the article. When you want the full conversation, press play and jump straight to the chapter you care about.

WHAT YOU CAN DO

• Watch or listen to episodes, with playback continuing in the background
• Jump between chapters instead of scrubbing
• Follow the transcript with speakers identified
• Read an AI-written article of the episode, chapter by chapter
• Search the archive by keyword or by meaning
• Open a person's page to see every episode they appear in
• Save favourites and pick up where you left off
• Use it on phone, tablet, and Android TV

ABOUT THE ARCHIVE TODAY

The current archive is a curated collection of mostly Croatian-language podcasts, plus a few English-language shows such as Sub Club by RevenueCat. The app interface is in English and Croatian; episode articles and chapter titles are currently written in Croatian. More podcasts and languages are planned, but they are not in this version.

AI-GENERATED CONTENT

Articles, summaries, chapters and speaker labels are generated automatically and may contain mistakes. The original episode is always one tap away.

PODCASTERIUM PLUS

Everything above is free. Podcasterium Plus is an optional subscription that today gives you 30 search results instead of 12 and a supporter badge, and supports the development and running costs of the archive. It is offered monthly or yearly, each with a 7-day free trial for new subscribers. Payment is charged to your App Store or Google Play account; the subscription renews automatically unless cancelled at least 24 hours before the end of the current period, and you can manage or cancel it in your store account settings. Buying Plus requires signing in, so the subscription follows you across devices.

Signing in is otherwise optional and only needed to sync favourites and progress across devices.

Privacy: https://podcasterium.com/privacy
Terms: https://podcasterium.com/terms
Apple Standard EULA: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
```

**App Review notes**

```
The app works without signing in; every feature reviewed can be reached logged out. Sign-in (Apple, Google, email) only syncs favourites and playback progress.

Media is streamed from the operator's own CDN (cdn.domovina.ai, shared with the operator's app DOMOVINA.ai). Where a YouTube video is shown, it uses the official youtube-nocookie embedded player; the app does not extract YouTube streams and does not strip ads. Its own value is the processing on top of each episode: chapters, a speaker-labelled transcript, an article per chapter, and keyword and semantic search across the archive.

The current archive is mostly Croatian-language podcasts; the interface is English.

In-app purchase: Podcasterium Plus (podcasterium_plus_monthly, podcasterium_plus_yearly), each with a 7-day free trial. Open the account menu or any "Plus" prompt to reach the paywall. Buying requires signing in, and Sign in with Apple works for that; no demo account is needed. Plus unlocks 30 instead of 12 search results and a supporter badge, nothing else.
```

---

## 3. Google Play

**Short description** (≤80)

```
Watch, listen to and read podcasts: chapters, speakers, transcript, article.
```

**Full description** (≤4000): the App Store description above, verbatim.

---

## 4. Open before submission (not before TestFlight / internal)

- The privacy and terms pages on `podcasterium.com` still render the upstream
  DOMOVINA wording ("Croatian Catholic podcasts", Magisterium, Certilia,
  contact at `ms@domovina.ai`). That text lives in `podcast_core` l10n and has
  to become brand-neutral before an App Review reads it.
- A support page (or a brand support address) for the Support URL and the
  Play contact e-mail.
