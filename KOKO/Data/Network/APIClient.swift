import Foundation

enum APIError: Error, LocalizedError, Equatable {
    case networkError(Error)
    case decodingError(Error)
    case invalidResponse
    case httpStatus(Int)
    case noData

    var errorDescription: String? {
        switch self {
        case .networkError(let e):  return "Network error: \(e.localizedDescription)"
        case .decodingError(let e): return "Decoding error: \(e.localizedDescription)"
        case .invalidResponse:      return "Invalid server response"
        case .httpStatus(let code): return "Server returned HTTP \(code)"
        case .noData:               return "No data received"
        }
    }
    
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.networkError(let lErr), .networkError(let rErr)):
            return lErr.localizedDescription == rErr.localizedDescription
        case (.decodingError(let lErr), .decodingError(let rErr)):
            return lErr.localizedDescription == rErr.localizedDescription
        case (.invalidResponse, .invalidResponse):
            return true
        case (.httpStatus(let lCode), .httpStatus(let rCode)):
            return lCode == rCode
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
        do {
            let (data, response) = try await session.data(from: endpoint.url)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.httpStatus(httpResponse.statusCode)
            }

            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}
