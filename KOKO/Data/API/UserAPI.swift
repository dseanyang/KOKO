import Foundation

protocol UserAPIProtocol {
    func fetchUser() async throws -> [User]
}

final class UserAPI: UserAPIProtocol {
    private let client: APIClient
    private let userURL = "\(APIConstants.baseURL)/man.json"

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchUser() async throws -> [User] {
        let response = try await client.fetch(urlString: userURL, type: UserResponse.self)
        return response.response
    }
}
