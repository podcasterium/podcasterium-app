import Foundation

/// `/channels/data/index.json`
struct ChannelIndex: Decodable {
    let version: String
    let channelCount: Int
    let channels: [ChannelSummary]

    enum CodingKeys: String, CodingKey {
        case version, channels
        case channelCount = "channel_count"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        version = c.value(.version, default: "1.0")
        channelCount = c.int(.channelCount) ?? 0
        channels = c.value(.channels, default: [])
    }
}

struct ChannelSummary: Decodable, Identifiable, Hashable {
    let id: String
    let name: String
    let avatarSquare: String?
    let avatarCover: String?
    let avatarCoverDimensions: ImageDimensions?
    let youtubeChannelUrl: String
    let youtubeChannelId: String?
    let youtubePlaylistUrl: String?
    let followerCount: Int?
    let videoCount: Int
    let totalDurationSeconds: Int
    /// Corpus-specific quality score (0-100), null when the corpus has none.
    let avgDomainScore: Int?
    let latestVideo: LatestVideo?

    enum CodingKeys: String, CodingKey {
        case id, name
        case avatarSquare = "avatar_square"
        case avatarCover = "avatar_cover"
        case avatarCoverDimensions = "avatar_cover_dimensions"
        case youtubeChannelUrl = "youtube_channel_url"
        case youtubeChannelId = "youtube_channel_id"
        case youtubePlaylistUrl = "youtube_playlist_url"
        case followerCount = "follower_count"
        case videoCount = "video_count"
        case totalDurationSeconds = "total_duration_seconds"
        case avgDomainScore = "avg_magisterium_score"
        case latestVideo = "latest_video"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = c.value(.id, default: "")
        name = c.value(.name, default: "")
        avatarSquare = c.optional(.avatarSquare)
        avatarCover = c.optional(.avatarCover)
        avatarCoverDimensions = c.optional(.avatarCoverDimensions)
        youtubeChannelUrl = c.value(.youtubeChannelUrl, default: "")
        youtubeChannelId = ChannelId.canonical(explicit: c.optional(.youtubeChannelId), url: youtubeChannelUrl)
        youtubePlaylistUrl = c.optional(.youtubePlaylistUrl)
        followerCount = c.int(.followerCount)
        videoCount = c.int(.videoCount) ?? 0
        totalDurationSeconds = c.int(.totalDurationSeconds) ?? 0
        avgDomainScore = c.int(.avgDomainScore)
        latestVideo = c.optional(.latestVideo)
    }

    var durationDisplay: String { Timecode.compact(totalDurationSeconds) }

    /// True when the cover is a real banner rather than a square avatar.
    var hasBannerCover: Bool {
        guard let d = avatarCoverDimensions, avatarCover != nil else { return false }
        return d.width != d.height
    }

    var avatarURL: URL { CDN.channelAvatar(id) }

    static func == (lhs: ChannelSummary, rhs: ChannelSummary) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct ImageDimensions: Decodable, Hashable {
    let width: Int
    let height: Int

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        width = c.int(.width) ?? 0
        height = c.int(.height) ?? 0
    }

    enum CodingKeys: String, CodingKey { case width, height }

    var aspectRatio: CGFloat { height > 0 ? CGFloat(width) / CGFloat(height) : 1 }
}

struct LatestVideo: Decodable, Hashable {
    let id: String
    let date: String
    let title: String

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = c.value(.id, default: "")
        date = c.value(.date, default: "")
        title = c.value(.title, default: "")
    }

    enum CodingKeys: String, CodingKey { case id, date, title }
}
