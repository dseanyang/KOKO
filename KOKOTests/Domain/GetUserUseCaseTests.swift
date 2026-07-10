import XCTest
@testable import KOKO

final class GetUserUseCaseTests: XCTestCase {

    var sut: GetUserUseCase!
    var mockRepo: MockUserRepository!

    override func setUp() {
        super.setUp()
        mockRepo = MockUserRepository()
        sut = GetUserUseCase(userRepository: mockRepo)
    }

    override func tearDown() {
        sut = nil
        mockRepo = nil
        super.tearDown()
    }

    func test_execute_returnsUser() async throws {
        mockRepo.stubbedUser = User(name: "Alice", kokoid: "alice123")
        let user = try await sut.execute()
        
        XCTAssertEqual(user.name, "Alice")
        XCTAssertEqual(user.kokoid, "alice123")
        XCTAssertEqual(mockRepo.fetchUserCallCount, 1)
    }

    func test_execute_propagatesError() async {
        mockRepo.errorToThrow = APIError.noData
        
        do {
            _ = try await sut.execute()
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual(error as? APIError, APIError.noData)
        }
    }
}
