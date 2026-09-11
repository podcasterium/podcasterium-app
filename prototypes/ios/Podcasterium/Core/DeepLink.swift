import Foundation

/// A screen the app can be opened on from outside.
enum DeepLink: Equatable {
    case channel(id: String)
    case episode(id: String, seconds: TimeInterval?, english: Bool)

    /// Custom scheme registered in the project spec (`CFBundleURLTypes`).
    static let scheme = "podcasterium"

    /// Parses every URL shape the app accepts:
    ///
    /// - `podcasterium://episode/<id>[?t=<seconds>][&lang=en]`
    /// - `podcasterium://channel/<id>`
    /// - The upstream web routes on any host, so links shared from the
    ///   reader open here once universal links are configured:
    ///   `/v/:id`, `/v/:id/en`, `/v/:id/read`, `/episode/:id`,
    ///   `/m/:id`, `/m/:id/t/:seconds`, `/m/:id/t/:seconds/en`, `/c/:slug`
    /// - YouTube links (`youtube.com/watch?v=<id>[&t=<seconds>]`,
    ///   `youtu.be/<id>`), because the episode id is the YouTube id.
    ///
    /// Returns `nil` for anything else; the caller ignores unknown links.
    static func parse(_ url: URL) -> DeepLink? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        let query = Dictionary(
            (components.queryItems ?? []).map { ($0.name, $0.value ?? "") },
            uniquingKeysWith: { first, _ in first }
        )
        let seconds = query["t"].flatMap(parseSeconds)
        let english = query["lang"]?.lowercased() == "en"

        if components.scheme?.lowercased() == scheme {
            // podcasterium://episode/<id> puts "episode" in the host slot.
            var parts = [components.host ?? ""] + components.path.split(separator: "/").map(String.init)
            parts.removeAll { $0.isEmpty }
            return route(parts, seconds: seconds, english: english)
        }

        let host = (components.host ?? "").lowercased()
        var parts = components.path.split(separator: "/").map(String.init)
        parts.removeAll { $0.isEmpty }

        if host.hasSuffix("youtube.com") {
            if parts.first == "watch", let id = query["v"], isEpisodeId(id) {
                return .episode(id: id, seconds: seconds, english: false)
            }
            if parts.count == 2, ["shorts", "live", "embed"].contains(parts[0]), isEpisodeId(parts[1]) {
                return .episode(id: parts[1], seconds: seconds, english: false)
            }
            return nil
        }
        if host == "youtu.be" {
            guard let id = parts.first, isEpisodeId(id) else { return nil }
            return .episode(id: id, seconds: seconds, english: false)
        }
        return route(parts, seconds: seconds, english: english)
    }

    /// Path-segment grammar shared by the custom scheme and the web routes.
    private static func route(_ parts: [String], seconds: TimeInterval?, english: Bool) -> DeepLink? {
        guard parts.count >= 2 else { return nil }
        switch parts[0] {
        case "c", "channel":
            return .channel(id: parts[1])
        case "v", "m", "episode":
            let id = parts[1]
            guard isEpisodeId(id) else { return nil }
            var rest = Array(parts.dropFirst(2))
            var seconds = seconds
            var english = english
            if rest.last == "en" {
                english = true
                rest.removeLast()
            }
            if rest.last == "read" { rest.removeLast() }
            if rest.count == 2, rest[0] == "t", let t = parseSeconds(rest[1]) {
                seconds = t
                rest.removeAll()
            }
            guard rest.isEmpty else { return nil }
            return .episode(id: id, seconds: seconds, english: english)
        default:
            return nil
        }
    }

    /// YouTube ids are 11 characters from `[A-Za-z0-9_-]`.
    static func isEpisodeId(_ s: String) -> Bool {
        s.count == 11 && s.allSatisfy { $0.isLetter || $0.isNumber || $0 == "_" || $0 == "-" }
    }

    /// Accepts `90`, `90s`, `1m30s`, `1h2m3s` and `HH:MM:SS`.
    static func parseSeconds(_ text: String) -> TimeInterval? {
        if text.contains(":") {
            let parts = text.split(separator: ":", omittingEmptySubsequences: false)
            guard parts.allSatisfy({ !$0.isEmpty && $0.allSatisfy(\.isNumber) }) else { return nil }
            return Timecode.seconds(text)
        }
        if let plain = TimeInterval(text) { return plain >= 0 ? plain : nil }
        var total: TimeInterval = 0
        var number = ""
        var matched = false
        for ch in text {
            if ch.isNumber {
                number.append(ch)
                continue
            }
            guard let n = TimeInterval(number) else { return nil }
            switch ch {
            case "h": total += n * 3600
            case "m": total += n * 60
            case "s": total += n
            default: return nil
            }
            number = ""
            matched = true
        }
        guard number.isEmpty, matched else { return nil }
        return total
    }

    /// Canonical shareable form of a link, always the custom scheme.
    var url: URL {
        switch self {
        case .channel(let id):
            return URL(string: "\(DeepLink.scheme)://channel/\(id)")!
        case .episode(let id, let seconds, let english):
            var components = URLComponents()
            components.scheme = DeepLink.scheme
            components.host = "episode"
            components.path = "/\(id)"
            var items: [URLQueryItem] = []
            if let seconds, seconds > 0 { items.append(URLQueryItem(name: "t", value: String(Int(seconds)))) }
            if english { items.append(URLQueryItem(name: "lang", value: "en")) }
            components.queryItems = items.isEmpty ? nil : items
            return components.url!
        }
    }
}
