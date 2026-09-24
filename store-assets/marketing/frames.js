// Captions and source screenshots for the store listing frames.
// Every claim must be visible in the app; numbers are rounded down only
// (3,237 episodes on 24 Sep 2026 -> "3,000+"). No other store or platform
// is named, because Apple rejects screenshots that mention them.
export const FRAMES = [
  {
    shot: '01-home',
    kicker: 'Watch · Listen · Read',
    title: 'Podcasts you can read',
    sub: 'Every episode as video, audio and an article — chapter by chapter.',
  },
  {
    shot: '02-player',
    kicker: 'Chapters',
    title: 'Jump to the minute that matters',
    sub: 'Chapters beside the player, background audio, speed control.',
  },
  {
    shot: '03-article',
    kicker: 'Read',
    title: 'A two-hour talk, read in ten minutes',
    sub: 'Each chapter retold as an article, its timestamp one tap away.',
  },
  {
    shot: '04-search',
    kicker: 'Search',
    title: 'Search inside the conversations',
    sub: 'Typo-tolerant search across 3,000+ processed episodes.',
  },
  {
    shot: '05-person',
    kicker: 'People',
    title: 'Everyone who speaks — or is mentioned',
    sub: 'A page for every person, with every episode they appear in.',
  },
  {
    shot: '06-channel',
    kicker: 'Shows',
    title: 'Follow the shows you love',
    sub: 'Browse by channel and pick up where you left off.',
  },
];

// Output sizes. `source` is the folder of raw captures; `cropTop` removes the
// iOS status bar when the capture is reused for Android.
export const DEVICES = {
  iphone: {
    width: 1320, height: 2868, source: 'ios-iphone', panorama: true,
    deviceWidth: 0.78, top: 0.255, radius: 0.13, bezel: 0.022, cropTop: 0,
  },
  ipad: {
    width: 2064, height: 2752, source: 'ios-ipad', panorama: true,
    deviceWidth: 0.78, top: 0.215, radius: 0.045, bezel: 0.014, cropTop: 0,
  },
  android: {
    width: 1080, height: 1920, source: 'ios-iphone', panorama: false,
    deviceWidth: 0.7, top: 0.235, radius: 0.1, bezel: 0.022, cropTop: 186,
  },
};
