import Foundation

protocol FriendAPIProtocol {
    func fetchFriendList1() async throws -> [Friend]
    func fetchFriendList2() async throws -> [Friend]
    func fetchFriendList3() async throws -> [Friend]
    func fetchFriendList4() async throws -> [Friend]
}

final class FriendAPI: FriendAPIProtocol {
    private let client: APIClient

    private let friend1URL = "\(APIConstants.baseURL)/friend1.json"
    private let friend2URL = "\(APIConstants.baseURL)/friend2.json"
    private let friend3URL = "\(APIConstants.baseURL)/friend3.json"
    private let friend4URL = "\(APIConstants.baseURL)/friend4.json"

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchFriendList1() async throws -> [Friend] { try await fetch(url: friend1URL) }
    func fetchFriendList2() async throws -> [Friend] { try await fetch(url: friend2URL) }
    func fetchFriendList3() async throws -> [Friend] { try await fetch(url: friend3URL) }
    func fetchFriendList4() async throws -> [Friend] { try await fetch(url: friend4URL) }

    private func fetch(url: String) async throws -> [Friend] {
        let response = try await client.fetch(urlString: url, type: FriendResponse.self)
        return response.response
    }
}
