import Foundation

/// `outline.json`: thematic blocks ("iterations") with chapters.
struct PodcastOutline: Decodable {
    let iterations: [OutlineIteration]

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        iterations = c.value(.iterations, default: [])
    }

    enum CodingKeys: String, CodingKey { case iterations }

    var allChapters: [OutlineChapter] { iterations.flatMap(\.chapters) }
}

struct OutlineIteration: Decodable, Identifiable {
    let iterationNumber: Int
    let startTime: String
    let endTime: String
    let theme: String
    let reasonForCut: String
    let chapters: [OutlineChapter]

    var id: Int { iterationNumber }

    enum CodingKeys: String, CodingKey {
        case theme, chapters
        case iterationNumber = "iteration_number"
        case startTime = "start_time"
        case endTime = "end_time"
        case reasonForCut = "reason_for_cut"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        iterationNumber = c.int(.iterationNumber) ?? 0
        startTime = c.value(.startTime, default: "")
        endTime = c.value(.endTime, default: "")
        theme = c.value(.theme, default: "")
        reasonForCut = c.value(.reasonForCut, default: "")
        chapters = c.value(.chapters, default: [])
    }
}

struct OutlineChapter: Decodable, Identifiable, Hashable {
    let timestamp: String
    let topic: String

    var id: String { timestamp + topic }
    var seconds: TimeInterval { Timecode.seconds(timestamp) }

    enum CodingKeys: String, CodingKey { case timestamp, topic }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        timestamp = c.value(.timestamp, default: "")
        topic = c.value(.topic, default: "")
    }
}
