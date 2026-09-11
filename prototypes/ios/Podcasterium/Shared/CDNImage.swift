import SwiftUI
import UIKit

/// In-memory image cache with ordered fallback URLs. `AsyncImage` cannot
/// fall back, and the CDN has WebP variants only for some episodes.
actor ImageStore {
    static let shared = ImageStore()

    private let cache = NSCache<NSURL, UIImage>()
    private let missing = NSCache<NSURL, NSNumber>()
    private var inflight: [URL: Task<UIImage?, Never>] = [:]

    init() {
        cache.totalCostLimit = 64 * 1024 * 1024
    }

    func image(for urls: [URL]) async -> UIImage? {
        for url in urls {
            if let hit = cache.object(forKey: url as NSURL) { return hit }
            if missing.object(forKey: url as NSURL) != nil { continue }
            if let image = await load(url) { return image }
        }
        return nil
    }

    private func load(_ url: URL) async -> UIImage? {
        if let task = inflight[url] { return await task.value }
        let task = Task<UIImage?, Never> {
            guard let (data, response) = try? await URLSession.shared.data(from: url),
                  (response as? HTTPURLResponse)?.statusCode == 200,
                  let image = UIImage(data: data) else { return nil }
            return image
        }
        inflight[url] = task
        let image = await task.value
        inflight[url] = nil
        if let image {
            cache.setObject(image, forKey: url as NSURL, cost: Int(image.size.width * image.size.height * 4))
        } else {
            missing.setObject(1, forKey: url as NSURL)
        }
        return image
    }
}

/// Image view that tries each URL in order and shows a placeholder when
/// none loads. Hides itself entirely when `hideOnFailure` is set.
struct CDNImage: View {
    let urls: [URL]
    var contentMode: ContentMode = .fill
    var placeholderSymbol: String = "photo"
    var hideOnFailure = false

    @State private var image: UIImage?
    @State private var failed = false

    init(_ url: URL?, contentMode: ContentMode = .fill, placeholderSymbol: String = "photo", hideOnFailure: Bool = false) {
        self.urls = url.map { [$0] } ?? []
        self.contentMode = contentMode
        self.placeholderSymbol = placeholderSymbol
        self.hideOnFailure = hideOnFailure
    }

    init(candidates: [URL], contentMode: ContentMode = .fill, placeholderSymbol: String = "photo", hideOnFailure: Bool = false) {
        self.urls = candidates
        self.contentMode = contentMode
        self.placeholderSymbol = placeholderSymbol
        self.hideOnFailure = hideOnFailure
    }

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if failed && hideOnFailure {
                EmptyView()
            } else {
                ZStack {
                    Rectangle().fill(.quaternary)
                    if failed {
                        Image(systemName: placeholderSymbol).foregroundStyle(.secondary)
                    } else {
                        ProgressView().controlSize(.small)
                    }
                }
            }
        }
        .task(id: urls) {
            image = nil
            failed = false
            let loaded = await ImageStore.shared.image(for: urls)
            image = loaded
            failed = loaded == nil
        }
    }
}
