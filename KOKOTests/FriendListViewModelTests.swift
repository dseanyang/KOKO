import XCTest
@testable import KOKO

// MARK: - Mock UseCase
final class MockGetFriendListUseCase: GetFriendListUseCaseProtocol {
    var stubbedResult: Result<FriendListResult, APIError> = .success(
        FriendListResult(friends: [], invitations: [])
    )
    var executeCallCount = 0
    var lastScenario: FriendScenario?

    func execute(scenario: FriendScenario) async -> Result<FriendListResult, APIError> {
        executeCallCount += 1
        lastScenario = scenario
        return stubbedResult
    }
}

// MARK: - Mock UserRepository
final class MockUserRepositoryForViewModel: UserRepositoryProtocol {
    var stubbedResult: Result<User, APIError> = .success(User(name: "Test User", kokoid: "testid"))
    var fetchUserCallCount = 0

    func fetchUser() async -> Result<User, APIError> {
        fetchUserCallCount += 1
        return stubbedResult
    }

    func clearCache() {}
}

// MARK: - FriendListViewModelTests
@MainActor
final class FriendListViewModelTests: XCTestCase {

    var sut: FriendListViewModel!
    var mockUseCase: MockGetFriendListUseCase!
    var mockUserRepo: MockUserRepositoryForViewModel!

    override func setUp() {
        super.setUp()
        mockUseCase = MockGetFriendListUseCase()
        mockUserRepo = MockUserRepositoryForViewModel()
        sut = FriendListViewModel(useCase: mockUseCase, userRepository: mockUserRepo)
    }

    override func tearDown() {
        sut = nil
        mockUseCase = nil
        mockUserRepo = nil
        super.tearDown()
    }

    // MARK: - loadData Tests

    func test_loadData_callsUseCaseAndRepo() {
        let exp = expectation(description: "loading finished")
        sut.onLoadingChanged = { isLoading in
            if !isLoading { exp.fulfill() }
        }

        sut.loadData(scenario: .noFriends)

        waitForExpectations(timeout: 1)
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
        XCTAssertEqual(mockUserRepo.fetchUserCallCount, 1)
        XCTAssertEqual(mockUseCase.lastScenario, .noFriends)
    }

    func test_loadData_clearsSearchByDefault() {
        sut.searchText = "some search"
        let exp = expectation(description: "loading finished")
        sut.onLoadingChanged = { isLoading in
            if !isLoading { exp.fulfill() }
        }

        sut.loadData(scenario: .friendsOnly)

        waitForExpectations(timeout: 1)
        XCTAssertEqual(sut.searchText, "")
    }

    func test_loadData_withClearSearchFalse_preservesSearchText() {
        sut.searchText = "keep this"
        let exp = expectation(description: "loading finished")
        sut.onLoadingChanged = { isLoading in
            if !isLoading { exp.fulfill() }
        }

        sut.loadData(scenario: .friendsOnly, clearSearch: false)

        waitForExpectations(timeout: 1)
        XCTAssertEqual(sut.searchText, "keep this")
    }

    func test_loadData_success_updatesUser() {
        let expectedUser = User(name: "紫琳", kokoid: "olylinhuang")
        mockUserRepo.stubbedResult = .success(expectedUser)
        
        let exp = expectation(description: "user loading finished")
        sut.onUserLoadingChanged = { isLoading in
            if !isLoading { exp.fulfill() }
        }

        sut.loadData(scenario: .friendsOnly)

        waitForExpectations(timeout: 1)
        XCTAssertEqual(sut.user?.name, "紫琳")
        XCTAssertEqual(sut.user?.kokoid, "olylinhuang")
    }

    func test_loadData_success_updatesFriendsAndInvitations() {
        let friends = [makeFriend(fid: "001", name: "Alice", status: 1)]
        let invitations = [makeFriend(fid: "002", name: "Bob", status: 0)]
        mockUseCase.stubbedResult = .success(
            FriendListResult(friends: friends, invitations: invitations)
        )
        let exp = expectation(description: "loading finished")
        sut.onLoadingChanged = { isLoading in
            if !isLoading { exp.fulfill() }
        }

        sut.loadData(scenario: .withInvitations)

        waitForExpectations(timeout: 1)
        XCTAssertEqual(sut.friends.count, 1)
        XCTAssertEqual(sut.invitations.count, 1)
        XCTAssertTrue(sut.hasFriends)
        XCTAssertTrue(sut.hasInvitations)
    }

    func test_loadData_failure_triggersOnError() {
        mockUseCase.stubbedResult = .failure(.networkError(NSError(domain: "test", code: -1)))
        let exp = expectation(description: "onError called")
        sut.onError = { _ in exp.fulfill() }

        sut.loadData(scenario: .noFriends)

        waitForExpectations(timeout: 1)
    }

    func test_loadData_triggersLoadingChanged() {
        let exp = expectation(description: "Loading finished")
        var states: [Bool] = []
        sut.onLoadingChanged = { isLoading in
            states.append(isLoading)
            if !isLoading { exp.fulfill() }
        }

        sut.loadData(scenario: .noFriends)

        waitForExpectations(timeout: 1)
        XCTAssertEqual(states.first, true, "Should start loading")
        XCTAssertEqual(states.last, false, "Should stop loading")
    }

