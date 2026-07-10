import Foundation

protocol UserAPIProtocol {
    func fetchUser() async throws -> [User]
}

final class UserAPI: UserAPIProtocol {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchUser() async throws -> [User] {
        let response: UserResponseDTO = try await client.request(.user)
        return response.response.map(UserMapper.map)
    }
}
