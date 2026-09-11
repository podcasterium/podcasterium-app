import Foundation

/// Lenient decoding helpers. The CDN contract is produced by several
/// pipeline generations, so fields go missing and integers sometimes arrive
/// as decimals (an X/Twitter source writes `duration_seconds: 245.295`).
extension KeyedDecodingContainer {
    func value<T: Decodable>(_ key: Key, default fallback: T) -> T {
        (try? decodeIfPresent(T.self, forKey: key)) ?? fallback
    }

    func optional<T: Decodable>(_ key: Key) -> T? {
        try? decodeIfPresent(T.self, forKey: key)
    }

    func int(_ key: Key) -> Int? {
        if let i = try? decodeIfPresent(Int.self, forKey: key) { return i }
        if let d = try? decodeIfPresent(Double.self, forKey: key) { return Int(d) }
        return nil
    }

    func strings(_ key: Key) -> [String] {
        (try? decodeIfPresent([String].self, forKey: key)) ?? []
    }

    func optionalStrings(_ key: Key) -> [String]? {
        try? decodeIfPresent([String].self, forKey: key)
    }
}

/// "HH:MM:SS" timecodes used by outline and article files.
enum Timecode {
    static func seconds(_ text: String) -> TimeInterval {
        let parts = text.split(separator: ":").compactMap { Double($0) }
        switch parts.count {
        case 3: return parts[0] * 3600 + parts[1] * 60 + parts[2]
        case 2: return parts[0] * 60 + parts[1]
        case 1: return parts[0]
        default: return 0
        }
    }

    /// "1:02:03" or "2:03" depending on length.
    static func display(_ seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds.rounded()))
        let h = total / 3600, m = (total % 3600) / 60, s = total % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%d:%02d", m, s)
    }

    /// "2h 08m" for listings.
    static func compact(_ seconds: Int) -> String {
        let h = seconds / 3600, m = (seconds % 3600) / 60
        return h > 0 ? "\(h)h \(String(format: "%02d", m))m" : "\(m)m"
    }
}

/// Canonical YouTube channel id: `UC` followed by 22 base64url characters.
enum ChannelId {
    private static let pattern = try! NSRegularExpression(pattern: #"UC[0-9A-Za-z_-]{22}"#)

    static func canonical(explicit: String?, url: String?) -> String? {
        if let explicit, explicit.count == 24, explicit.hasPrefix("UC"),
           pattern.firstMatch(in: explicit, range: NSRange(explicit.startIndex..., in: explicit)) != nil {
            return explicit
        }
        if let url, let range = url.range(of: #"/channel/(UC[0-9A-Za-z_-]{22})"#, options: .regularExpression) {
            return String(url[range].dropFirst("/channel/".count))
        }
        return nil
    }
}

enum DateText {
    private static let isoDay: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    private static let compactDay: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyyMMdd"
        return f
    }()

    /// Accepts "2026-02-14" and "20260214".
    static func parse(_ text: String?) -> Date? {
        guard let text else { return nil }
        return isoDay.date(from: text) ?? compactDay.date(from: text)
    }

    static func medium(_ text: String?) -> String {
        guard let date = parse(text) else { return text ?? "" }
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}
