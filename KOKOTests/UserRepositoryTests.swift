import XCTest
@testable import KKFriendList

// MARK: - Mock User Remote DataSource
final class MockUserRemoteDataSource: UserAPIProtocol {
    var stubbedUsers: [User] = [User(name: "Test User", kokoid: "test_koko")]
    var shouldThrowError: APIError?
    var fetchUserCallCount = 0

    func fetchUser() async throws -> [User] {
        fetchUserCallCount += 1
        if let error = shouldThrowError {
            throw error
        }
        return stubbedUsers
    }
}

// MARK: - Mock User Local DataSource
final class MockUserLocalDataSource: UserLocalDataSourceProtocol {
    var stubbedUser: User?
    var fetchUserCallCount = 0
    var saveUserCallCount = 0
    var clearCacheCallCount = 0

    func fetchUser() -> User? {
        fetchUserCallCount += 1
        return stubbedUser
    }

    func saveUser(_ user: User) {
        saveUserCallCount += 1
        stubbedUser = user
    }

    func clearCache() {
        clearCacheCallCount += 1
        stubbedUser = nil
    }
}

// MARK: - UserRepositoryTests
final class UserRepositoryTests: XCTestCase {

    var sut: UserRepository!
    var mockRemote: MockUserRemoteDataSource!
    var mockLocal: MockUserLocalDataSource!

    override func setUp() {
        super.setUp()
        mockRemote = MockUserRemoteDataSource()
        mockLocal = MockUserLocalDataSource()
        sut = UserRepository(remoteDataSource: mockRemote, localDataSource: mockLocal)
    }

    override func tearDown() {
        sut = nil
        mockRemote = nil
        mockLocal = nil
        super.tearDown()
    }

    // MARK: - fetchUser Tests

    func test_fetchUser_success_returnsFirstUserAndSavesToLocal() async {
        let result = await sut.fetchUser()

        if case .success(let user) = result {
            XCTAssertEqual(user.name, "Test User")
            XCTAssertEqual(user.kokoid, "test_koko")
        } else {
            XCTFail("Expected success")
        }

        XCTAssertEqual(mockRemote.fetchUserCallCount, 1)
        XCTAssertEqual(mockLocal.saveUserCallCount, 1)
    }

    func test_fetchUser_remoteEmpty_returnsNoDataError() async {
        mockRemote.stubbedUsers = []

        let result = await sut.fetchUser()

        if case .failure(let error) = result, case .noData = error {
            // Success
        } else {
            XCTFail("Expected noData error")
        }
    }

    func test_fetchUser_remoteEmpty_returnsCachedDataIfExists() async {
        mockRemote.stubbedUsers = []
        mockLocal.stubbedUser = User(name: "Cached User", kokoid: "cached_koko")

        let result = await sut.fetchUser()

        if case .success(let user) = result {
            XCTAssertEqual(user.name, "Cached User")
        } else {
            XCTFail("Expected success from cache")
        }
    }

    func test_fetchUser_remoteError_returnsCachedDataIfExists() async {
        mockRemote.shouldThrowError = .invalidURL
        mockLocal.stubbedUser = User(name: "Cached User", kokoid: "cached_koko")

        let result = await sut.fetchUser()

        if case .success(let user) = result {
            XCTAssertEqual(user.name, "Cached User")
        } else {
            XCTFail("Expected success from cache")
        }
    }

    func test_fetchUser_remoteError_returnsErrorIfNoCache() async {
        mockRemote.shouldThrowError = .invalidURL
        mockLocal.stubbedUser = nil

        let result = await sut.fetchUser()

        if case .failure(let error) = result, case .invalidURL = error {
            // Expected
        } else {
            XCTFail("Expected invalidURL error")
        }
    }

    func test_clearCache_callsLocalDataSource() {
        sut.clearCache()
        XCTAssertEqual(mockLocal.clearCacheCallCount, 1)
    }
}
