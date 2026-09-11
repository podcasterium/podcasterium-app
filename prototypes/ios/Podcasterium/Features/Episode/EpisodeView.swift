import AVKit
import SwiftUI

@MainActor
final class EpisodeModel: ObservableObject {
    @Published var state: LoadState<EpisodeData> = .idle
    @Published var english: Bool
    @Published var tab: Tab = .article

    enum Tab: String, CaseIterable, Identifiable {
        case article = "Article"
        case chapters = "Chapters"
        case summary = "Summary"
        case transcript = "Transcript"
        var id: String { rawValue }
    }

    let youtubeId: String

    init(youtubeId: String, english: Bool = false) {
        self.youtubeId = youtubeId
        self.english = english
    }

    /// Loads the episode and hands its media to the shared session. If the
    /// session already plays this episode the data is reused and playback
    /// continues untouched.
    func load(route: EpisodeRoute, session: PlaybackSession) async {
        if case .loaded = state { return }
        if let data = session.data(for: youtubeId) {
            state = .loaded(data)
            pickDefaultTab(data)
            session.prepare(data, route: route, english: english)
            return
        }
        state = .loading
        do {
            let data = try await EpisodeData.load(youtubeId: youtubeId)
            state = .loaded(data)
            pickDefaultTab(data)
            session.prepare(data, route: route, english: english)
        } catch {
            state = .failed(error)
        }
    }

    func reload(route: EpisodeRoute, session: PlaybackSession) async {
        state = .idle
        await load(route: route, session: session)
    }

    private func pickDefaultTab(_ data: EpisodeData) {
        if !data.hasArticle { tab = data.chapters.isEmpty ? .summary : .chapters }
    }
}

struct EpisodeView: View {
    let route: EpisodeRoute
    @StateObject private var model: EpisodeModel
    @EnvironmentObject private var session: PlaybackSession

    init(route: EpisodeRoute) {
        self.route = route
        _model = StateObject(wrappedValue: EpisodeModel(youtubeId: route.youtubeId, english: route.english))
    }

    var body: some View {
        LoadStateView(state: model.state, retry: { Task { await model.reload(route: route, session: session) } }) { data in
            VStack(spacing: 0) {
                MediaSurface(data: data, player: session.player)
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        header(data)
                        Picker("Section", selection: $model.tab) {
                            ForEach(EpisodeModel.Tab.allCases) { Text($0.rawValue).tag($0) }
                        }
                        .pickerStyle(.segmented)
                        switch model.tab {
                        case .article:
                            ArticleTab(data: data, english: model.english, player: session.player)
                        case .chapters:
                            ChaptersTab(data: data, player: session.player)
                        case .summary:
                            SummaryTab(data: data, english: model.english)
                        case .transcript:
                            TranscriptTab(data: data, player: session.player)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
            .toolbar {
                if data.hasEnglish {
                    ToolbarItem(placement: .topBarTrailing) {
                        Picker("Language", selection: $model.english) {
                            Text("Source").tag(false)
                            Text("EN").tag(true)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 130)
                    }
                }
                if let url = data.info.sourceURL {
                    ToolbarItem(placement: .topBarTrailing) {
                        ShareLink(item: url) { Image(systemName: "square.and.arrow.up") }
                    }
                }
            }
        }
        .navigationTitle(route.channelName.isEmpty ? (model.state.value?.info.channel ?? "") : route.channelName)
        .navigationBarTitleDisplayMode(.inline)
        .task { await model.load(route: route, session: session) }
        .onAppear { session.visibleEpisodeId = route.youtubeId }
        .onDisappear {
            if session.visibleEpisodeId == route.youtubeId { session.visibleEpisodeId = nil }
        }
    }

    private func header(_ data: EpisodeData) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(data.displayTitle(english: model.english))
                .font(.title3.weight(.semibold))
            HStack(spacing: 6) {
                Text(data.info.channel.isEmpty ? route.channelName : data.info.channel)
                Text("·")
                Text(DateText.medium(data.info.uploadDate))
                if data.info.duration > 0 {
                    Text("·")
                    Text(Timecode.display(TimeInterval(data.info.duration)))
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            if let speakers = data.summary(english: model.english)?.summary.speakers, !speakers.isEmpty {
                ChipRow(items: speakers.map { s in
                    let role = s.roleLabel(english: model.english)
                    return s.displayName.map { "\($0) · \(role)" } ?? role
                }, tint: BrandConfig.current.accent)
            }
            if !data.hasArticle {
                Label("The AI article for this episode is not ready yet.", systemImage: "hourglass")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 12)
    }
}

/// Video player, audio cover art with transport, or a "no media" notice.
private struct MediaSurface: View {
    let data: EpisodeData
    @ObservedObject var player: PlayerController

    var body: some View {
        switch data.mediaKind {
        case .video:
            VideoPlayer(player: player.player) {
                // Poster until playback starts; a paused AVPlayer at 0:00 renders black.
                if !player.isPlaying && player.currentTime == 0 {
                    CDNImage(candidates: CDN.thumbnailCandidates(data.youtubeId, targetPixels: 1280), hideOnFailure: true)
                        .allowsHitTesting(false)
                }
            }
            .aspectRatio(16 / 9, contentMode: .fit)
            .background(Color.black)
        case .audio:
            AudioSurface(data: data, player: player)
        case .none:
            ContentUnavailableView(
                "No media on the CDN yet",
                systemImage: "play.slash",
                description: Text("Text content still works once the pipeline has produced it.")
            )
            .frame(height: 180)
        }
    }
}

private struct AudioSurface: View {
    let data: EpisodeData
    @ObservedObject var player: PlayerController
    @State private var scrubbing = false
    @State private var scrubValue: Double = 0

    var body: some View {
        VStack(spacing: 10) {
            CDNImage(candidates: CDN.thumbnailCandidates(data.youtubeId, targetPixels: 1280), placeholderSymbol: "waveform")
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            Slider(
                value: Binding(
                    get: { scrubbing ? scrubValue : player.currentTime },
                    set: { scrubValue = $0 }
                ),
                in: 0...max(player.duration, 1),
                onEditingChanged: { editing in
                    scrubbing = editing
                    if !editing { player.seek(to: scrubValue) }
                }
            )
            HStack {
                Text(Timecode.display(player.currentTime)).monospacedDigit()
                Spacer()
                Text(Timecode.display(player.duration)).monospacedDigit()
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            HStack(spacing: 36) {
                Button { player.skip(-15) } label: { Image(systemName: "gobackward.15") }
                Button { player.toggle() } label: {
                    Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 52))
                }
                Button { player.skip(15) } label: { Image(systemName: "goforward.15") }
            }
            .font(.title2)
            .disabled(!player.isReady)
        }
        .padding()
    }
}
