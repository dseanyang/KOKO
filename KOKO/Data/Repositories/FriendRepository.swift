import Foundation

protocol FriendRepositoryProtocol {
    func fetchFriendList1() async throws -> [Friend]
    func fetchFriendList2() async throws -> [Friend]
    func fetchFriendList3() async throws -> [Friend]
    func fetchFriendList4() async throws -> [Friend]
    func clearCache()
}

final class FriendRepository: FriendRepositoryProtocol {

    private let remoteDataSource: FriendAPIProtocol
    private let localDataSource: FriendLocalDataSourceProtocol

    init(remoteDataSource: FriendAPIProtocol = FriendAPI(),
         localDataSource: FriendLocalDataSourceProtocol = FriendCoreData()) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }


    func fetchFriendList1() async throws -> [Friend] {
        try await fetch(remote: { try await self.remoteDataSource.fetchFriendList1() }, cacheKey: .friend1)
    }

    func fetchFriendList2() async throws -> [Friend] {
        try await fetch(remote: { try await self.remoteDataSource.fetchFriendList2() }, cacheKey: .friend2)
    }

    func fetchFriendList3() async throws -> [Friend] {
        try await fetch(remote: { try await self.remoteDataSource.fetchFriendList3() }, cacheKey: .friend3)
    }

    func fetchFriendList4() async throws -> [Friend] {
        try await fetch(remote: { try await self.remoteDataSource.fetchFriendList4() }, cacheKey: .friend4)
    }

    func clearCache() {
        localDataSource.clearCache()
    }


    private func fetch(remote: () async throws -> [Friend], cacheKey: FriendCacheKey) async throws -> [Friend] {
        do {
            var friends = try await remote()
            friends.append(
                Friend(
                    fid: "1",
                    name: "測試好友",
                    status: 0,
                    isTop: "1",
                    updateDate: "10000000000000000"
                )
            )
            friends.append(
                Friend(
                    fid: "11",
                    name: "測試好友1",
                    status: 0,
                    isTop: "1",
                    updateDate: "10000000000000000"
                )
            )
            friends.append(
                Friend(
                    fid: "111",
                    name: "測試好友111",
                    status: 0,
                    isTop: "1",
                    updateDate: "10000000000000000"
                )
            )
            friends.append(
                Friend(
                    fid: "1",
                    name: "測試好友11",
                    status: 0,
                    isTop: "1",
                    updateDate: "10000000000000000"
                )
            )
            friends.append(
                Friend(
                    fid: "12",
                    name: "測試好友12",
                    status: 0,
                    isTop: "1",
                    updateDate: "10000000000000000"
                )
            )
//            friends.append(
//                Friend(
//                    fid: "13",
//                    name: "測試好友13",
//                    status: 0,
//                    isTop: "1",
//                    updateDate: "10000000000000000"
//                )
//            )
            localDataSource.saveFriends(friends, cacheKey: cacheKey)
            return friends
        } catch {
            if let cached = localDataSource.fetchFriends(cacheKey: cacheKey) {
                return cached
            }
            throw error
        }
    }
}
