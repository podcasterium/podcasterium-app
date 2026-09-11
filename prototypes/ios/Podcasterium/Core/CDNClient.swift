import Foundation

enum CDNError: LocalizedError {
    case http(Int, URL)
    case episodeNotFound(String)

    var errorDescription: String? {
        switch self {
        case .http(let code, let url): return "HTTP \(code): \(url.lastPathComponent)"
        case .episodeNotFound(let id): return "Episode \(id) is not on the CDN."
        }
    }
}

/// Thin HTTP layer over the static CDN contract. Optional assets return
/// `nil` on 404 because the pipeline can lag hours or days behind publication.
struct CDNClient {
    static let shared = CDNClient()

    private let session: URLSession
    private let decoder = JSONDecoder()

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetch<T: Decodable>(_ type: T.Type, from url: URL, optional: Bool = false) async throws -> T? {
        let (data, response) = try await session.data(from: url)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        if status == 404, optional { return nil }
        guard status == 200 else { throw CDNError.http(status, url) }
        return try decoder.decode(T.self, from: data)
    }

    func fetchText(from url: URL, optional: Bool = true) async throws -> String? {
        let (data, response) = try await session.data(from: url)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        if status == 404, optional { return nil }
        guard status == 200 else { throw CDNError.http(status, url) }
        return String(decoding: data, as: UTF8.self)
    }

    /// HEAD probe. Any transport error counts as "does not exist".
    func exists(_ url: URL) async -> Bool {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        guard let (_, response) = try? await session.data(for: request) else { return false }
        return (response as? HTTPURLResponse)?.statusCode == 200
    }
}
