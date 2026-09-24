# Shipaton 2026 — submission copy

Draft text for the RevenueCat Shipaton 2026 entry on Devpost
(`https://revenuecat-shipaton-2026.devpost.com/`). Deadline: **30 Sep 2026,
23:45 PDT** (1 Oct 2026, 08:45 CEST). Entrant: ITalk d.o.o.

Every number below was read in the app on 24 Sep 2026 (home-page footer
statistics and the search screen's channel chips). Re-read them on the day
of submission and update them; do not round up.

Rules that shape this text (official rules, sections 4, 6 and 8):

- The app must be published on the App Store or Google Play by the deadline,
  with RevenueCat powering at least one purchase. Judges need free access to
  everything, which the 7-day free trial provides.
- Each category needs its own write-up. Judges may score from the text, the
  images and the video alone, so every claim has to be visible in one of
  them.
- No third-party trademarks or copyrighted material without permission — see
  the note in `demo-video-script.md`.

---

## 1. Project fields

**Name:** Podcasterium

**Tagline (≤ 60):** Watch, listen to and read podcasts.

**Store links**

- App Store: `https://apps.apple.com/app/id6815415892` (live once approved)
- Google Play: `https://play.google.com/store/apps/details?id=com.podcasterium`
- Web: `https://podcasterium.com`
- Source: `https://github.com/podcasterium/podcasterium-app`

**Built with:** Flutter, Dart, RevenueCat (`purchases_flutter`), Supabase,
Cloudflare (Pages, Workers, CDN), Meilisearch, YouTube embedded player.

**Short description**

> Podcasterium turns a two-hour podcast into something you can read in ten
> minutes — and then play from exactly the right second. Every processed
> episode gets chapters, a transcript that knows who is speaking, an
> AI-written article chapter by chapter, and a page for every person who
> appears or is mentioned. One app on iPhone, iPad, Android, Android TV and
> the web.

**Long description**

> Long-form podcasts are where some of the best conversations happen, and
> they are almost impossible to skim. You cannot search inside them, you
> cannot quote them, and you cannot tell whether minute 74 is the part you
> care about.
>
> Podcasterium processes each episode once and gives it back in three ways:
>
> - **Watch or listen** with a chapter list next to the player, background
>   audio, and speed control.
> - **Read** an article that retells the episode chapter by chapter, with
>   the timestamp of every section one tap away.
> - **Search** the whole archive by keyword or by meaning, and open a
>   **person page** that shows every episode someone speaks in or is talked
>   about, with the minute of each mention.
>
> The archive today holds 49 channels, 3,237 episodes and 3,103 hours of
> processed audio — mostly Croatian-language shows, plus English-language
> ones such as RevenueCat's own *Sub Club* (181 episodes). Articles are
> currently written in Croatian; the interface is English and Croatian.
>
> **Podcasterium Plus** is an optional subscription sold through RevenueCat:
> monthly or yearly, with a 7-day free trial. Today it unlocks 30 search
> results instead of 12 and a supporter badge. We list only what exists; the
> roadmap is shown separately and is never part of the purchase.
>
> The app is a white-label shell: all brand-specific material lives in one
> configuration object, and the same engine already runs a second,
> independent brand in production. Podcasterium is the open, brand-neutral
> edition of it.

---

## 2. Category write-ups

### Design Award

> **Reading is a first-class way to consume a podcast.**
>
> Most podcast apps design for the ears and treat text as an afterthought — a
> wall of transcript at the bottom of the screen. Podcasterium designs the
> episode as a document you can move through in three modes, and keeps you
> oriented in time in all of them.
>
> - **Article view.** Each chapter is a section with its own heading,
>   timestamp, play button, share link and a still frame from the video. The
>   typography is set for reading: a serif display face for titles, a
>   generous measure and line height for body text.
> - **Player panel.** The player slides in beside the text instead of
>   replacing it. The chapter list is always visible, the current chapter is
>   highlighted, and the waveform shows chapter boundaries, so you can see
>   the shape of a two-hour conversation at a glance.
> - **Simple / detailed toggle.** One tap switches between a clean
>   video-first view and the full article with chapters.
> - **Speakers everywhere.** Diarized speaker labels appear in the player
>   and the transcript, and each person's name links to their page.
> - **Person hub.** A timeline of when someone is mentioned, the channels
>   that talk about them, and every mention with the exact minute — a view
>   no other podcast app gives you.
> - **One layout system from phone to TV.** The same screens reflow from a
>   6.1" phone to a 13" iPad (contents rail on the left, player on the right)
>   to a 10-foot Android TV interface driven by a D-pad.
> - **Honest paywall.** Two real benefits, the trial and renewal terms next
>   to the price, and links to the terms and privacy policy in the purchase
>   flow. The roadmap is visually separated and labelled as not part of the
>   purchase.

### Peace Prize

> **Making spoken public debate readable, searchable and accountable.**
>
> A growing share of public conversation — politics, faith, science,
> business — now happens in multi-hour podcasts. That content is effectively
> invisible to anyone who cannot spend the hours, cannot hear it, or does
> not speak fast enough in the language to follow it.
>
> Podcasterium's social benefit:
>
> - **Accessibility.** Every episode becomes a readable article and a
>   speaker-labelled transcript, which opens long-form audio to deaf and
>   hard-of-hearing people and to anyone who reads faster than they listen.
> - **Accountability.** The person hub shows what was said about a public
>   figure, where and when, each claim linked to the exact second of the
>   original recording — context instead of clips.
> - **Long-tail languages.** The engine was built for a small language
>   market first (Croatian), where no big platform invests in these tools.
>   The same pipeline can serve any community whose podcasts are ignored by
>   global products.
> - **Open, white-label engine.** The app shell is MIT-licensed on GitHub,
>   and the engine is designed so a community, a newsroom, a university or a
>   church can run its own branded archive without starting from scratch.
>   The core package is being extracted from the production codebase and
>   will be published under the same GitHub organisation.
>
> **Feasibility:** this is not a prototype. The engine already serves a
> second brand in production, the archive holds 3,237 processed episodes, and
> Podcasterium ships on iOS, Android, Android TV and the web from one
> codebase.

### #BuildInPublic (optional)

Needs links to public posts tagged **#Shipaton** (and optionally
**#BuildInPublic**) made during the submission period. Suggested posts until
the deadline, one per day on LinkedIn and X:

1. **24 Sep** — "Shipping a white-label podcast reader to both stores in six
   days." The two builds, the store records, and the Shipaton deadline.
2. **25 Sep** — The white-label leaks we found while taking screenshots: the
   app opened in Croatian, the footer talked about the other brand, and the
   paywall offered a plan that did not exist. Screenshots before and after.
3. **26 Sep** — Store gotchas: an App Store subscription stays "Missing
   Metadata" until it has a price in every territory, including one where
   the app is not sold; Play accepts only draft releases on a draft app.
4. **27 Sep** — Pricing: why Plus lists two benefits and not seven (a lesson
   from July 2026), and why there is a 7-day trial.
5. **28–29 Sep** — Review results from Apple and Google, and the demo
   video.
6. **30 Sep** — Launch post with both store links.

**Write-up:**

> We built Podcasterium in the open over the last week of Shipaton: from two
> internal test builds to both stores. The posts cover the real problems —
> the brand leaks a white-label app hides until you look at every screen,
> the store-console behaviour no documentation mentions, and why our paywall
> promises two things instead of seven. [links]

### Help Apps Make Money (optional)

> Podcasterium has two revenue streams, in this order:
>
> 1. **Consumer subscription (live).** Podcasterium Plus through RevenueCat,
>    monthly or yearly with a 7-day trial, priced the same per territory as
>    its sister brand so both apps can be compared on the same dashboard.
>    The paywall lists only the two benefits that exist today; new benefits
>    are added to Plus at no extra cost as they ship.
> 2. **White-label licensing (next).** The same engine, under a community's
>    own brand, for newsrooms, universities, churches and podcast networks
>    that want their archive readable and searchable. Each instance can run
>    its own RevenueCat project, so entitlements and revenue stay per brand.
>
> Sustainability comes from processing each episode once and serving it as
> static files from a CDN: the marginal cost of a reader is close to zero,
> so even a small subscriber base covers the archive.

---

## 3. Assets checklist

| Asset | Requirement | Source |
| :-- | :-- | :-- |
| Icon | 1024×1024 PNG | `assets/brand/logo_1024.png` |
| Screenshot | ≥ 1 at 1179×2556, no device frame | resize `store-assets/ios-iphone/*` (1320×2868) |
| Video | < 2 min, public on YouTube or Vimeo, recorded on a device | `docs/shipaton/demo-video-script.md` |
| Store link | App Store and/or Google Play | §1 above |
| Description + write-ups | English | §1 and §2 above |

Resize one screenshot to the required size:

```bash
sips -z 2556 1179 store-assets/ios-iphone/03-article.jpg --out /tmp/shipaton-article.jpg
```
