import Foundation

enum APIError: Error, LocalizedError, Equatable {
    case networkError(Error)
    case decodingError(Error)
    case noData

    var errorDescription: String? {
        switch self {
        case .networkError(let e):  return "Network error: \(e.localizedDescription)"
        case .decodingError(let e): return "Decoding error: \(e.localizedDescription)"
        case .noData:               return "No data received"
        }
    }
    
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.networkError(let lErr), .networkError(let rErr)):
            return lErr.localizedDescription == rErr.localizedDescription
        case (.decodingError(let lErr), .decodingError(let rErr)):
            return lErr.localizedDescription == rErr.localizedDescription
        case (.noData, .noData):
            return true
        default:
            return false
        }
    }
}

final class APIClient {
    static let shared = APIClient()
    private let session: URLSession
    private let decoder = JSONDecoder()

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let (data, _) = try await session.data(from: endpoint.url)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
