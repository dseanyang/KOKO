import Foundation

protocol UserAPIProtocol {
    func fetchUser() async throws -> [UserDTO]
}

final class UserAPI: UserAPIProtocol {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchUser() async throws -> [UserDTO] {
        let response: UserResponseDTO = try await client.request(.user)
        return response.response
    }
}
