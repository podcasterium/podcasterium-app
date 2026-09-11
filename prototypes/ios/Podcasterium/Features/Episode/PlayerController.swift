import AVFoundation
import Combine
import MediaPlayer
import UIKit

/// Owns the `AVPlayer`, publishes playback state, and wires the audio
/// session, lock-screen info and remote commands so audio keeps playing in
/// the background (see `UIBackgroundModes` in the project spec).
@MainActor
final class PlayerController: ObservableObject {
    let player = AVPlayer()

    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var isPlaying = false
    @Published private(set) var isReady = false

    private var timeObserver: Any?
    private var statusObservation: NSKeyValueObservation?
    private var rateObservation: NSKeyValueObservation?
    private var nowPlaying: [String: Any] = [:]
    private var commandTargets: [(MPRemoteCommand, Any)] = []

    init() {
        player.automaticallyWaitsToMinimizeStalling = true
        player.allowsExternalPlayback = true
        registerRemoteCommands()
    }

    deinit {
        if let timeObserver { player.removeTimeObserver(timeObserver) }
        for (command, target) in commandTargets { command.removeTarget(target) }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    /// Loads `url` and, once the item is ready, seeks to `startAt` (resume
    /// position or deep-link timestamp) and starts playback if `autoplay`.
    func load(url: URL, title: String, artist: String, artworkCandidates: [URL],
              startAt: TimeInterval? = nil, autoplay: Bool = false) {
        configureAudioSession()
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        isReady = false
        currentTime = 0
        duration = 0

        statusObservation = item.observe(\.status, options: [.new]) { [weak self] item, _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if item.status == .readyToPlay, !self.isReady {
                    self.isReady = true
                    let seconds = item.duration.seconds
                    self.duration = seconds.isFinite ? seconds : 0
                    if let startAt, startAt > 0 { self.seek(to: startAt) }
                    if autoplay { self.play() }
                    self.updateNowPlaying()
                }
            }
        }
        rateObservation = player.observe(\.rate, options: [.new]) { [weak self] player, _ in
            Task { @MainActor [weak self] in
                self?.isPlaying = player.rate > 0
                self?.updateNowPlaying()
            }
        }
        if let timeObserver { player.removeTimeObserver(timeObserver) }
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.25, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            MainActor.assumeIsolated {
                self?.currentTime = time.seconds.isFinite ? time.seconds : 0
            }
        }

        nowPlaying = [
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyArtist: artist,
            MPNowPlayingInfoPropertyMediaType: MPNowPlayingInfoMediaType.audio.rawValue,
        ]
        updateNowPlaying()
        Task { [weak self] in
            guard let image = await ImageStore.shared.image(for: artworkCandidates) else { return }
            await MainActor.run {
                self?.nowPlaying[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                self?.updateNowPlaying()
            }
        }
    }

    /// Drops the current item and clears the lock-screen entry.
    func unload() {
        player.pause()
        player.replaceCurrentItem(with: nil)
        statusObservation = nil
        isReady = false
        isPlaying = false
        currentTime = 0
        duration = 0
        nowPlaying = [:]
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    func play() {
        configureAudioSession()
        player.play()
    }

    func pause() { player.pause() }

    func toggle() { isPlaying ? pause() : play() }

    func seek(to seconds: TimeInterval, andPlay: Bool = false) {
        let clamped = max(0, min(seconds, duration > 0 ? duration : seconds))
        player.seek(to: CMTime(seconds: clamped, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero)
        currentTime = clamped
        if andPlay, !isPlaying { play() }
        updateNowPlaying()
    }

    func skip(_ delta: TimeInterval) { seek(to: currentTime + delta) }

    // MARK: - System integration

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .moviePlayback, policy: .longFormAudio)
        try? session.setActive(true)
    }

    private func updateNowPlaying() {
        var info = nowPlaying
        info[MPMediaItemPropertyPlaybackDuration] = duration
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        info[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func registerRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()
        func bind(_ command: MPRemoteCommand, _ action: @escaping @MainActor (MPRemoteCommandEvent) -> Void) {
            command.isEnabled = true
            let target = command.addTarget { event in
                Task { @MainActor in action(event) }
                return .success
            }
            commandTargets.append((command, target))
        }
        bind(center.playCommand) { [weak self] _ in self?.play() }
        bind(center.pauseCommand) { [weak self] _ in self?.pause() }
        bind(center.togglePlayPauseCommand) { [weak self] _ in self?.toggle() }
        center.skipForwardCommand.preferredIntervals = [15]
        center.skipBackwardCommand.preferredIntervals = [15]
        bind(center.skipForwardCommand) { [weak self] _ in self?.skip(15) }
        bind(center.skipBackwardCommand) { [weak self] _ in self?.skip(-15) }
        bind(center.changePlaybackPositionCommand) { [weak self] event in
            if let e = event as? MPChangePlaybackPositionCommandEvent { self?.seek(to: e.positionTime) }
        }
    }
}
