import XCTest
@testable import KOKO

final class FriendRepositoryTests: XCTestCase {

    var sut: FriendRepository!
    var mockAPI: MockFriendAPI!
    var mockLocal: MockFriendLocalDataSource!

    override func setUp() {
        super.setUp()
        mockAPI = MockFriendAPI()
        mockLocal = MockFriendLocalDataSource()
        sut = FriendRepository(remoteDataSource: mockAPI, localDataSource: mockLocal)
    }

    override func tearDown() {
        sut = nil
        mockAPI = nil
        mockLocal = nil
        super.tearDown()
    }

    func test_fetchFriendList1_success_savesToCache() async throws {
        let remoteFriends = [Friend(fid: "1", name: "Remote", status: 1, isTop: "0", updateDate: "")]
        mockAPI.stubbedList1 = remoteFriends
        
        let result = try await sut.fetchFriendList1()
        
        XCTAssertEqual(result.first?.name, "Remote")
        XCTAssertEqual(mockLocal.savedFriends[.friend1]?.count, 1, "Should save to local cache")
    }

    func test_fetchFriendList1_networkError_fallsBackToCache() async throws {
        mockAPI.errorToThrow = APIError.noData
        let cachedFriends = [Friend(fid: "1", name: "Cached", status: 1, isTop: "0", updateDate: "")]
        mockLocal.savedFriends[.friend1] = cachedFriends
        
        let result = try await sut.fetchFriendList1()
        
        XCTAssertEqual(result.first?.name, "Cached", "Should fallback to cache on error")
    }

    func test_fetchFriendList1_networkErrorAndNoCache_throwsError() async {
        mockAPI.errorToThrow = APIError.noData
        mockLocal.savedFriends.removeAll()
        
        do {
            _ = try await sut.fetchFriendList1()
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual(error as? APIError, APIError.noData)
        }
    }

    func test_clearCache_callsLocalDataSource() {
        sut.clearCache()
        XCTAssertEqual(mockLocal.clearCacheCallCount, 1)
    }
}
