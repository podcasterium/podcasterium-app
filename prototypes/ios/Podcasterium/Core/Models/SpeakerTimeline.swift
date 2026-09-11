import Foundation

/// One cue of the diarized transcript (`diarized.srt`).
struct SpeakerSegment: Identifiable, Equatable {
    let index: Int
    let startMs: Int
    let endMs: Int
    /// "SPEAKER_00", "SPEAKER_01", ...
    let speakerId: String
    /// Cue text without the `[SPEAKER_XX]` prefix.
    let text: String

    var id: Int { index }
    var start: TimeInterval { TimeInterval(startMs) / 1000 }
}

struct SpeakerTimeline {
    let segments: [SpeakerSegment]

    /// Speaker at `seconds`. Sticky: gaps keep the previous speaker.
    func speaker(at seconds: TimeInterval) -> String? {
        let ms = Int(seconds * 1000)
        var last: String?
        for seg in segments {
            if seg.startMs > ms { break }
            last = seg.speakerId
        }
        return last
    }

    /// Cue active exactly at `seconds`, or nil in a gap. Binary search: the
    /// player ticks several times a second over ~2,000 cues.
    func cue(at seconds: TimeInterval) -> SpeakerSegment? {
        let ms = Int(seconds * 1000)
        var lo = 0, hi = segments.count - 1
        while lo <= hi {
            let mid = (lo + hi) / 2
            let seg = segments[mid]
            if ms < seg.startMs { hi = mid - 1 }
            else if ms >= seg.endMs { lo = mid + 1 }
            else { return seg }
        }
        return nil
    }

    /// Index of the last cue that started at or before `seconds`; used to
    /// highlight and follow the transcript even inside gaps.
    func index(at seconds: TimeInterval) -> Int? {
        let ms = Int(seconds * 1000)
        var lo = 0, hi = segments.count - 1, answer: Int?
        while lo <= hi {
            let mid = (lo + hi) / 2
            if segments[mid].startMs <= ms { answer = mid; lo = mid + 1 } else { hi = mid - 1 }
        }
        return answer
    }
}

/// Parser for the pipeline's diarized SRT: standard SRT blocks whose text
/// starts with `[SPEAKER_XX]`. Blocks without a speaker tag are skipped.
enum SRTParser {
    private static let timeRegex = try! NSRegularExpression(
        pattern: #"(\d{2}):(\d{2}):(\d{2})[,.](\d{3})\s*-->\s*(\d{2}):(\d{2}):(\d{2})[,.](\d{3})"#
    )
    private static let speakerRegex = try! NSRegularExpression(pattern: #"^\[(\w+)\]\s*"#)

    static func parse(_ raw: String) -> SpeakerTimeline {
        var segments: [SpeakerSegment] = []
        let normalized = raw.replacingOccurrences(of: "\r\n", with: "\n")
        let blocks = normalized.components(separatedBy: "\n\n")
        for block in blocks {
            let lines = block.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
            guard lines.count >= 3 else { continue }
            let timeLine = lines[1]
            guard let m = timeRegex.firstMatch(in: timeLine, range: NSRange(timeLine.startIndex..., in: timeLine)) else { continue }
            func group(_ i: Int) -> Int {
                Int(timeLine[Range(m.range(at: i), in: timeLine)!]) ?? 0
            }
            let startMs = group(1) * 3_600_000 + group(2) * 60_000 + group(3) * 1000 + group(4)
            let endMs = group(5) * 3_600_000 + group(6) * 60_000 + group(7) * 1000 + group(8)
            let text = lines[2...].joined(separator: " ").trimmingCharacters(in: .whitespaces)
            guard let sm = speakerRegex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
                  let idRange = Range(sm.range(at: 1), in: text),
                  let fullRange = Range(sm.range, in: text) else { continue }
            segments.append(SpeakerSegment(
                index: segments.count,
                startMs: startMs,
                endMs: endMs,
                speakerId: String(text[idRange]),
                text: String(text[fullRange.upperBound...]).trimmingCharacters(in: .whitespaces)
            ))
        }
        return SpeakerTimeline(segments: segments)
    }
}
