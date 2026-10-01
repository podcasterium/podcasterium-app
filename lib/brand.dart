import 'package:flutter/painting.dart' show Color;
import 'package:podcast_core/podcast_core.dart';

/// The Podcasterium brand: everything that distinguishes this shell from
/// DOMOVINA.ai and lives in Dart. Non-Dart brand material (icons, splash,
/// manifest, index.html meta) is generated from the brand manifest.
///
/// Open decisions (docs/DECISIONS.md, D4/D6/D7) are marked TODO; the values
/// here are neutral placeholders that let the shell build today.
const BrandConfig podcasteriumBrand = BrandConfig(
  appName: 'Podcasterium',
  wordmark: 'Podcasterium',
  wordmarkAccent: '',
  plusDisplayName: 'Podcasterium Plus',
  logPrefix: 'Podcasterium',
  // Mirrors the bundle ID, like upstream (docs/03 §1).
  urlScheme: 'com.podcasterium',
  androidPackage: 'com.podcasterium',
  iosBundleId: 'com.podcasterium',
  // App Store Connect record created 23 Sep 2026.
  iosAppStoreId: '6815415892',
  entitlement: 'podcasterium_plus',
  // TODO(D4): placeholder neutral palette until colours are decided.
  seed: Color(0xFF2B4C7E),
  accent: Color(0xFFD97706),
  logoAsset: 'assets/brand/logo_1024.png',
  splashAsset: 'assets/brand/splash.png',
  defaultLocale: 'en',
  // Phase 1 shares the DOMOVINA corpus, whose articles are Croatian.
  defaultEpisodeLanguage: 'hr',
  endpoints: Endpoints(
    site: 'https://podcasterium.com',
    // Phase 1 shares the DOMOVINA backend and corpus (docs/06 §1, §4), but
    // only under podcasterium.com names: cdn is a second custom domain on
    // the same R2 bucket, the others go through infra/edge-proxy.
    cdn: 'https://cdn.podcasterium.com',
    rag: 'https://mcp.podcasterium.com',
    meili: 'https://search.podcasterium.com',
    cutter: 'https://cutter.podcasterium.com',
  ),
  // Everything domain-specific is off in phase 1 (docs/06 §3).
  // The Plus button in the home header is how App Review finds the
  // in-app purchases (rejection of 1.0.0 on 30 Sep 2026, Guideline 2.1(b)).
  flags: FeatureFlags(plusInHeader: true),
  sourceCodeUrl: 'https://github.com/podcasterium/podcasterium-app',
  // Plus is sold as monthly and yearly only (docs/DECISIONS.md, 24 Sep 2026).
  plusLifetime: false,
  // English-language shows in the shared corpus, surfaced first on the
  // home page, the channel list and the search chips.
  featuredChannels: ['subclub', 'launched', 'catholic_futurist'],
);
