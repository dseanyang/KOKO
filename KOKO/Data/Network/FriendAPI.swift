import Foundation

protocol FriendAPIProtocol {
    func fetchFriendList1() async throws -> [Friend]
    func fetchFriendList2() async throws -> [Friend]
    func fetchFriendList3() async throws -> [Friend]
    func fetchFriendList4() async throws -> [Friend]
}

final class FriendAPI: FriendAPIProtocol {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchFriendList1() async throws -> [Friend] { try await fetch(.friendList1) }
    func fetchFriendList2() async throws -> [Friend] { try await fetch(.friendList2) }
    func fetchFriendList3() async throws -> [Friend] { try await fetch(.friendList3) }
    func fetchFriendList4() async throws -> [Friend] { try await fetch(.friendList4) }


    private func fetch(_ endpoint: Endpoint) async throws -> [Friend] {
        let response: FriendResponseDTO = try await client.request(endpoint)
        return FriendMapper.map(response.response)
    }
}
