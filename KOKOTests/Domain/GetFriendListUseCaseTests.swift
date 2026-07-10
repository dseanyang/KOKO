import XCTest
@testable import KOKO

final class GetFriendListUseCaseTests: XCTestCase {

    var sut: GetFriendListUseCase!
    var mockRepo: MockFriendRepository!
    var mockMerger: MockFriendMerger!
    var mockSorter: MockFriendSorter!

    override func setUp() {
        super.setUp()
        mockRepo = MockFriendRepository()
        mockMerger = MockFriendMerger()
        mockSorter = MockFriendSorter()
        sut = GetFriendListUseCase(
            friendRepository: mockRepo,
            merger: mockMerger,
            sorter: mockSorter
        )
    }

    override func tearDown() {
        sut = nil
        mockRepo = nil
        mockMerger = nil
        mockSorter = nil
        super.tearDown()
    }

    func test_execute_noFriends_callsList4() async throws {
        mockRepo.stubbedList4 = []
        _ = try await sut.execute(scenario: .noFriends)
        XCTAssertEqual(mockRepo.fetchList4CallCount, 1)
        XCTAssertEqual(mockRepo.fetchList1CallCount, 0)
    }

    func test_execute_friendsOnly_callsList1And2() async throws {
        mockRepo.stubbedList1 = []
        mockRepo.stubbedList2 = []
        _ = try await sut.execute(scenario: .friendsOnly)
        XCTAssertEqual(mockRepo.fetchList1CallCount, 1)
        XCTAssertEqual(mockRepo.fetchList2CallCount, 1)
    }

    func test_execute_withInvitations_callsList3() async throws {
        mockRepo.stubbedList3 = []
        _ = try await sut.execute(scenario: .withInvitations)
        XCTAssertEqual(mockRepo.fetchList3CallCount, 1)
    }

    func test_execute_separatesInvitations() async throws {
        let f1 = Friend(fid: "1", name: "A", status: 1, isTop: "0", updateDate: "")
        let f2 = Friend(fid: "2", name: "B", status: 0, isTop: "0", updateDate: "") // invitation
        let f3 = Friend(fid: "3", name: "C", status: 1, isTop: "0", updateDate: "")
        
        mockMerger.stubbedResult = [f1, f2, f3]
        mockSorter.stubbedResult = [f1, f3] // return only non-invitations
        
        let result = try await sut.execute(scenario: .noFriends)
        
        XCTAssertEqual(result.invitations.count, 1)
        XCTAssertEqual(result.invitations.first?.fid, "2")
        XCTAssertEqual(result.friends.count, 2)
    }

    func test_execute_propagatesError() async {
        mockRepo.errorToThrow = APIError.noData
        
        do {
            _ = try await sut.execute(scenario: .noFriends)
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual(error as? APIError, APIError.noData)
        }
    }
}
