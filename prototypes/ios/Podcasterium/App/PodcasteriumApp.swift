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
/// `NavigationStack`, so deep links push the same routes the lists do. Owns
/// the app-wide `PlaybackSession` and shows the mini player above the
/// bottom safe area while an episode plays off-screen.
struct RootView: View {
    @State private var path = NavigationPath()
    @StateObject private var session = PlaybackSession()

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
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if session.showsMiniPlayer {
                MiniPlayerView(player: session.player) { route in path.append(route) }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.snappy, value: session.showsMiniPlayer)
        .environmentObject(session)
        .tint(BrandConfig.current.accent)
        .onOpenURL { url in
            if let link = DeepLink.parse(url) { open(link) }
        }
        .onAppear(perform: openLaunchRoute)
    }

    /// Pushes the screen for `link`. A timestamp for the episode already on
    /// screen just seeks instead of pushing a second copy.
    private func open(_ link: DeepLink) {
        switch link {
        case .channel(let id):
            path.append(ChannelRoute(id: id, name: id))
        case .episode(let id, let seconds, let english):
            if session.visibleEpisodeId == id, let seconds {
                session.player.seek(to: seconds, andPlay: true)
                return
            }
            path.append(EpisodeRoute(youtubeId: id, title: "", channelName: "", thumbnailURL: nil,
                                     startSeconds: seconds, english: english))
        }
    }

    /// Debug entry points for the simulator: `-url <any accepted URL>`
    /// (repeatable; each one is pushed in order, so a second URL lands on
    /// top of the first), `-channel <id>` or `-episode <youtubeId>`.
    /// `xcrun simctl openurl booted podcasterium://...` exercises the real
    /// `onOpenURL` path but needs a tap on the system confirmation.
    private func openLaunchRoute() {
        let args = ProcessInfo.processInfo.arguments
        let urls = args.indices
            .filter { args[$0] == "-url" && $0 + 1 < args.count }
            .compactMap { URL(string: args[$0 + 1]) }
        if !urls.isEmpty {
            urls.compactMap(DeepLink.parse).forEach(open)
        } else if let i = args.firstIndex(of: "-episode"), i + 1 < args.count {
            open(.episode(id: args[i + 1], seconds: nil, english: false))
        } else if let i = args.firstIndex(of: "-channel"), i + 1 < args.count {
            open(.channel(id: args[i + 1]))
        }
    }
}

/// Navigation payload for a channel screen.
struct ChannelRoute: Hashable {
    let id: String
    let name: String
}

/// Navigation payload for an episode screen. Carries what the list already
/// knows so the screen can render a header before the CDN answers, plus the
/// optional start position and language a deep link asked for.
struct EpisodeRoute: Hashable {
    let youtubeId: String
    let title: String
    let channelName: String
    let thumbnailURL: URL?
    var startSeconds: TimeInterval? = nil
    var english: Bool = false
}
