import SwiftUI

@MainActor
final class HomeModel: ObservableObject {
    @Published var state: LoadState<ChannelIndex> = .idle
    @Published var query = ""

    func load() async {
        if case .loaded = state { return }
        state = .loading
        do {
            guard let index = try await CDNClient.shared.fetch(ChannelIndex.self, from: CDN.channelsIndex) else {
                throw CDNError.http(404, CDN.channelsIndex)
            }
            state = .loaded(index)
        } catch {
            state = .failed(error)
        }
    }

    func reload() async {
        state = .idle
        await load()
    }

    /// Channels sorted by most recent episode, filtered by the search field.
    func channels(_ index: ChannelIndex) -> [ChannelSummary] {
        let sorted = index.channels.sorted { ($0.latestVideo?.date ?? "") > ($1.latestVideo?.date ?? "") }
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return sorted }
        return sorted.filter { $0.name.localizedCaseInsensitiveContains(q) }
    }

    /// Newest episode per channel, newest first.
    func latest(_ index: ChannelIndex) -> [(channel: ChannelSummary, video: LatestVideo)] {
        index.channels
            .compactMap { c in c.latestVideo.map { (channel: c, video: $0) } }
            .sorted { $0.video.date > $1.video.date }
            .prefix(12)
            .map { $0 }
    }
}

struct HomeView: View {
    @StateObject private var model = HomeModel()

    var body: some View {
        LoadStateView(state: model.state, retry: { Task { await model.reload() } }) { index in
            List {
                if model.query.isEmpty {
                    Section("Latest episodes") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(alignment: .top, spacing: 12) {
                                ForEach(model.latest(index), id: \.video.id) { item in
                                    NavigationLink(value: EpisodeRoute(
                                        youtubeId: item.video.id,
                                        title: item.video.title,
                                        channelName: item.channel.name,
                                        thumbnailURL: CDN.thumbnail(item.video.id)
                                    )) {
                                        LatestCard(channel: item.channel, video: item.video)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }
                Section("Channels") {
                    ForEach(model.channels(index)) { channel in
                        NavigationLink(value: ChannelRoute(id: channel.id, name: channel.name)) {
                            ChannelRow(channel: channel)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .refreshable { await model.reload() }
        }
        .navigationTitle(BrandConfig.current.appName)
        .searchable(text: $model.query, prompt: "Search channels")
        .task { await model.load() }
    }
}

private struct LatestCard: View {
    let channel: ChannelSummary
    let video: LatestVideo

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Unprocessed episodes have no thumbnail yet; fall back to the channel avatar.
            CDNImage(candidates: CDN.thumbnailCandidates(video.id, targetPixels: 640) + [channel.avatarURL], placeholderSymbol: "play.rectangle")
                .frame(width: 220, height: 124)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Text(video.title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)
            Text("\(channel.name) · \(DateText.medium(video.date))")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(width: 220)
        .padding(.vertical, 8)
    }
}

private struct ChannelRow: View {
    let channel: ChannelSummary

    var body: some View {
        HStack(spacing: 12) {
            CDNImage(channel.avatarURL, placeholderSymbol: "person.crop.square")
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 3) {
                Text(channel.name).font(.body.weight(.medium)).lineLimit(2)
                Text("\(channel.videoCount) episodes · \(channel.durationDisplay)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let latest = channel.latestVideo {
                    Text("Latest: \(DateText.medium(latest.date))")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}
