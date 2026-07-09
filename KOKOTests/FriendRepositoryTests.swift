import XCTest
@testable import KKFriendList

// MARK: - Mock Remote DataSource
final class MockFriendAPI: FriendAPIProtocol {
    var stubbedFriends1: [Friend] = []
    var stubbedFriends2: [Friend] = []
    var stubbedFriends3: [Friend] = []
    var stubbedFriends4: [Friend] = []

    var shouldThrowError: APIError?

    var fetchList1CallCount = 0
    var fetchList2CallCount = 0
    var fetchList3CallCount = 0
    var fetchList4CallCount = 0

    func fetchFriendList1() async throws -> [Friend] {
        fetchList1CallCount += 1
        if let error = shouldThrowError { throw error }
        return stubbedFriends1
    }

    func fetchFriendList2() async throws -> [Friend] {
        fetchList2CallCount += 1
        if let error = shouldThrowError { throw error }
        return stubbedFriends2
    }

    func fetchFriendList3() async throws -> [Friend] {
        fetchList3CallCount += 1
        if let error = shouldThrowError { throw error }
        return stubbedFriends3
    }

    func fetchFriendList4() async throws -> [Friend] {
        fetchList4CallCount += 1
        if let error = shouldThrowError { throw error }
        return stubbedFriends4
    }
}

// MARK: - Mock Local DataSource
final class MockFriendLocalDataSource: FriendLocalDataSourceProtocol {
    var stubbedFriends: [Friend]?
    var fetchFriendsCallCount = 0
    var saveFriendsCallCount = 0
    var clearCacheCallCount = 0

    func fetchFriends(scenario: FriendScenario) -> [Friend]? {
        fetchFriendsCallCount += 1
        return stubbedFriends
    }

    func saveFriends(_ friends: [Friend], scenario: FriendScenario) {
        saveFriendsCallCount += 1
    }

    func clearCache() {
        clearCacheCallCount += 1
    }
}

// MARK: - FriendRepositoryTests
final class FriendRepositoryTests: XCTestCase {

    var sut: FriendRepository!
    var mockRemote: MockFriendAPI!
    var mockLocal: MockFriendLocalDataSource!

    override func setUp() {
        super.setUp()
        mockRemote = MockFriendAPI()
        mockLocal = MockFriendLocalDataSource()
        sut = FriendRepository(remoteDataSource: mockRemote, localDataSource: mockLocal)
    }

    override func tearDown() {
        sut = nil
        mockRemote = nil
        mockLocal = nil
        super.tearDown()
    }

    // MARK: - fetchFriends Tests

    func test_fetchFriends_noFriends_callsRemote4AndSaves() async {
        mockRemote.stubbedFriends4 = [makeFriend(name: "A")]
        
        let result = await sut.fetchFriends(scenario: .noFriends)
        
        if case .success(let friends) = result {
            XCTAssertEqual(friends.count, 1)
        } else {
            XCTFail("Expected success")
        }

        XCTAssertEqual(mockRemote.fetchList4CallCount, 1)
        XCTAssertEqual(mockLocal.saveFriendsCallCount, 1)
    }

    func test_fetchFriends_friendsOnly_callsRemote1And2AndSaves() async {
        mockRemote.stubbedFriends1 = [makeFriend(name: "A")]
        mockRemote.stubbedFriends2 = [makeFriend(name: "B")]
        
        let result = await sut.fetchFriends(scenario: .friendsOnly)
        
        if case .success(let friends) = result {
            XCTAssertEqual(friends.count, 2)
        } else {
            XCTFail("Expected success")
        }

        XCTAssertEqual(mockRemote.fetchList1CallCount, 1)
        XCTAssertEqual(mockRemote.fetchList2CallCount, 1)
        XCTAssertEqual(mockLocal.saveFriendsCallCount, 1)
    }

    func test_fetchFriends_withInvitations_callsRemote3AndSaves() async {
        mockRemote.stubbedFriends3 = [makeFriend(name: "C")]
        
        let result = await sut.fetchFriends(scenario: .withInvitations)
        
        if case .success(let friends) = result {
            XCTAssertEqual(friends.count, 1)
        } else {
            XCTFail("Expected success")
        }

        XCTAssertEqual(mockRemote.fetchList3CallCount, 1)
        XCTAssertEqual(mockLocal.saveFriendsCallCount, 1)
    }

    func test_fetchFriends_remoteError_returnsCachedDataIfExists() async {
        mockRemote.shouldThrowError = .invalidURL
        mockLocal.stubbedFriends = [makeFriend(name: "Cached")]
        
        let result = await sut.fetchFriends(scenario: .noFriends)
        
        if case .success(let friends) = result {
            XCTAssertEqual(friends.first?.name, "Cached")
        } else {
            XCTFail("Expected success from cache")
        }
        
        XCTAssertEqual(mockLocal.fetchFriendsCallCount, 1)
    }

    func test_fetchFriends_remoteError_returnsErrorIfNoCache() async {
        mockRemote.shouldThrowError = .invalidURL
        mockLocal.stubbedFriends = nil
        
        let result = await sut.fetchFriends(scenario: .noFriends)
        
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

    // MARK: - Helpers

    private func makeFriend(name: String) -> Friend {
        let json = """
        {
            "name": "\(name)",
            "status": 1,
            "isTop": "0",
            "fid": "001",
            "updateDate": "20190801"
        }
        """.data(using: .utf8)!
        return try! JSONDecoder().decode(Friend.self, from: json)
    }
}