    // MARK: - refresh Tests

    func test_refresh_callsUseCaseWithCurrentScenario() {
        let exp1 = expectation(description: "initial load")
        sut.onLoadingChanged = { isLoading in
            if !isLoading { exp1.fulfill() }
        }
        sut.loadData(scenario: .withInvitations)
        waitForExpectations(timeout: 1)

        let exp2 = expectation(description: "refresh done")
        sut.onLoadingChanged = { isLoading in
            if !isLoading { exp2.fulfill() }
        }
        sut.refresh()

        waitForExpectations(timeout: 1)
        XCTAssertEqual(mockUseCase.lastScenario, .withInvitations)
        XCTAssertEqual(mockUseCase.executeCallCount, 2)
    }

    func test_refresh_preservesSearchText() {
        // First load
        let exp1 = expectation(description: "first load")
        sut.onLoadingChanged = { isLoading in
            if !isLoading { exp1.fulfill() }
        }
        sut.loadData(scenario: .friendsOnly)
        waitForExpectations(timeout: 1)

        sut.searchText = "search term"

        let exp2 = expectation(description: "refresh done")
        sut.onLoadingChanged = { isLoading in
            if !isLoading { exp2.fulfill() }
        }
        sut.refresh()
        waitForExpectations(timeout: 1)

        XCTAssertEqual(sut.searchText, "search term")
    }

    // MARK: - Search Filter Tests

    func test_searchFilter_byName() {
        let friends = [
            makeFriend(fid: "001", name: "黃靖僑", status: 1),
            makeFriend(fid: "002", name: "翁勳儀", status: 1)
        ]
        mockUseCase.stubbedResult = .success(
            FriendListResult(friends: friends, invitations: [])
        )
        let exp = expectation(description: "load done")
        sut.onLoadingChanged = { isLoading in
            if !isLoading { exp.fulfill() }
        }
        sut.loadData(scenario: .friendsOnly)
        waitForExpectations(timeout: 1)

        sut.searchText = "黃"

        XCTAssertEqual(sut.filteredFriends.count, 1)
        XCTAssertEqual(sut.filteredFriends.first?.name, "黃靖僑")
    }

    func test_searchFilter_emptyTextReturnsAll() {
        let friends = [makeFriend(fid: "001", name: "A", status: 1), makeFriend(fid: "002", name: "B", status: 1)]
        mockUseCase.stubbedResult = .success(
            FriendListResult(friends: friends, invitations: [])
        )
        let exp = expectation(description: "load done")
        sut.onLoadingChanged = { isLoading in
            if !isLoading { exp.fulfill() }
        }
        sut.loadData(scenario: .friendsOnly)
        waitForExpectations(timeout: 1)

        sut.searchText = ""

        XCTAssertEqual(sut.filteredFriends.count, sut.friends.count)
    }

    func test_searchFilter_noMatch_returnsEmpty() {
        let friends = [makeFriend(fid: "001", name: "Alice", status: 1)]
        mockUseCase.stubbedResult = .success(
            FriendListResult(friends: friends, invitations: [])
        )
        let exp = expectation(description: "load done")
        sut.onLoadingChanged = { isLoading in
            if !isLoading { exp.fulfill() }
        }
        sut.loadData(scenario: .friendsOnly)
        waitForExpectations(timeout: 1)

        sut.searchText = "ZZZZZ"

        XCTAssertTrue(sut.filteredFriends.isEmpty)
    }

    // MARK: - toggleInvitationExpanded Tests

    func test_toggleInvitationExpanded_defaultIsFalse() {
        XCTAssertFalse(sut.isInvitationExpanded) // Default is false from our code inspection
    }

    func test_toggleInvitationExpanded_togglesCorrectly() {
        sut.toggleInvitationExpanded()
        XCTAssertTrue(sut.isInvitationExpanded)

        sut.toggleInvitationExpanded()
        XCTAssertFalse(sut.isInvitationExpanded)
    }

    func test_toggleInvitationExpanded_triggersOnUpdate() {
        let exp = expectation(description: "onUpdate triggered")
        sut.onUpdate = { exp.fulfill() }

        sut.toggleInvitationExpanded()

        waitForExpectations(timeout: 1)
    }

    // MARK: - Scenario Tests

    func test_scenario_noFriends_hasCorrectTitle() {
        XCTAssertEqual(FriendScenario.noFriends.title, "情境 I：無好友畫面")
    }

    func test_scenario_friendsOnly_hasCorrectTitle() {
        XCTAssertEqual(FriendScenario.friendsOnly.title, "情境 II：只有好友列表")
    }

    func test_scenario_withInvitations_hasCorrectTitle() {
        XCTAssertEqual(FriendScenario.withInvitations.title, "情境 III：好友列表含邀請")
    }

    func test_allScenarios_count() {
        XCTAssertEqual(FriendScenario.allCases.count, 3)
    }

    // MARK: - Helpers

    private func makeFriend(fid: String, name: String, status: Int = 1, isTop: String = "0") -> Friend {
        let json = """
        {
            "name": "\(name)",
            "status": \(status),
            "isTop": "\(isTop)",
            "fid": "\(fid)",
            "updateDate": "20190801"
        }
        """.data(using: .utf8)!
        return try! JSONDecoder().decode(Friend.self, from: json)
    }
}
