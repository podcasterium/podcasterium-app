import SwiftUI

@main
struct PodcasteriumApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

/// Root navigation container. Every screen is reached through a value-based
/// `NavigationStack` so deep links can later push the same routes.
struct RootView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .navigationDestination(for: ChannelRoute.self) { route in
                    ChannelView(route: route)
                }
                .navigationDestination(for: EpisodeRoute.self) { route in
                    EpisodeView(route: route)
                }
        }
        .tint(BrandConfig.current.accent)
        .onAppear(perform: openLaunchRoute)
    }

    /// Debug entry points, also the seam where universal links will land:
    /// `-channel <id>` or `-episode <youtubeId>` as launch arguments.
    private func openLaunchRoute() {
        let args = ProcessInfo.processInfo.arguments
        if let i = args.firstIndex(of: "-episode"), i + 1 < args.count {
            path.append(EpisodeRoute(youtubeId: args[i + 1], title: "", channelName: "", thumbnailURL: nil))
        } else if let i = args.firstIndex(of: "-channel"), i + 1 < args.count {
            path.append(ChannelRoute(id: args[i + 1], name: args[i + 1]))
        }
    }
}

/// Navigation payload for a channel screen.
struct ChannelRoute: Hashable {
    let id: String
    let name: String
}

/// Navigation payload for an episode screen. Carries what the list already
/// knows so the screen can render a header before the CDN answers.
struct EpisodeRoute: Hashable {
    let youtubeId: String
    let title: String
    let channelName: String
    let thumbnailURL: URL?
}
