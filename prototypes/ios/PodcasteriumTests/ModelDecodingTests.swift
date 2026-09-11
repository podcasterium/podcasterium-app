import XCTest
@testable import Podcasterium

final class ModelDecodingTests: XCTestCase {
    private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
        try JSONDecoder().decode(T.self, from: Data(json.utf8))
    }

    func testChannelIndexDerivesCanonicalChannelId() throws {
        let json = """
        {"version":"1.0","channel_count":1,"channels":[{
          "id":"sample","name":"Sample","avatar_cover":"https://cdn.example/cover.jpg","avatar_cover_dimensions":{"width":1060,"height":175},
          "youtube_channel_url":"https://www.youtube.com/channel/UChgVPEqmTeG0na3u8VfY3PQ",
          "video_count":77,"total_duration_seconds":267355,"avg_magisterium_score":95,
          "latest_video":{"id":"4cpxioHdQDs","date":"2026-09-08","title":"Latest"}}]}
        """
        let index = try decode(ChannelIndex.self, json)
        XCTAssertEqual(index.channelCount, 1)
        let channel = try XCTUnwrap(index.channels.first)
        XCTAssertEqual(channel.youtubeChannelId, "UChgVPEqmTeG0na3u8VfY3PQ")
        XCTAssertTrue(channel.hasBannerCover)
        XCTAssertEqual(channel.avgDomainScore, 95)
        XCTAssertEqual(channel.latestVideo?.id, "4cpxioHdQDs")
    }

    func testChannelVideoAcceptsBothSpeakerShapesAndDecimalDurations() throws {
        let json = """
        {"id":"c","name":"C","youtube_channel_url":"https://launchedfm.com/show","videos":[
          {"id":"abc","title":"Raw","title_hr":"Cleaned","duration_seconds":245.295,
           "speakers":["Ann",{"id":"SPEAKER_00","suggested_name":"Bob","role":"host"}]},
          {"id":"def","title":"Only title"}
        ]}
        """
        let detail = try decode(ChannelDetail.self, json)
        XCTAssertTrue(detail.isAudioSource)
        XCTAssertEqual(detail.videos[0].displayTitle, "Cleaned")
        XCTAssertEqual(detail.videos[0].durationSeconds, 245)
        XCTAssertEqual(detail.videos[0].speakers, ["Ann", "Bob"])
        XCTAssertEqual(detail.videos[1].displayTitle, "Only title")
        XCTAssertNil(detail.videos[1].durationSeconds)
    }

    func testPodcastInfoFallsBackToUploaderAndDetectsNonYouTubeSources() throws {
        let x = try decode(PodcastInfo.self, """
        {"id":"synthetic123","title":"Post","uploader":"Someone","duration":245.3,
         "webpage_url":"https://x.com/someone/status/1","_source":"x","extractor":"twitter"}
        """)
        XCTAssertEqual(x.channel, "Someone")
        XCTAssertEqual(x.duration, 245)
        XCTAssertTrue(x.isX)
        XCTAssertEqual(x.sourceURL?.absoluteString, "https://x.com/someone/status/1")

        let yt = try decode(PodcastInfo.self, """
        {"id":"e4aPRlJ04fc","title":"Episode","channel":"Show","upload_date":"20260214",
         "chapters":[{"start_time":0,"title":"Intro","end_time":19}]}
        """)
        XCTAssertEqual(yt.sourceURL?.absoluteString, "https://www.youtube.com/watch?v=e4aPRlJ04fc")
        XCTAssertEqual(yt.chapters.first?.title, "Intro")
        XCTAssertNotNil(yt.uploadDateValue)
    }

    func testSummaryLanguageOverlayFallsBackToSource() throws {
        let summary = try decode(PodcastSummary.self, """
        {"summary":{"title_hr":"Source title","abstract_hr":"Source abstract","abstract_en":"English abstract",
          "speakers":[{"id":"SPEAKER_00","suggested_name":"host","role":"host"},
                      {"id":"SPEAKER_01","suggested_name":"Jane Doe","role":"guest","role_en":"guest"}]}}
        """)
        let content = summary.summary
        XCTAssertEqual(content.title(english: true), "Source title", "missing title_en falls back")
        XCTAssertEqual(content.abstract(english: true), "English abstract")
        XCTAssertNil(content.speakers[0].displayName, "name equal to role is not a name")
        XCTAssertEqual(content.speakerNames["SPEAKER_00"], "Host")
        XCTAssertEqual(content.speakerNames["SPEAKER_01"], "Jane Doe")
    }

    func testArticleAndOutlineTimecodes() throws {
        let article = try decode(PodcastArticle.self, """
        {"metadata":{"model":"m"},"iterations":[{"iteration_number":1,"start_time":"00:00:00","end_time":"00:41:19",
          "theme":"Theme","sections":[{"subtitle":"S","screenshot_timestamp":"00:03:55","content":"**Bold** text","keywords":["k"]}]}]}
        """)
        XCTAssertEqual(article.sectionCount, 1)
        XCTAssertEqual(article.iterations[0].sections[0].seconds, 235)
        XCTAssertEqual(article.iterations[0].sections[0].content(english: true), "**Bold** text")

        let outline = try decode(PodcastOutline.self, """
        {"iterations":[{"iteration_number":1,"theme":"T","chapters":[{"timestamp":"00:00:58","topic":"Guests"}]}]}
        """)
        XCTAssertEqual(outline.allChapters.first?.seconds, 58)
    }

    func testCDNUrlBuilders() {
        XCTAssertEqual(CDN.screenshot("abc", timestamp: "00:03:55").path, "/images/abc/screenshots/00-03-55.png")
        XCTAssertEqual(CDN.thumbnailCandidates("abc", targetPixels: 500).map(\.lastPathComponent), ["thumb-640.webp", "thumbnail.png"])
        XCTAssertEqual(CDN.thumbnailCandidates("abc", targetPixels: 5000).first?.lastPathComponent, "thumb-1280.webp")
        XCTAssertEqual(CDN.episodeId(fromThumbnail: "https://cdn.example/images/e4aPRlJ04fc/thumbnail.png"), "e4aPRlJ04fc")
        XCTAssertTrue(CDN.channelsIndex.query?.hasPrefix("v=") == true)
        XCTAssertNil(CDN.info("abc").query, "per-episode JSON is immutable and takes no cache buster")
    }
}
