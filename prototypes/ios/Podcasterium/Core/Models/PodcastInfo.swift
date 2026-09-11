import Foundation

/// `info.json`: yt-dlp metadata plus pipeline markers (`_source`, `_yt_matched`).
/// The very large `formats`, `thumbnails` and caption maps are ignored.
struct PodcastInfo: Decodable {
    let id: String
    let title: String
    let channel: String
    let channelId: String
    let uploader: String
    /// YYYYMMDD
    let uploadDate: String
    let duration: Int
    let durationString: String
    let viewCount: Int
    let likeCount: Int
    let commentCount: Int?
    let description: String
    let thumbnail: String
    let webpageUrl: String
    let tags: [String]
    let categories: [String]
    let chapters: [YtChapter]
    /// `youtube` (default), `x`, `beamly`, ...
    let source: String
    let extractor: String
    let soundLink: String?
    /// False when the episode has no YouTube video (audio-only feed).
    let ytMatched: Bool
    let playableInEmbed: Bool

    enum CodingKeys: String, CodingKey {
        case id, title, channel, uploader, duration, description, thumbnail, tags, categories, chapters, extractor
        case channelId = "channel_id"
        case uploadDate = "upload_date"
        case durationString = "duration_string"
        case viewCount = "view_count"
        case likeCount = "like_count"
        case commentCount = "comment_count"
        case webpageUrl = "webpage_url"
        case source = "_source"
        case soundLink = "_sound_link"
        case ytMatched = "_yt_matched"
        case playableInEmbed = "playable_in_embed"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = c.value(.id, default: "")
        title = c.value(.title, default: "")
        let uploaderRaw: String = c.value(.uploader, default: "")
        let channelRaw: String = c.value(.channel, default: "")
        channel = channelRaw.isEmpty ? uploaderRaw : channelRaw
        channelId = c.value(.channelId, default: "")
        uploader = uploaderRaw
        uploadDate = c.value(.uploadDate, default: "")
        duration = c.int(.duration) ?? 0
        durationString = c.value(.durationString, default: "")
        viewCount = c.int(.viewCount) ?? 0
        likeCount = c.int(.likeCount) ?? 0
        commentCount = c.int(.commentCount)
        description = c.value(.description, default: "")
        thumbnail = c.value(.thumbnail, default: "")
        webpageUrl = c.value(.webpageUrl, default: "")
        tags = c.strings(.tags)
        categories = c.strings(.categories)
        chapters = c.value(.chapters, default: [])
        source = c.value(.source, default: "youtube")
        extractor = c.value(.extractor, default: "youtube")
        soundLink = c.optional(.soundLink)
        ytMatched = c.value(.ytMatched, default: true)
        playableInEmbed = c.value(.playableInEmbed, default: true)
    }

    var isX: Bool {
        source == "x" || extractor == "twitter" || webpageUrl.contains("x.com/") || webpageUrl.contains("twitter.com/")
    }

    /// Link to the original episode. Synthetic ids (X, audio feeds) point to
    /// `webpage_url`; real YouTube ids build a watch URL.
    var sourceURL: URL? {
        if isX || !ytMatched { return URL(string: webpageUrl) }
        return URL(string: "https://www.youtube.com/watch?v=\(id)")
    }

    var uploadDateValue: Date? { DateText.parse(uploadDate) }
}

struct YtChapter: Decodable {
    let startTime: TimeInterval
    let title: String

    enum CodingKeys: String, CodingKey {
        case title
        case startTime = "start_time"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        startTime = c.value(.startTime, default: 0.0)
        title = c.value(.title, default: "")
    }
}
