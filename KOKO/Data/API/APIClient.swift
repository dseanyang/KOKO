import Foundation

// MARK: - API Error
enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidURL:            return "Invalid URL"
        case .networkError(let e):  return "Network error: \(e.localizedDescription)"
        case .decodingError(let e): return "Decoding error: \(e.localizedDescription)"
        case .noData:               return "No data received"
        }
    }
}

// MARK: - APIClient
final class APIClient {
    static let shared = APIClient()
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetch<T: Decodable>(urlString: String, type: T.Type) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        let (data, _) = try await session.data(from: url)

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
