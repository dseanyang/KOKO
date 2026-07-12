import Foundation
import os

protocol FriendRepositoryProtocol {
    func fetchFriendList1() async throws -> [Friend]
    func fetchFriendList2() async throws -> [Friend]
    func fetchFriendList3() async throws -> [Friend]
    func fetchFriendList4() async throws -> [Friend]
    func clearCache()
}

final class FriendRepository: FriendRepositoryProtocol {

    private static let logger = Logger(subsystem: "com.koko.ioskoko", category: "FriendRepository")

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
        do {
            try localDataSource.clearCache()
        } catch {
            Self.logger.error("Failed to clear friend cache: \(error.localizedDescription, privacy: .public)")
        }
    }


    private func fetch(remote: () async throws -> [Friend], cacheKey: FriendCacheKey) async throws -> [Friend] {
        do {
            let friends = try await remote()
            do {
                try localDataSource.saveFriends(friends, cacheKey: cacheKey)
            } catch {
                Self.logger.error("Failed to save friend cache: \(error.localizedDescription, privacy: .public)")
            }
            return friends
        } catch {
            do {
                if let cached = try localDataSource.fetchFriends(cacheKey: cacheKey) {
                    return cached
                }
            } catch {
                Self.logger.error("Failed to read friend cache: \(error.localizedDescription, privacy: .public)")
            }
            throw error
        }
    }
}
