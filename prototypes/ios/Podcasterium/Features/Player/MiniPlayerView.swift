import SwiftUI

/// Persistent bar above the bottom safe area while an episode plays and
/// its screen is not visible. Tap to reopen the episode; long-press to stop.
struct MiniPlayerView: View {
    @EnvironmentObject private var session: PlaybackSession
    @ObservedObject var player: PlayerController
    let open: (EpisodeRoute) -> Void

    var body: some View {
        if let data = session.current, let route = session.route {
            VStack(spacing: 0) {
                ProgressView(value: min(player.currentTime, max(player.duration, 1)), total: max(player.duration, 1))
                    .progressViewStyle(.linear)
                    .tint(BrandConfig.current.accent)
                    .scaleEffect(x: 1, y: 0.5, anchor: .top)
                HStack(spacing: 12) {
                    CDNImage(candidates: CDN.thumbnailCandidates(data.youtubeId, targetPixels: 320), placeholderSymbol: data.isAudioOnly ? "waveform" : "play.rectangle")
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(route.title.isEmpty ? data.info.title : route.title)
                            .font(.subheadline.weight(.medium))
                            .lineLimit(1)
                        Text(data.info.channel.isEmpty ? route.channelName : data.info.channel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                    Button { player.toggle() } label: {
                        Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title3)
                            .frame(width: 32, height: 32)
                    }
                    .disabled(!player.isReady)
                    Button { player.skip(15) } label: {
                        Image(systemName: "goforward.15")
                            .font(.title3)
                            .frame(width: 32, height: 32)
                    }
                    .disabled(!player.isReady)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .background(.regularMaterial)
            .overlay(alignment: .top) { Divider() }
            .contentShape(Rectangle())
            .onTapGesture { open(route) }
            .contextMenu {
                Button("Open episode", systemImage: "arrow.up.right.square") { open(route) }
                Button("Stop", systemImage: "stop.fill", role: .destructive) { session.stop() }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Now playing")
        }
    }
}
