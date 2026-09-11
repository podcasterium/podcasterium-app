import Foundation

/// `article.json`: the AI-written article, in thematic blocks and sections.
/// Section `content` is Markdown with inline emphasis.
struct PodcastArticle: Decodable {
    let metadata: ArticleMetadata
    let iterations: [ArticleIteration]

    enum CodingKeys: String, CodingKey { case metadata, iterations }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        metadata = try c.decodeIfPresent(ArticleMetadata.self, forKey: .metadata) ?? .empty
        iterations = c.value(.iterations, default: [])
    }

    var sectionCount: Int { iterations.reduce(0) { $0 + $1.sections.count } }
}

struct ArticleMetadata: Decodable {
    let sourceFile: String
    let generatedAt: String
    let model: String

    enum CodingKeys: String, CodingKey {
        case model
        case sourceFile = "source_file"
        case generatedAt = "generated_at"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        sourceFile = c.value(.sourceFile, default: "")
        generatedAt = c.value(.generatedAt, default: "")
        model = c.value(.model, default: "")
    }

    private init() { sourceFile = ""; generatedAt = ""; model = "" }
    static let empty = ArticleMetadata()
}

struct ArticleIteration: Decodable, Identifiable {
    let iterationNumber: Int
    let startTime: String
    let endTime: String
    let theme: String
    let themeEn: String?
    let reasonForCut: String?
    let reasonForCutEn: String?
    let sections: [ArticleSection]

    var id: Int { iterationNumber }

    enum CodingKeys: String, CodingKey {
        case theme, sections
        case iterationNumber = "iteration_number"
        case startTime = "start_time"
        case endTime = "end_time"
        case themeEn = "theme_en"
        case reasonForCut = "reason_for_cut"
        case reasonForCutEn = "reason_for_cut_en"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        iterationNumber = c.int(.iterationNumber) ?? 0
        startTime = c.value(.startTime, default: "")
        endTime = c.value(.endTime, default: "")
        theme = c.value(.theme, default: "")
        themeEn = c.optional(.themeEn)
        reasonForCut = c.optional(.reasonForCut)
        reasonForCutEn = c.optional(.reasonForCutEn)
        sections = c.value(.sections, default: [])
    }

    func theme(english: Bool) -> String { english ? (themeEn ?? theme) : theme }
}

struct ArticleSection: Decodable, Identifiable {
    let subtitle: String
    let subtitleEn: String?
    /// HH:MM:SS
    let screenshotTimestamp: String
    let screenshotDescription: String
    let screenshotDescriptionEn: String?
    let content: String
    let contentEn: String?
    let keywords: [String]
    let keywordsEn: [String]?
    let entities: [String]
    let entitiesEn: [String]?

    var id: String { screenshotTimestamp + subtitle }
    var seconds: TimeInterval { Timecode.seconds(screenshotTimestamp) }

    enum CodingKeys: String, CodingKey {
        case subtitle, content, keywords, entities
        case subtitleEn = "subtitle_en"
        case screenshotTimestamp = "screenshot_timestamp"
        case screenshotDescription = "screenshot_description"
        case screenshotDescriptionEn = "screenshot_description_en"
        case contentEn = "content_en"
        case keywordsEn = "keywords_en"
        case entitiesEn = "entities_en"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        subtitle = c.value(.subtitle, default: "")
        subtitleEn = c.optional(.subtitleEn)
        screenshotTimestamp = c.value(.screenshotTimestamp, default: "")
        screenshotDescription = c.value(.screenshotDescription, default: "")
        screenshotDescriptionEn = c.optional(.screenshotDescriptionEn)
        content = c.value(.content, default: "")
        contentEn = c.optional(.contentEn)
        keywords = c.strings(.keywords)
        keywordsEn = c.optionalStrings(.keywordsEn)
        entities = c.strings(.entities)
        entitiesEn = c.optionalStrings(.entitiesEn)
    }

    func subtitle(english: Bool) -> String { english ? (subtitleEn ?? subtitle) : subtitle }
    func content(english: Bool) -> String { english ? (contentEn ?? content) : content }
    func keywords(english: Bool) -> [String] { english ? (keywordsEn ?? keywords) : keywords }
    func screenshotDescription(english: Bool) -> String {
        english ? (screenshotDescriptionEn ?? screenshotDescription) : screenshotDescription
    }
}
