import XCTest
@testable import Podcasterium

final class DeepLinkTests: XCTestCase {
    private func parse(_ s: String) -> DeepLink? {
        DeepLink.parse(URL(string: s)!)
    }

    func testCustomScheme() {
        XCTAssertEqual(parse("podcasterium://episode/e4aPRlJ04fc"), .episode(id: "e4aPRlJ04fc", seconds: nil, english: false))
        XCTAssertEqual(parse("podcasterium://episode/e4aPRlJ04fc?t=95&lang=en"), .episode(id: "e4aPRlJ04fc", seconds: 95, english: true))
        XCTAssertEqual(parse("podcasterium://channel/abbacast"), .channel(id: "abbacast"))
        XCTAssertNil(parse("podcasterium://settings"))
    }

    func testUpstreamWebRoutes() {
        let id = "e4aPRlJ04fc"
        XCTAssertEqual(parse("https://example.com/v/\(id)"), .episode(id: id, seconds: nil, english: false))
        XCTAssertEqual(parse("https://example.com/v/\(id)/en"), .episode(id: id, seconds: nil, english: true))
        XCTAssertEqual(parse("https://example.com/v/\(id)/read"), .episode(id: id, seconds: nil, english: false))
        XCTAssertEqual(parse("https://example.com/episode/\(id)"), .episode(id: id, seconds: nil, english: false))
        XCTAssertEqual(parse("https://example.com/m/\(id)/t/754"), .episode(id: id, seconds: 754, english: false))
        XCTAssertEqual(parse("https://example.com/m/\(id)/t/754/en"), .episode(id: id, seconds: 754, english: true))
        XCTAssertEqual(parse("https://example.com/c/abbacast"), .channel(id: "abbacast"))
        XCTAssertNil(parse("https://example.com/v/short"))
        XCTAssertNil(parse("https://example.com/v/\(id)/unknown"))
        XCTAssertNil(parse("https://example.com/privacy"))
    }

    func testYouTubeLinks() {
        let id = "e4aPRlJ04fc"
        XCTAssertEqual(parse("https://www.youtube.com/watch?v=\(id)&t=1m30s"), .episode(id: id, seconds: 90, english: false))
        XCTAssertEqual(parse("https://youtu.be/\(id)?t=42"), .episode(id: id, seconds: 42, english: false))
        XCTAssertEqual(parse("https://youtube.com/shorts/\(id)"), .episode(id: id, seconds: nil, english: false))
        XCTAssertNil(parse("https://www.youtube.com/@channel"))
    }

    func testSecondsFormats() {
        XCTAssertEqual(DeepLink.parseSeconds("90"), 90)
        XCTAssertEqual(DeepLink.parseSeconds("90s"), 90)
        XCTAssertEqual(DeepLink.parseSeconds("1m30s"), 90)
        XCTAssertEqual(DeepLink.parseSeconds("1h2m3s"), 3723)
        XCTAssertEqual(DeepLink.parseSeconds("01:02:03"), 3723)
        XCTAssertEqual(DeepLink.parseSeconds("2:03"), 123)
        XCTAssertNil(DeepLink.parseSeconds("abc"))
        XCTAssertNil(DeepLink.parseSeconds("1x"))
        XCTAssertNil(DeepLink.parseSeconds("-5"))
    }

    func testCanonicalURLRoundTrip() {
        let links: [DeepLink] = [
            .channel(id: "abbacast"),
            .episode(id: "e4aPRlJ04fc", seconds: nil, english: false),
            .episode(id: "e4aPRlJ04fc", seconds: 754, english: true),
        ]
        for link in links {
            XCTAssertEqual(DeepLink.parse(link.url), link, "\(link.url)")
        }
    }
}
