import 'package:podcast_core/podcast_core.dart';

import 'brand.dart';

/// Entry point of the Podcasterium shell. All application code lives in the
/// `podcast_core` package; this shell only says which brand it runs.
Future<void> main() => runPodcastApp(podcasteriumBrand);
