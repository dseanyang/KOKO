import XCTest
@testable import KKFriendList

// MARK: - Mock Friend Repository
final class MockFriendRepository: FriendRepositoryProtocol {
    var stubbedFriends: Result<[Friend], APIError> = .success([])
    var fetchFriendsCallCount = 0
    var clearCacheCallCount = 0
    var lastScenario: FriendScenario?

    func fetchFriends(scenario: FriendScenario) async -> Result<[Friend], APIError> {
        fetchFriendsCallCount += 1
        lastScenario = scenario
        return stubbedFriends
    }

    func clearCache() {
        clearCacheCallCount += 1
    }
}

// MARK: - GetFriendListUseCaseTests
final class GetFriendListUseCaseTests: XCTestCase {

    var sut: GetFriendListUseCase!
    var mockFriendRepo: MockFriendRepository!

    override func setUp() {
        super.setUp()
        mockFriendRepo = MockFriendRepository()
        sut = GetFriendListUseCase(friendRepository: mockFriendRepo)
    }

    override func tearDown() {
        sut = nil
        mockFriendRepo = nil
        super.tearDown()
    }

    // MARK: - DateParser Tests

    func test_dateParser_parsesYYYYMMDD() {
        XCTAssertNotNil(DateParser.parse("20190801"))
    }

    func test_dateParser_parsesSlashFormat() {
        XCTAssertNotNil(DateParser.parse("2019/08/02"))
    }

    func test_dateParser_returnsNilForInvalid() {
        XCTAssertNil(DateParser.parse("INVALID"))
    }

    func test_dateParser_isNewer_slashNewerThanCompact() {
        XCTAssertTrue(DateParser.isNewer("2019/08/02", than: "20190801"))
    }

    func test_dateParser_isNewer_compactOlderThanSlash() {
        XCTAssertFalse(DateParser.isNewer("20190801", than: "2019/08/02"))
    }

    func test_dateParser_isNewer_sameDatesReturnFalse() {
        XCTAssertFalse(DateParser.isNewer("20190801", than: "20190801"))
    }

    // MARK: - Deduplicate Tests

    func test_deduplicate_uniqueFids_allKept() {
        let list = [
            makeFriend(fid: "001", name: "Alice", updateDate: "20190801"),
            makeFriend(fid: "002", name: "Bob",   updateDate: "20190801"),
            makeFriend(fid: "003", name: "Carol", updateDate: "20190801")
        ]
        let result = sut.deduplicate(list)
        XCTAssertEqual(result.count, 3)
    }

    func test_deduplicate_duplicateFid_takesNewerDate() {
        let list = [
            makeFriend(fid: "001", name: "Alice_old", updateDate: "20190801"),
            makeFriend(fid: "001", name: "Alice_new", updateDate: "2019/08/02")
        ]
        let result = sut.deduplicate(list)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Alice_new")
    }

    func test_deduplicate_duplicateFid_keepsList1IfNewer() {
        let list = [
            makeFriend(fid: "001", name: "Alice_new", updateDate: "2019/08/02"),
            makeFriend(fid: "001", name: "Alice_old", updateDate: "20190801")
        ]
        let result = sut.deduplicate(list)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Alice_new")
    }

    func test_deduplicate_emptyList() {
        XCTAssertTrue(sut.deduplicate([]).isEmpty)
    }

