import XCTest
@testable import KOKO

final class UserRepositoryTests: XCTestCase {

    var sut: UserRepository!
    var mockAPI: MockUserAPI!
    var mockLocal: MockUserLocalDataSource!

    override func setUp() {
        super.setUp()
        mockAPI = MockUserAPI()
        mockLocal = MockUserLocalDataSource()
        sut = UserRepository(remoteDataSource: mockAPI, localDataSource: mockLocal)
    }

    override func tearDown() {
        sut = nil
        mockAPI = nil
        mockLocal = nil
        super.tearDown()
    }

    func test_fetchUser_success_savesToCache() async throws {
        let remoteUser = User(name: "Remote", kokoid: "remote")
        mockAPI.stubbedUser = [remoteUser]
        
        let result = try await sut.fetchUser()
        
        XCTAssertEqual(result.name, "Remote")
        XCTAssertEqual(mockLocal.savedUser?.name, "Remote")
    }

    func test_fetchUser_networkError_fallsBackToCache() async throws {
        mockAPI.errorToThrow = APIError.noData
        mockLocal.savedUser = User(name: "Cached", kokoid: "cached")
        
        let result = try await sut.fetchUser()
        
        XCTAssertEqual(result.name, "Cached")
    }

    func test_fetchUser_networkReturnsEmpty_fallsBackToCache() async throws {
        mockAPI.stubbedUser = [] // API returned empty array
        mockLocal.savedUser = User(name: "Cached", kokoid: "cached")
        
        let result = try await sut.fetchUser()
        
        XCTAssertEqual(result.name, "Cached")
    }

    func test_fetchUser_networkErrorAndNoCache_throwsError() async {
        mockAPI.errorToThrow = APIError.noData
        mockLocal.savedUser = nil
        
        do {
            _ = try await sut.fetchUser()
            XCTFail("Should throw error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func test_fetchUser_cacheWriteFailure_stillReturnsRemoteData() async throws {
        let remoteUser = User(name: "Remote", kokoid: "remote")
        mockAPI.stubbedUser = [remoteUser]
        mockLocal.errorToThrow = MockCacheError.unavailable

        let result = try await sut.fetchUser()

        XCTAssertEqual(result.name, "Remote")
    }
}
