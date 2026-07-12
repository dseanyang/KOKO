import Foundation

protocol FriendRepositoryProtocol {
    func fetchFriendList1() async throws -> [Friend]
    func fetchFriendList2() async throws -> [Friend]
    func fetchFriendList3() async throws -> [Friend]
    func fetchFriendList4() async throws -> [Friend]
    func clearCache()
}

protocol UserRepositoryProtocol {
    func fetchUser() async throws -> User
    func clearCache()
}
