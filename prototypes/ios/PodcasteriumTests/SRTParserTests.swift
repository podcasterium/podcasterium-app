import XCTest
@testable import Podcasterium

final class SRTParserTests: XCTestCase {
    private let sample = """
    1
    00:00:19,600 --> 00:00:21,280
    [SPEAKER_02] Okay, are you ready?

    2
    00:00:22,239 --> 00:00:23,920
    [SPEAKER_02] Yes, we can start.

    3
    00:00:24,559 --> 00:00:27,039
    [SPEAKER_00] Thank you for having us,
    dear viewers.

    4
    00:00:28,000 --> 00:00:29,000
    No speaker tag here, skipped.
    """

    func testParsesSpeakerTaggedBlocksOnly() {
        let timeline = SRTParser.parse(sample)
        XCTAssertEqual(timeline.segments.count, 3)
        XCTAssertEqual(timeline.segments[0].speakerId, "SPEAKER_02")
        XCTAssertEqual(timeline.segments[0].startMs, 19_600)
        XCTAssertEqual(timeline.segments[0].endMs, 21_280)
        XCTAssertEqual(timeline.segments[0].text, "Okay, are you ready?")
        XCTAssertEqual(timeline.segments[2].text, "Thank you for having us, dear viewers.")
    }

    func testCueLookupIsExactAndSpeakerLookupIsSticky() {
        let timeline = SRTParser.parse(sample)
        XCTAssertEqual(timeline.cue(at: 20.0)?.index, 0)
        XCTAssertNil(timeline.cue(at: 21.5), "gap between cues has no active cue")
        XCTAssertEqual(timeline.speaker(at: 21.5), "SPEAKER_02", "speaker stays sticky through gaps")
        XCTAssertEqual(timeline.speaker(at: 25.0), "SPEAKER_00")
        XCTAssertNil(timeline.speaker(at: 1.0))
        XCTAssertEqual(timeline.index(at: 27.5), 2)
    }

    func testTimecodeRoundTrip() {
        XCTAssertEqual(Timecode.seconds("01:02:03"), 3723)
        XCTAssertEqual(Timecode.seconds("02:03"), 123)
        XCTAssertEqual(Timecode.display(3723), "1:02:03")
        XCTAssertEqual(Timecode.display(65), "1:05")
        XCTAssertEqual(Timecode.compact(267_355), "74h 15m")
    }
}
