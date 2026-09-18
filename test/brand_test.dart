import 'package:flutter_test/flutter_test.dart';
import 'package:podcasterium/brand.dart';

/// Tripwire for the white-label boundary: the Podcasterium brand must never
/// carry DOMOVINA identity, and phase-1 flags must stay off.
void main() {
  test('brand carries no DOMOVINA identity', () {
    final values = [
      podcasteriumBrand.appName,
      podcasteriumBrand.wordmark,
      podcasteriumBrand.plusDisplayName,
      podcasteriumBrand.logPrefix,
      podcasteriumBrand.urlScheme,
      podcasteriumBrand.androidPackage,
      podcasteriumBrand.iosBundleId,
      podcasteriumBrand.entitlement,
      podcasteriumBrand.endpoints.site,
    ];
    for (final v in values) {
      expect(v.toLowerCase(), isNot(contains('domovina')), reason: v);
    }
  });

  test('platform identity matches docs/03', () {
    expect(podcasteriumBrand.androidPackage, 'com.podcasterium');
    expect(podcasteriumBrand.iosBundleId, 'com.podcasterium');
    expect(podcasteriumBrand.endpoints.site, 'https://podcasterium.com');
  });

  test('phase-1 feature flags are off', () {
    final f = podcasteriumBrand.flags;
    expect(f.certilia, isFalse);
    expect(f.voting, isFalse);
    expect(f.pinka, isFalse);
    expect(f.channelOwnership, isFalse);
    expect(f.domainScore, isFalse);
    expect(f.calBooking, isFalse);
    expect(f.handoff, isTrue);
    expect(f.tv, isTrue);
  });
}
