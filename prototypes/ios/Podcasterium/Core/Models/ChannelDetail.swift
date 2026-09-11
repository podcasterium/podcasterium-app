import Foundation

/// `/channels/data/{channel_id}.json`
struct ChannelDetail: Decodable {
    let version: String
    let id: String
    let name: String
    let avatarSquare: String?
    let avatarCover: String?
    let youtubeChannelUrl: String
    let youtubeChannelId: String?
    let youtubePlaylistUrl: String?
    let description: String?
    let tags: [String]
    let followerCount: Int?
    let videoCount: Int
    let totalDurationSeconds: Int
    let avgDomainScore: Int?
    let latestVideoDate: String?
    let videos: [ChannelVideo]

    enum CodingKeys: String, CodingKey {
        case version, id, name, description, tags, videos
        case avatarSquare = "avatar_square"
        case avatarCover = "avatar_cover"
        case youtubeChannelUrl = "youtube_channel_url"
        case youtubeChannelId = "youtube_channel_id"
        case youtubePlaylistUrl = "youtube_playlist_url"
        case followerCount = "follower_count"
        case videoCount = "video_count"
        case totalDurationSeconds = "total_duration_seconds"
        case avgDomainScore = "avg_magisterium_score"
        case latestVideoDate = "latest_video_date"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        version = c.value(.version, default: "1.0")
        id = c.value(.id, default: "")
        name = c.value(.name, default: "")
        avatarSquare = c.optional(.avatarSquare)
        avatarCover = c.optional(.avatarCover)
        youtubeChannelUrl = c.value(.youtubeChannelUrl, default: "")
        youtubeChannelId = ChannelId.canonical(explicit: c.optional(.youtubeChannelId), url: youtubeChannelUrl)
        youtubePlaylistUrl = c.optional(.youtubePlaylistUrl)
        description = c.optional(.description)
        tags = c.strings(.tags)
        followerCount = c.int(.followerCount)
        videoCount = c.int(.videoCount) ?? 0
        totalDurationSeconds = c.int(.totalDurationSeconds) ?? 0
        avgDomainScore = c.int(.avgDomainScore)
        latestVideoDate = c.optional(.latestVideoDate)
        videos = c.value(.videos, default: [])
    }

    /// True when the channel is a podcast feed rather than a YouTube channel.
    var isAudioSource: Bool {
        guard let host = URL(string: youtubeChannelUrl)?.host, !host.isEmpty else { return false }
        return !host.contains("youtube.com") && !host.contains("youtu.be")
    }
}

struct ChannelVideo: Decodable, Identifiable {
    let id: String
    let title: String
    let titleLocalized: String?
    let date: String?
    let durationSeconds: Int?
    let durationDisplay: String?
    let views: Int?
    let likes: Int?
    let thumbnail: String?
    let youtubeUrl: String?
    let abstract: String?
    let topics: [String]
    let speakers: [String]
    let domainScore: Int?
    let pipeline: VideoPipeline?
    let source: String?
    let soundLink: String?

    enum CodingKeys: String, CodingKey {
        case id, title, date, views, likes, thumbnail, abstract, topics, speakers, pipeline, source
        case titleLocalized = "title_hr"
        case durationSeconds = "duration_seconds"
        case durationDisplay = "duration_display"
        case youtubeUrl = "youtube_url"
        case domainScore = "magisterium_score"
        case soundLink = "sound_link"
        case legacySource = "_source"
        case legacySoundLink = "_sound_link"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = c.value(.id, default: "")
        title = c.value(.title, default: "")
        titleLocalized = c.optional(.titleLocalized)
        date = c.optional(.date)
        durationSeconds = c.int(.durationSeconds)
        durationDisplay = c.optional(.durationDisplay)
        views = c.int(.views)
        likes = c.int(.likes)
        thumbnail = c.optional(.thumbnail)
        youtubeUrl = c.optional(.youtubeUrl)
        abstract = c.optional(.abstract)
        topics = c.strings(.topics)
        // Speakers arrive either as plain strings or as {id, suggested_name, role}.
        let refs: [SpeakerRef] = c.value(.speakers, default: [])
        speakers = refs.map(\.name).filter { !$0.isEmpty }
        domainScore = c.int(.domainScore)
        pipeline = c.optional(.pipeline)
        source = c.optional(.source) ?? c.optional(.legacySource)
        soundLink = c.optional(.soundLink) ?? c.optional(.legacySoundLink)
    }

    /// Prefer the pipeline-cleaned title over the raw platform title.
    var displayTitle: String { titleLocalized ?? title }

    var thumbnailCandidates: [URL] {
        var urls = CDN.thumbnailCandidates(id, targetPixels: 640)
        if let thumbnail, let url = URL(string: thumbnail), !urls.contains(url) { urls.append(url) }
        return urls
    }

    var durationText: String {
        if let durationDisplay, !durationDisplay.isEmpty { return durationDisplay }
        if let durationSeconds { return Timecode.display(TimeInterval(durationSeconds)) }
        return ""
    }
}

/// Polymorphic speaker entry in channel listings.
struct SpeakerRef: Decodable {
    let name: String

    init(from decoder: Decoder) throws {
        if let single = try? decoder.singleValueContainer(), let s = try? single.decode(String.self) {
            name = s
            return
        }
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = c.optional(.suggestedName) ?? c.optional(.name) ?? ""
    }

    enum CodingKeys: String, CodingKey {
        case name
        case suggestedName = "suggested_name"
    }
}

struct VideoPipeline: Decodable {
    let hasTranscript: Bool
    let hasDiarized: Bool
    let hasSummary: Bool
    let hasArticle: Bool
    let hasDomainScore: Bool

    enum CodingKeys: String, CodingKey {
        case hasTranscript = "has_transcript"
        case hasDiarized = "has_diarized"
        case hasSummary = "has_summary"
        case hasArticle = "has_article"
        case hasDomainScore = "has_magisterium"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        hasTranscript = c.value(.hasTranscript, default: false)
        hasDiarized = c.value(.hasDiarized, default: false)
        hasSummary = c.value(.hasSummary, default: false)
        hasArticle = c.value(.hasArticle, default: false)
        hasDomainScore = c.value(.hasDomainScore, default: false)
    }
}
