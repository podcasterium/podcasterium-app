import Combine
import Foundation

/// App-wide playback state: one `PlayerController` for the whole app, the
/// episode it is playing, and the resume positions. Lives in `RootView` so
/// playback survives leaving the episode screen (mini player) and so the
/// lock-screen commands are registered exactly once.
@MainActor
final class PlaybackSession: ObservableObject {
    let player = PlayerController()

    /// Episode currently loaded in the player, with the route that opens it.
    @Published private(set) var current: EpisodeData?
    @Published private(set) var route: EpisodeRoute?
    /// Set by `EpisodeView` while it is on screen; the mini player hides
    /// itself when the full screen for the same episode is visible.
    @Published var visibleEpisodeId: String?

    private let progress: ProgressStore
    private var lastSaved: TimeInterval = 0
    private var cancellables = Set<AnyCancellable>()

    init(progress: ProgressStore = ProgressStore()) {
        self.progress = progress
        player.$currentTime
            .sink { [weak self] time in self?.record(time) }
            .store(in: &cancellables)
        player.$isPlaying
            .dropFirst()
            .filter { !$0 }
            .sink { [weak self] _ in self?.flush() }
            .store(in: &cancellables)
    }

    var showsMiniPlayer: Bool {
        guard let current else { return false }
        return current.hasMedia && current.youtubeId != visibleEpisodeId
    }

    /// Already-loaded data for `id`, so reopening the playing episode is instant.
    func data(for id: String) -> EpisodeData? {
        current?.youtubeId == id ? current : nil
    }

    func resumePosition(for id: String) -> TimeInterval? {
        progress.position(for: id)
    }

    /// Makes `data` the current episode. A second call for the same episode
    /// keeps playback and only honours a new start position.
    func prepare(_ data: EpisodeData, route: EpisodeRoute, english: Bool) {
        if current?.youtubeId == data.youtubeId {
            if let seconds = route.startSeconds { player.seek(to: seconds, andPlay: true) }
            return
        }
        flush()
        current = data
        self.route = route
        lastSaved = 0
        guard let url = data.mediaURL else {
            player.unload()
            return
        }
        let resume = progress.position(for: data.youtubeId)
        player.load(
            url: url,
            title: data.displayTitle(english: english),
            artist: data.info.channel.isEmpty ? route.channelName : data.info.channel,
            artworkCandidates: CDN.thumbnailCandidates(data.youtubeId, targetPixels: 640),
            startAt: route.startSeconds ?? resume,
            autoplay: route.startSeconds != nil
        )
    }

    func stop() {
        flush()
        player.unload()
        current = nil
        route = nil
    }

    // MARK: - Progress

    /// Persist every 5 s of playback; `flush` handles pause and switches.
    private func record(_ time: TimeInterval) {
        guard player.isPlaying, abs(time - lastSaved) >= 5 else { return }
        save(time)
    }

    private func flush() {
        guard player.isReady else { return }
        save(player.currentTime)
    }

    private func save(_ time: TimeInterval) {
        guard let current else { return }
        lastSaved = time
        progress.save(time, duration: player.duration, for: current.youtubeId)
    }
}
