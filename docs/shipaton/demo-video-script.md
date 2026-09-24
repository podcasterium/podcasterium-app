# Shipaton 2026 — demo video script

Target length **1:45** (hard limit under 2:00). Public on YouTube, unlisted
is not enough. Shot on a real device or a simulator screen recording; the
rules ask for the app running on a device, so the opening and the purchase
scene should be a real iPhone or Android phone.

## Content rules

The official rules forbid third-party trademarks, copyrighted music and
other material used without permission. Podcasterium shows third-party
podcasts, so:

- **No music**, or only a track with a licence that allows it. The voice-over
  carries the video.
- **Mute the episode audio** in every scene. Show the player, not someone
  else's voice.
- Keep third-party video frames short and small (under 3 seconds each, in
  the player panel, not full screen). The subject of each shot is our UI:
  chapters, article, speakers, search.
- Prefer **RevenueCat's own Sub Club** episodes for the scenes that show a
  podcast in detail. The audience is RevenueCat, and it is RevenueCat's
  content.
- Do not show an e-mail address or a real account name. Sign in with a test
  Apple ID for the purchase scene.

## Recording

iOS simulator (iPhone 17 Pro Max, status bar at 9:41):

```bash
xcrun simctl status_bar booted override --time "9:41" --batteryState charged --batteryLevel 100
xcrun simctl io booted recordVideo --codec h264 scene-01.mp4   # Ctrl+C to stop
```

Android phone:

```bash
adb shell settings put global sysui_demo_allowed 1
adb shell screenrecord --bit-rate 12000000 /sdcard/scene-01.mp4   # max 3 min
adb pull /sdcard/scene-01.mp4
```

Useful deep links on the simulator (confirm the "Open" prompt once):

```bash
xcrun simctl openurl booted "com.podcasterium://podcasterium.com/search"
xcrun simctl openurl booted "com.podcasterium://podcasterium.com/subscribe"
xcrun simctl openurl booted "com.podcasterium://podcasterium.com/p/<person-slug>"
```

Record each scene separately, then cut in any editor. Add captions: many
judges watch muted.

---

## Scenes

| # | Time | On screen | Voice-over | Caption |
| :-- | :-- | :-- | :-- | :-- |
| 1 | 0:00–0:10 | A phone in hand; the Podcasterium icon; the app opens on the home page | "Podcasts are where the best long conversations happen. And they're almost impossible to skim." | **Podcasterium** · watch, listen to and read podcasts |
| 2 | 0:10–0:22 | Scroll the home page: featured episode, latest episodes, people rail, footer statistics | "Podcasterium processes every episode once — 3,237 episodes and over three thousand hours so far — and gives it back three ways." | 49 channels · 3,237 episodes · 3,103 hours |
| 3 | 0:22–0:40 | Open search, type **paywall**; results from Sub Club by RevenueCat appear instantly; tap one | "Search the whole archive by keyword or by meaning. Here's every Sub Club episode that talks about paywalls." | Search inside every episode |
| 4 | 0:40–0:58 | The episode opens; the player panel slides in beside the text; tap a chapter; the waveform jumps; the speaker label changes | "Watch or listen, with chapters next to the player and the speaker named on screen. Jump straight to the minute you care about." | Chapters · speakers · background audio |
| 5 | 0:58–1:15 | Close the player; scroll the article: chapter headings, timestamps, a still frame; tap a timestamp's play button | "Or don't listen at all. Every chapter becomes a section of an article you can read in minutes — and play from exactly that second." | Read the episode, chapter by chapter |
| 6 | 1:15–1:28 | Tap a person chip; the person hub: mentions count, activity timeline, every mention with its minute | "Every person gets a page: every episode they speak in or are talked about, with the minute of each mention." | Who said what, and when |
| 7 | 1:28–1:40 | Open the account menu → Plus; the paywall with monthly and yearly, "7-day free trial, then …"; tap Yearly; the App Store sheet; subscribe with a sandbox account; the Plus badge appears | "Podcasterium Plus runs on RevenueCat: monthly or yearly, with a seven-day free trial. It's honest — two benefits today, more at no extra cost as they ship." | Podcasterium Plus · powered by RevenueCat |
| 8 | 1:40–1:45 | iPad and Android TV side by side (still frames), then the store badges and `podcasterium.com` | "One app on iPhone, iPad, Android, TV and the web. Podcasterium." | App Store · Google Play · podcasterium.com |

## Voice-over, continuous (about 230 words, ~1:40 at a calm pace)

> Podcasts are where the best long conversations happen. And they're almost
> impossible to skim.
>
> Podcasterium processes every episode once — three thousand two hundred
> episodes and over three thousand hours so far — and gives it back three
> ways.
>
> Search the whole archive by keyword or by meaning. Here's every Sub Club
> episode that talks about paywalls.
>
> Watch or listen, with the chapters next to the player and the speaker
> named on screen. Jump straight to the minute you care about.
>
> Or don't listen at all. Every chapter becomes a section of an article you
> can read in minutes — and play from exactly that second.
>
> Every person gets a page: every episode they speak in or are talked about,
> with the minute of each mention.
>
> Podcasterium Plus runs on RevenueCat: monthly or yearly, with a seven-day
> free trial. It's honest — two benefits today, and more at no extra cost as
> they ship.
>
> One app on iPhone, iPad, Android, TV and the web. Podcasterium.

## Before recording scene 7

- RevenueCat store credentials are uploaded for both apps, otherwise the
  purchase fails.
- The sandbox tester exists (App Store Connect → Users and Access →
  Sandbox) or the Play licence tester is set up.
- The paywall shows the real packages, with the trial line. If it still
  shows "Prices are indicative", the offering did not load; do not record
  until it does.

## YouTube upload

- Title: `Podcasterium — watch, listen to and read podcasts (Shipaton 2026)`
- Visibility: **Public**.
- Description: the short description from `submission.md` §1 plus both
  store links.
- No third-party music in the audio track (Content ID would flag it).
