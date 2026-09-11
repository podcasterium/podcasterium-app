import XCTest

/// Drives the real app on the simulator against the live CDN. Needs network.
final class MiniPlayerUITests: XCTestCase {
    private let episodeId = "e4aPRlJ04fc"

    override func setUp() {
        continueAfterFailure = false
    }

    /// Open an episode from a timestamped deep link, leave the screen,
    /// expect the mini player, tap it, expect the episode again.
    func testPlaybackSurvivesLeavingTheEpisodeScreen() {
        let app = XCUIApplication()
        app.launchArguments = ["-url", "podcasterium://episode/\(episodeId)?t=754"]
        app.launch()

        let chaptersTab = app.buttons["Chapters"]
        XCTAssertTrue(chaptersTab.waitForExistence(timeout: 40), "episode screen did not load")

        app.navigationBars.buttons.element(boundBy: 0).tap()

        let miniPlayer = app.otherElements["Now playing"]
        XCTAssertTrue(miniPlayer.waitForExistence(timeout: 10), "mini player did not appear after leaving the episode")
        XCTAssertTrue(app.navigationBars["Podcasterium"].exists, "expected to be back on Home")
        attach(app, name: "home-with-mini-player")

        miniPlayer.tap()
        XCTAssertTrue(chaptersTab.waitForExistence(timeout: 10), "tapping the mini player did not reopen the episode")
        XCTAssertFalse(miniPlayer.exists, "mini player must hide while its episode is on screen")
        attach(app, name: "episode-reopened")
    }

    private func attach(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
