import Foundation

protocol FriendAPIProtocol {
    func fetchFriendList1() async throws -> [FriendDTO]
    func fetchFriendList2() async throws -> [FriendDTO]
    func fetchFriendList3() async throws -> [FriendDTO]
    func fetchFriendList4() async throws -> [FriendDTO]
}

final class FriendAPI: FriendAPIProtocol {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchFriendList1() async throws -> [FriendDTO] { try await fetch(.friendList1) }
    func fetchFriendList2() async throws -> [FriendDTO] { try await fetch(.friendList2) }
    func fetchFriendList3() async throws -> [FriendDTO] { try await fetch(.friendList3) }
    func fetchFriendList4() async throws -> [FriendDTO] { try await fetch(.friendList4) }


    private func fetch(_ endpoint: Endpoint) async throws -> [FriendDTO] {
        let response: FriendResponseDTO = try await client.request(endpoint)
        return response.response
    }
}
