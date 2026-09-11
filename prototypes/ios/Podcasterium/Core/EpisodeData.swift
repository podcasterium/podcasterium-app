import Foundation

enum MediaKind { case video, audio, none }

/// Everything the episode screen needs, loaded in parallel from the CDN.
/// `info` and the media probe are required; every AI asset is optional
/// because the pipeline lags publication by hours or days.
struct EpisodeData {
    let youtubeId: String
    let info: PodcastInfo
    let summary: PodcastSummary?
    let summaryEn: PodcastSummary?
    let outline: PodcastOutline?
    let article: PodcastArticle?
    let articleEn: PodcastArticle?
    let timeline: SpeakerTimeline?
    let mediaURL: URL?
    let mediaKind: MediaKind

    var hasMedia: Bool { mediaKind != .none }
    var isAudioOnly: Bool { mediaKind == .audio }
    var hasArticle: Bool { article != nil }
    /// The article is the core artifact; a translation without it is useless.
    var hasEnglish: Bool { articleEn != nil }

    func article(english: Bool) -> PodcastArticle? { english ? (articleEn ?? article) : article }
    func summary(english: Bool) -> PodcastSummary? { english ? (summaryEn ?? summary) : summary }

    func displayTitle(english: Bool) -> String {
        let t = summary(english: english)?.summary.title(english: english) ?? ""
        return t.isEmpty ? info.title : t
    }

    /// Chapters for the chapter list: the AI outline when present, otherwise
    /// the platform's own chapters from `info.json`.
    var chapters: [(seconds: TimeInterval, title: String)] {
        if let outline, !outline.allChapters.isEmpty {
            return outline.allChapters.map { ($0.seconds, $0.topic) }
        }
        return info.chapters.map { ($0.startTime, $0.title) }
    }

    var speakerNames: [String: String] { summary?.summary.speakerNames ?? [:] }

    static func load(youtubeId id: String, client: CDNClient = .shared) async throws -> EpisodeData {
        async let info = client.fetch(PodcastInfo.self, from: CDN.info(id), optional: true)
        async let summary = client.fetch(PodcastSummary.self, from: CDN.summary(id), optional: true)
        async let summaryEn = client.fetch(PodcastSummary.self, from: CDN.summaryEn(id), optional: true)
        async let outline = client.fetch(PodcastOutline.self, from: CDN.outline(id), optional: true)
        async let article = client.fetch(PodcastArticle.self, from: CDN.article(id), optional: true)
        async let articleEn = client.fetch(PodcastArticle.self, from: CDN.articleEn(id), optional: true)
        async let srt = client.fetchText(from: CDN.diarizedSrt(id))
        async let media = resolveMedia(id, client: client)

        guard let info = try await info else { throw CDNError.episodeNotFound(id) }
        let timeline = (try? await srt).flatMap { $0 }.map(SRTParser.parse)
        let resolved = await media
        return EpisodeData(
            youtubeId: id,
            info: info,
            summary: (try? await summary) ?? nil,
            summaryEn: (try? await summaryEn) ?? nil,
            outline: (try? await outline) ?? nil,
            article: (try? await article) ?? nil,
            articleEn: (try? await articleEn) ?? nil,
            timeline: timeline,
            mediaURL: resolved.url,
            mediaKind: resolved.kind
        )
    }

    /// Mandatory probe order from the upstream data contract: H.264 video,
    /// then audio-only MP3, then the legacy source-codec video. Probes run
    /// concurrently; priority is applied afterwards.
    static func resolveMedia(_ id: String, client: CDNClient) async -> (url: URL?, kind: MediaKind) {
        async let h264 = client.exists(CDN.videoH264Probe(id))
        async let audio = client.exists(CDN.audioProbe(id))
        async let legacy = client.exists(CDN.videoProbe(id))
        if await h264 { return (CDN.videoH264(id), .video) }
        if await audio { return (CDN.audio(id), .audio) }
        if await legacy { return (CDN.video(id), .video) }
        return (nil, .none)
    }
}
