import SwiftUI

/// Everything that differs between white-label instances lives here.
/// The rest of the app must not mention a brand name, host or colour.
struct BrandConfig {
    let appName: String
    /// Origin of the static content contract (channel index, per-episode
    /// JSON, media). See `docs/00-source-app-analysis.md` section 1.
    let cdnBase: URL
    let accent: Color
    /// Label shown next to the per-episode domain score, if the corpus has one.
    let domainScoreLabel: String?

    static let current = BrandConfig(
        appName: "Podcasterium",
        cdnBase: URL(string: "https://cdn.domovina.ai")!,
        accent: Color(red: 0.33, green: 0.27, blue: 0.86),
        domainScoreLabel: nil
    )
}
