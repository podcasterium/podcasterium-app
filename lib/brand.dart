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
    // Phase 1 shares the DOMOVINA backend and corpus (docs/06 §1, §4).
    cdn: 'https://cdn.domovina.ai',
    rag: 'https://mcp.domovina.ai',
    meili: 'https://search.domovina.ai',
    cutter: 'https://cutter.domovina.ai',
  ),
  // Everything domain-specific is off in phase 1 (docs/06 §3).
  flags: FeatureFlags(),
  sourceCodeUrl: 'https://github.com/podcasterium/podcasterium-app',
  // Plus is sold as monthly and yearly only (docs/DECISIONS.md, 24 Sep 2026).
  plusLifetime: false,
);
