import SwiftUI

@MainActor
final class ChannelModel: ObservableObject {
    @Published var state: LoadState<ChannelDetail> = .idle
    let channelId: String

    init(channelId: String) { self.channelId = channelId }

    func load() async {
        if case .loaded = state { return }
        state = .loading
        do {
            guard let detail = try await CDNClient.shared.fetch(ChannelDetail.self, from: CDN.channel(channelId)) else {
                throw CDNError.http(404, CDN.channel(channelId))
            }
            state = .loaded(detail)
        } catch {
            state = .failed(error)
        }
    }

    func reload() async {
        state = .idle
        await load()
    }
}

struct ChannelView: View {
    let route: ChannelRoute
    @StateObject private var model: ChannelModel

    init(route: ChannelRoute) {
        self.route = route
        _model = StateObject(wrappedValue: ChannelModel(channelId: route.id))
    }

    var body: some View {
        LoadStateView(state: model.state, retry: { Task { await model.reload() } }) { detail in
            List {
                Section {
                    ChannelHeader(detail: detail)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
                Section("Episodes") {
                    ForEach(sortedVideos(detail)) { video in
                        NavigationLink(value: EpisodeRoute(
                            youtubeId: video.id,
                            title: video.displayTitle,
                            channelName: detail.name,
                            thumbnailURL: video.thumbnail.flatMap(URL.init(string:))
                        )) {
                            EpisodeRow(video: video, audioSource: detail.isAudioSource)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .refreshable { await model.reload() }
        }
        .navigationTitle(route.name)
        .navigationBarTitleDisplayMode(.inline)
        .task { await model.load() }
    }

    private func sortedVideos(_ detail: ChannelDetail) -> [ChannelVideo] {
        detail.videos.sorted { ($0.date ?? "") > ($1.date ?? "") }
    }
}

private struct ChannelHeader: View {
    let detail: ChannelDetail
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                CDNImage(CDN.channelAvatar(detail.id), placeholderSymbol: "person.crop.square")
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                VStack(alignment: .leading, spacing: 4) {
                    Text(detail.name).font(.title3.weight(.semibold))
                    Text("\(detail.videoCount) episodes · \(Timecode.compact(detail.totalDurationSeconds))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if let followers = detail.followerCount {
                        Text("\(followers.formatted()) followers")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            if let description = detail.description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .lineLimit(expanded ? nil : 3)
                    .onTapGesture { withAnimation { expanded.toggle() } }
            }
            if !detail.tags.isEmpty {
                ChipRow(items: Array(detail.tags.prefix(8)))
            }
        }
    }
}

private struct EpisodeRow: View {
    let video: ChannelVideo
    let audioSource: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            CDNImage(candidates: video.thumbnailCandidates, placeholderSymbol: audioSource ? "waveform" : "play.rectangle")
                .frame(width: 112, height: 63)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 4) {
                Text(video.displayTitle)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(2)
                HStack(spacing: 6) {
                    Text(DateText.medium(video.date))
                    if !video.durationText.isEmpty {
                        Text("·")
                        Text(video.durationText)
                    }
                    if video.pipeline?.hasArticle == true {
                        Text("·")
                        Label("Article", systemImage: "doc.text").labelStyle(.iconOnly)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                if let abstract = video.abstract, !abstract.isEmpty {
                    Text(abstract)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
