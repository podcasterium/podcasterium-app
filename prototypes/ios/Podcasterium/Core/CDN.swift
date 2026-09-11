import Foundation

/// Central definition of every CDN URL. Mirrors the upstream
/// `lib/services/cdn_config.dart`; keep the two in sync.
enum CDN {
    static var base: URL { BrandConfig.current.cdnBase }

    /// Channel listing files change as new episodes arrive, yet the uploader
    /// marks every file `Cache-Control: immutable`. A 5-minute bucket keeps
    /// listings fresh while still letting the edge serve one URL to many
    /// clients. Per-episode JSON is truly immutable and gets no buster.
    static var listingCacheBuster: String {
        "v=\(Int(Date().timeIntervalSince1970 / 300))"
    }

    private static func url(_ path: String, bust: Bool = false) -> URL {
        var s = base.absoluteString + path
        if bust { s += "?" + listingCacheBuster }
        return URL(string: s)!
    }

    // MARK: Channels

    static var channelsIndex: URL { url("/channels/data/index.json", bust: true) }
    static func channel(_ id: String) -> URL { url("/channels/data/\(id).json", bust: true) }
    static func channelAvatar(_ id: String) -> URL { url("/channels/images/\(id)/avatar_square.jpg", bust: true) }
    static func channelCover(_ id: String) -> URL { url("/channels/images/\(id)/avatar_cover.jpg", bust: true) }

    // MARK: Per-episode JSON (immutable)

    static func info(_ ytId: String) -> URL { url("/data/\(ytId)/info.json") }
    static func summary(_ ytId: String) -> URL { url("/data/\(ytId)/summary.json") }
    static func outline(_ ytId: String) -> URL { url("/data/\(ytId)/outline.json") }
    static func article(_ ytId: String) -> URL { url("/data/\(ytId)/article.json") }
    /// English overlays: a superset of the source-language file with `_en`
    /// fields added. 404 until the pipeline has produced the translation.
    static func summaryEn(_ ytId: String) -> URL { url("/data/\(ytId)/summary.en.json") }
    static func articleEn(_ ytId: String) -> URL { url("/data/\(ytId)/article.en.json") }
    static func diarizedSrt(_ ytId: String) -> URL { url("/data/\(ytId)/diarized.srt") }

    // MARK: Media

    /// H.264 transcode, hardware-decodable everywhere. Supports HTTP range.
    static func videoH264(_ ytId: String) -> URL { url("/data/\(ytId)/video_h264.mp4") }
    /// Source codec (may be AV1/VP9). Legacy fallback.
    static func video(_ ytId: String) -> URL { url("/data/\(ytId)/video.mp4") }
    /// Audio-only episodes (podcast feeds without a video source).
    static func audio(_ ytId: String) -> URL { url("/data/\(ytId)/audio.mp3") }
    /// Probe URLs carry a cache buster because the edge caches 404s for hours.
    static func videoH264Probe(_ ytId: String) -> URL { url("/data/\(ytId)/video_h264.mp4", bust: true) }
    static func videoProbe(_ ytId: String) -> URL { url("/data/\(ytId)/video.mp4", bust: true) }
    static func audioProbe(_ ytId: String) -> URL { url("/data/\(ytId)/audio.mp3", bust: true) }

    // MARK: Images

    /// Full-resolution PNG (1280x720, about 800 KB). Canonical identity of the
    /// thumbnail and the last-resort fallback.
    static func thumbnail(_ ytId: String) -> URL { url("/images/\(ytId)/thumbnail.png") }
    /// Pre-generated WebP variants, sorted ascending.
    static let thumbVariantWidths = [320, 640, 1280]
    static func thumbnailVariant(_ ytId: String, width: Int) -> URL {
        url("/images/\(ytId)/thumb-\(width).webp")
    }
    /// Smallest WebP variant covering `targetPixels`, falling back to the PNG.
    /// Variants do not exist for every episode, so callers try in order.
    static func thumbnailCandidates(_ ytId: String, targetPixels: CGFloat) -> [URL] {
        let width = thumbVariantWidths.first { CGFloat($0) >= targetPixels } ?? thumbVariantWidths.last!
        return [thumbnailVariant(ytId, width: width), thumbnail(ytId)]
    }
    /// Frame captured at an article section's timestamp ("HH:MM:SS").
    static func screenshot(_ ytId: String, timestamp: String) -> URL {
        url("/images/\(ytId)/screenshots/\(timestamp.replacingOccurrences(of: ":", with: "-")).png")
    }

    /// Extracts the 11-character episode id from a canonical thumbnail URL.
    static func episodeId(fromThumbnail urlString: String) -> String? {
        let pattern = #"/images/([A-Za-z0-9_-]{11})/thumbnail\.png$"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: urlString, range: NSRange(urlString.startIndex..., in: urlString)),
              let range = Range(match.range(at: 1), in: urlString) else { return nil }
        return String(urlString[range])
    }
}