    func test_deduplicate_maintainsInsertionOrder() {
        let list = [
            makeFriend(fid: "002", name: "Bob",   updateDate: "20190801"),
            makeFriend(fid: "001", name: "Alice", updateDate: "20190801"),
            makeFriend(fid: "003", name: "Carol", updateDate: "20190801"),
            makeFriend(fid: "001", name: "Alice_new", updateDate: "2019/08/02") // Should update Alice but keep order
        ]
        let result = sut.deduplicate(list)
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].fid, "002")
        XCTAssertEqual(result[1].fid, "001")
        XCTAssertEqual(result[1].name, "Alice_new")
        XCTAssertEqual(result[2].fid, "003")
    }

    // MARK: - Execute Tests

    func test_execute_separatesInvitationsFromFriends() async {
        let friends = [
            makeFriend(fid: "001", name: "A", updateDate: "20190801", status: 1),
            makeFriend(fid: "002", name: "B", updateDate: "20190801", status: 0),
            makeFriend(fid: "003", name: "C", updateDate: "20190801", status: 2)
        ]
        mockFriendRepo.stubbedFriends = .success(friends)

        let result = await sut.execute(scenario: .withInvitations)
        
        if case .success(let listResult) = result {
            XCTAssertEqual(listResult.friends.count, 2)
            XCTAssertEqual(listResult.invitations.count, 1)
        } else {
            XCTFail("Expected success")
        }
    }

    func test_execute_sortsFriendsCorrectly() async {
        let friends = [
            makeFriend(fid: "001", name: "Charlie", updateDate: "20190801", status: 1, isTop: "0"),
            makeFriend(fid: "002", name: "Alice",   updateDate: "20190801", status: 1, isTop: "1"),
            makeFriend(fid: "003", name: "Bob",     updateDate: "20190801", status: 1, isTop: "0"),
            makeFriend(fid: "004", name: "Dave",    updateDate: "20190801", status: 2, isTop: "0")
        ]
        mockFriendRepo.stubbedFriends = .success(friends)

        let result = await sut.execute(scenario: .friendsOnly)
        
        if case .success(let listResult) = result {
            let sorted = listResult.friends
            XCTAssertEqual(sorted.count, 4)
            // status=2 (inviting) should be first
            XCTAssertEqual(sorted[0].name, "Dave")
            // then isTop="1"
            XCTAssertEqual(sorted[1].name, "Alice")
            // then alphabetical
            XCTAssertEqual(sorted[2].name, "Bob")
            XCTAssertEqual(sorted[3].name, "Charlie")
        } else {
            XCTFail("Expected success")
        }
    }

    func test_execute_callsRepository() async {
        _ = await sut.execute(scenario: .noFriends)
        XCTAssertEqual(mockFriendRepo.fetchFriendsCallCount, 1)
        XCTAssertEqual(mockFriendRepo.lastScenario, .noFriends)
    }

    func test_execute_propagatesRepositoryError() async {
        mockFriendRepo.stubbedFriends = .failure(.networkError(NSError(domain: "test", code: -1)))

        let result = await sut.execute(scenario: .noFriends)
        
        if case .failure = result {
            // Expected
        } else {
            XCTFail("Expected failure")
        }
    }

    // MARK: - Friend Model Tests

    func test_friend_isInvitation_status0() {
        let f = makeFriend(fid: "001", name: "T", updateDate: "20190801", status: 0)
        XCTAssertTrue(f.isInvitation)
    }

    func test_friend_isInvitation_status2() {
        let f = makeFriend(fid: "001", name: "T", updateDate: "20190801", status: 2)
        XCTAssertFalse(f.isInvitation) // status 2 is inviting, not an invitation card
    }

    func test_friend_notInvitation_status1() {
        let f = makeFriend(fid: "001", name: "T", updateDate: "20190801", status: 1)
        XCTAssertFalse(f.isInvitation)
    }

    func test_friend_hasStarBadge_isTop1() {
        let f = makeFriend(fid: "001", name: "T", updateDate: "20190801", isTop: "1")
        XCTAssertTrue(f.hasStarBadge)
    }

    func test_friend_noStarBadge_isTop0() {
        let f = makeFriend(fid: "001", name: "T", updateDate: "20190801", isTop: "0")
        XCTAssertFalse(f.hasStarBadge)
    }

    // MARK: - Helpers

    private func makeFriend(
        fid: String,
        name: String,
        updateDate: String,
        status: Int = 1,
        isTop: String = "0"
    ) -> Friend {
        let json = """
        {
            "name": "\(name)",
            "status": \(status),
            "isTop": "\(isTop)",
            "fid": "\(fid)",
            "updateDate": "\(updateDate)"
        }
        """.data(using: .utf8)!
        return try! JSONDecoder().decode(Friend.self, from: json)
    }
}
