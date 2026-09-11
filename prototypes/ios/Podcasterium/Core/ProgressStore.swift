import Foundation

/// Local "resume where you left off" positions, keyed by episode id.
/// Device-only; the upstream product syncs this through Supabase, which
/// the prototype does not touch.
struct ProgressStore {
    static let key = "playback.positions"
    /// Positions inside the first seconds, or within this margin of the
    /// end, are not worth resuming and are dropped.
    static let leadIn: TimeInterval = 10
    static let tail: TimeInterval = 30

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func position(for id: String) -> TimeInterval? {
        (defaults.dictionary(forKey: Self.key) as? [String: Double])?[id]
    }

    /// Stores `seconds` for `id`, or clears it when the position is at the
    /// start or near the end (`duration` 0 means unknown, keep the tail rule off).
    func save(_ seconds: TimeInterval, duration: TimeInterval, for id: String) {
        var table = (defaults.dictionary(forKey: Self.key) as? [String: Double]) ?? [:]
        let finished = duration > 0 && seconds >= duration - Self.tail
        if seconds < Self.leadIn || finished {
            table.removeValue(forKey: id)
        } else {
            table[id] = seconds
        }
        defaults.set(table, forKey: Self.key)
    }

    func clear(_ id: String) {
        var table = (defaults.dictionary(forKey: Self.key) as? [String: Double]) ?? [:]
        table.removeValue(forKey: id)
        defaults.set(table, forKey: Self.key)
    }
}
