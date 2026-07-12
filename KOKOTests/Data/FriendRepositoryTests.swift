import XCTest
import Foundation
@testable import KOKO

private final class StubURLProtocol: URLProtocol {
    static var handler: ((URLRequest) -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        let (response, data) = handler(request)
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

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
        StubURLProtocol.handler = nil
        sut = nil
        mockAPI = nil
        mockLocal = nil
        super.tearDown()
    }

    func test_fetchFriendList1_success_savesToCache() async throws {
        let remoteFriends = [FriendDTO(name: "Remote", status: 1, isTop: "0", fid: "1", updateDate: "")]
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

    func test_fetchFriendList1_cacheWriteFailure_stillReturnsRemoteData() async throws {
        let remoteFriends = [FriendDTO(name: "Remote", status: 1, isTop: "0", fid: "1", updateDate: "")]
        mockAPI.stubbedList1 = remoteFriends
        mockLocal.errorToThrow = MockCacheError.unavailable

        let result = try await sut.fetchFriendList1()

        XCTAssertEqual(result.first?.name, "Remote")
    }

    func test_apiClient_successfulHTTPResponse_decodesPayload() async throws {
        StubURLProtocol.handler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://test.local")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = Data(#"{"response":[{"name":"Alice","status":1,"isTop":"0","fid":"1","updateDate":"20240101"}]}"#.utf8)
            return (response, data)
        }

        let response: FriendResponseDTO = try await APIClient(session: makeStubSession()).request(.friendList1)

        XCTAssertEqual(response.response.first?.name, "Alice")
    }

    func test_apiClient_nonSuccessHTTPResponse_throwsHTTPStatusError() async {
        StubURLProtocol.handler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://test.local")!,
                statusCode: 503,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        do {
            let _: FriendResponseDTO = try await APIClient(session: makeStubSession()).request(.friendList1)
            XCTFail("Expected HTTP status error")
        } catch {
            XCTAssertEqual(error as? APIError, .httpStatus(503))
        }
    }

    func test_clearCache_callsLocalDataSource() {
        sut.clearCache()
        XCTAssertEqual(mockLocal.clearCacheCallCount, 1)
    }

    private func makeStubSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return URLSession(configuration: configuration)
    }
}
