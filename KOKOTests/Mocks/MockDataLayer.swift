import Foundation
@testable import KOKO

final class MockFriendAPI: FriendAPIProtocol {
    var stubbedList1: [Friend] = []
    var stubbedList2: [Friend] = []
    var stubbedList3: [Friend] = []
    var stubbedList4: [Friend] = []
    var errorToThrow: Error?

    func fetchFriendList1() async throws -> [Friend] {
        if let error = errorToThrow { throw error }
        return stubbedList1
    }
    func fetchFriendList2() async throws -> [Friend] {
        if let error = errorToThrow { throw error }
        return stubbedList2
    }
    func fetchFriendList3() async throws -> [Friend] {
        if let error = errorToThrow { throw error }
        return stubbedList3
    }
    func fetchFriendList4() async throws -> [Friend] {
        if let error = errorToThrow { throw error }
        return stubbedList4
    }
}

final class MockUserAPI: UserAPIProtocol {
    var stubbedUser: [User] = []
    var errorToThrow: Error?

    func fetchUser() async throws -> [User] {
        if let error = errorToThrow { throw error }
        return stubbedUser
    }
}

final class MockFriendLocalDataSource: FriendLocalDataSourceProtocol {
    var savedFriends: [FriendCacheKey: [Friend]] = [:]
    var clearCacheCallCount = 0

    func fetchFriends(cacheKey: FriendCacheKey) -> [Friend]? {
        savedFriends[cacheKey]
    }

    func saveFriends(_ friends: [Friend], cacheKey: FriendCacheKey) {
        savedFriends[cacheKey] = friends
    }

    func clearCache() {
        clearCacheCallCount += 1
        savedFriends.removeAll()
    }
}

final class MockUserLocalDataSource: UserLocalDataSourceProtocol {
    var savedUser: User?
    var clearCacheCallCount = 0

    func fetchUser() -> User? {
        savedUser
    }

    func saveUser(_ user: User) {
        savedUser = user
    }

    func clearCache() {
        clearCacheCallCount += 1
        savedUser = nil
    }
}

final class MockFriendRepository: FriendRepositoryProtocol {
    var stubbedList1: [Friend] = []
    var stubbedList2: [Friend] = []
    var stubbedList3: [Friend] = []
    var stubbedList4: [Friend] = []
    var errorToThrow: Error?
    
    var fetchList1CallCount = 0
    var fetchList2CallCount = 0
    var fetchList3CallCount = 0
    var fetchList4CallCount = 0
    var clearCacheCallCount = 0

    func fetchFriendList1() async throws -> [Friend] {
        fetchList1CallCount += 1
        if let error = errorToThrow { throw error }
        return stubbedList1
    }
    func fetchFriendList2() async throws -> [Friend] {
        fetchList2CallCount += 1
        if let error = errorToThrow { throw error }
        return stubbedList2
    }
    func fetchFriendList3() async throws -> [Friend] {
        fetchList3CallCount += 1
        if let error = errorToThrow { throw error }
        return stubbedList3
    }
    func fetchFriendList4() async throws -> [Friend] {
        fetchList4CallCount += 1
        if let error = errorToThrow { throw error }
        return stubbedList4
    }
    func clearCache() {
        clearCacheCallCount += 1
    }
}

final class MockUserRepository: UserRepositoryProtocol {
    var stubbedUser: User = User(name: "Test", kokoid: "test")
    var errorToThrow: Error?
    
    var fetchUserCallCount = 0
    var clearCacheCallCount = 0

    func fetchUser() async throws -> User {
        fetchUserCallCount += 1
        if let error = errorToThrow { throw error }
        return stubbedUser
    }
    
    func clearCache() {
        clearCacheCallCount += 1
    }
}
