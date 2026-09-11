import Foundation

/// `summary.json`: AI summary of one episode. The `.en.json` overlay carries
/// the same fields plus `*_en` translations.
struct PodcastSummary: Decodable {
    let version: String
    let generatedAt: String
    let model: String
    let source: SummarySource
    let summary: SummaryContent

    enum CodingKeys: String, CodingKey {
        case version, model, source, summary
        case generatedAt = "generated_at"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        version = c.value(.version, default: "1.0")
        generatedAt = c.value(.generatedAt, default: "")
        model = c.value(.model, default: "")
        source = try c.decodeIfPresent(SummarySource.self, forKey: .source) ?? SummarySource.empty
        summary = try c.decodeIfPresent(SummaryContent.self, forKey: .summary) ?? SummaryContent.empty
    }
}

struct SummarySource: Decodable {
    let filename: String
    let channel: String
    let youtubeId: String
    let title: String
    let uploadDate: String
    let durationSeconds: Int

    enum CodingKeys: String, CodingKey {
        case filename, channel, title
        case youtubeId = "youtube_id"
        case uploadDate = "upload_date"
        case durationSeconds = "duration_seconds"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        filename = c.value(.filename, default: "")
        channel = c.value(.channel, default: "")
        youtubeId = c.value(.youtubeId, default: "")
        title = c.value(.title, default: "")
        uploadDate = c.value(.uploadDate, default: "")
        durationSeconds = c.int(.durationSeconds) ?? 0
    }

    private init() {
        filename = ""; channel = ""; youtubeId = ""; title = ""; uploadDate = ""; durationSeconds = 0
    }
    static let empty = SummarySource()
}

struct SummaryContent: Decodable {
    /// Source-language fields keep the upstream `_hr` key names on the wire;
    /// in the app they are simply "the source language".
    let title: String
    let titleEn: String?
    let abstract: String
    let abstractEn: String?
    let keyTopics: [String]
    let keyTopicsEn: [String]?
    let speakers: [SummarySpeaker]
    let keyPoints: [String]
    let keyPointsEn: [String]?
    let mentionedPeople: [String]
    let mentionedPeopleEn: [String]?
    let mentionedPlaces: [String]
    let mentionedPlacesEn: [String]?
    let mentionedOrganizations: [String]
    let mentionedOrganizationsEn: [String]?
    let language: String
    let contentType: String
    let sentiment: String

    enum CodingKeys: String, CodingKey {
        case speakers, language, sentiment
        case title = "title_hr"
        case titleEn = "title_en"
        case abstract = "abstract_hr"
        case abstractEn = "abstract_en"
        case keyTopics = "key_topics"
        case keyTopicsEn = "key_topics_en"
        case keyPoints = "key_points"
        case keyPointsEn = "key_points_en"
        case mentionedPeople = "mentioned_people"
        case mentionedPeopleEn = "mentioned_people_en"
        case mentionedPlaces = "mentioned_places"
        case mentionedPlacesEn = "mentioned_places_en"
        case mentionedOrganizations = "mentioned_organizations"
        case mentionedOrganizationsEn = "mentioned_organizations_en"
        case contentType = "content_type"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        title = c.value(.title, default: "")
        titleEn = c.optional(.titleEn)
        abstract = c.value(.abstract, default: "")
        abstractEn = c.optional(.abstractEn)
        keyTopics = c.strings(.keyTopics)
        keyTopicsEn = c.optionalStrings(.keyTopicsEn)
        speakers = c.value(.speakers, default: [])
        keyPoints = c.strings(.keyPoints)
        keyPointsEn = c.optionalStrings(.keyPointsEn)
        mentionedPeople = c.strings(.mentionedPeople)
        mentionedPeopleEn = c.optionalStrings(.mentionedPeopleEn)
        mentionedPlaces = c.strings(.mentionedPlaces)
        mentionedPlacesEn = c.optionalStrings(.mentionedPlacesEn)
        mentionedOrganizations = c.strings(.mentionedOrganizations)
        mentionedOrganizationsEn = c.optionalStrings(.mentionedOrganizationsEn)
        language = c.value(.language, default: "")
        contentType = c.value(.contentType, default: "")
        sentiment = c.value(.sentiment, default: "")
    }

    private init() {
        title = ""; titleEn = nil; abstract = ""; abstractEn = nil; keyTopics = []; keyTopicsEn = nil
        speakers = []; keyPoints = []; keyPointsEn = nil; mentionedPeople = []; mentionedPeopleEn = nil
        mentionedPlaces = []; mentionedPlacesEn = nil; mentionedOrganizations = []; mentionedOrganizationsEn = nil
        language = ""; contentType = ""; sentiment = ""
    }
    static let empty = SummaryContent()

    // Language-aware accessors: English when requested and present, else source.
    func title(english: Bool) -> String { english ? (titleEn ?? title) : title }
    func abstract(english: Bool) -> String { english ? (abstractEn ?? abstract) : abstract }
    func keyTopics(english: Bool) -> [String] { english ? (keyTopicsEn ?? keyTopics) : keyTopics }
    func keyPoints(english: Bool) -> [String] { english ? (keyPointsEn ?? keyPoints) : keyPoints }
    func mentionedPeople(english: Bool) -> [String] { english ? (mentionedPeopleEn ?? mentionedPeople) : mentionedPeople }
    func mentionedPlaces(english: Bool) -> [String] { english ? (mentionedPlacesEn ?? mentionedPlaces) : mentionedPlaces }
    func mentionedOrganizations(english: Bool) -> [String] {
        english ? (mentionedOrganizationsEn ?? mentionedOrganizations) : mentionedOrganizations
    }

    /// Diarization id ("SPEAKER_00") to display name.
    var speakerNames: [String: String] {
        Dictionary(speakers.map { ($0.id, $0.displayName ?? $0.roleLabel(english: false)) }, uniquingKeysWith: { a, _ in a })
    }
}

struct SummarySpeaker: Decodable, Identifiable {
    let id: String
    let suggestedName: String
    let role: String
    let roleEn: String?

    enum CodingKeys: String, CodingKey {
        case id, role
        case suggestedName = "suggested_name"
        case roleEn = "role_en"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = c.value(.id, default: "")
        suggestedName = c.value(.suggestedName, default: "")
        role = c.value(.role, default: "")
        roleEn = c.optional(.roleEn)
    }

    func roleLabel(english: Bool) -> String {
        let raw = english ? (roleEn ?? role) : role
        return raw.prefix(1).uppercased() + raw.dropFirst()
    }

    /// The name when it differs from the role; the pipeline writes the role
    /// as the name when the speaker never introduces themselves.
    var displayName: String? {
        let raw = suggestedName.trimmingCharacters(in: .whitespaces)
        if raw.isEmpty || raw.lowercased() == role.lowercased() { return nil }
        return raw
    }
}
