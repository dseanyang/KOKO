import XCTest
@testable import KOKO

@MainActor
final class FriendListViewModelTests: XCTestCase {

    var sut: FriendListViewModel!
    var mockFriendUseCase: MockGetFriendListUseCase!
    var mockUserUseCase: MockGetUserUseCase!

    override func setUp() {
        super.setUp()
        mockFriendUseCase = MockGetFriendListUseCase()
        mockUserUseCase = MockGetUserUseCase()
        sut = FriendListViewModel(
            getFriendListUseCase: mockFriendUseCase,
            getUserUseCase: mockUserUseCase
        )
    }

    override func tearDown() {
        sut = nil
        mockFriendUseCase = nil
        mockUserUseCase = nil
        super.tearDown()
    }

    func test_loadData_emitsLoadingThenLoaded() {
        let expUser = expectation(description: "User loaded")
        var userStates: [ViewState] = []
        sut.onUserStateChanged = { state in
            userStates.append(state)
            if state == .loaded { expUser.fulfill() }
        }

        let expFriends = expectation(description: "Friends loaded")
        var friendsStates: [ViewState] = []
        sut.onFriendsStateChanged = { state in
            friendsStates.append(state)
            if state == .loaded { expFriends.fulfill() }
        }

        sut.loadData(scenario: .noFriends)
        
        waitForExpectations(timeout: 1)
        
        XCTAssertEqual(userStates.first, .loading)
        XCTAssertEqual(userStates.last, .loaded)
        
        XCTAssertEqual(friendsStates.first, .loading)
        XCTAssertEqual(friendsStates.last, .loaded)
        
        XCTAssertEqual(mockFriendUseCase.executeCallCount, 1)
        XCTAssertEqual(mockUserUseCase.executeCallCount, 1)
    }
    
    func test_loadData_error_emitsErrorState() {
        mockFriendUseCase.errorToThrow = APIError.noData
        
        let expFriends = expectation(description: "Friends error")
        var friendsStates: [ViewState] = []
        sut.onFriendsStateChanged = { state in
            friendsStates.append(state)
            if case .error = state { expFriends.fulfill() }
        }

        sut.loadData(scenario: .noFriends)
        
        waitForExpectations(timeout: 1)
        
        XCTAssertEqual(friendsStates.first, .loading)
        if case .error = friendsStates.last {
            // Success
        } else {
            XCTFail("Expected error state")
        }
    }

    func test_loadData_clearsSearchTextByDefault() {
        sut.searchText = "Old Search"
        
        let exp = expectation(description: "load finished")
        sut.onFriendsStateChanged = { state in
            if state == .loaded { exp.fulfill() }
        }
        
        sut.loadData(scenario: .friendsOnly)
        
        waitForExpectations(timeout: 1)
        XCTAssertEqual(sut.searchText, "")
    }

    func test_searchFilter_filtersFriendsByName() {
        let friends = [
            Friend(fid: "1", name: "Alice", status: 1, isTop: "0", updateDate: ""),
            Friend(fid: "2", name: "Bob", status: 1, isTop: "0", updateDate: "")
        ]
        mockFriendUseCase.stubbedResult = FriendListResult(friends: friends, invitations: [])
        
        let exp = expectation(description: "load finished")
        sut.onFriendsStateChanged = { state in
            if state == .loaded { exp.fulfill() }
        }
        
        sut.loadData(scenario: .friendsOnly)
        waitForExpectations(timeout: 1)
        
        sut.searchText = "Ali"
        XCTAssertEqual(sut.filteredFriends.count, 1)
        XCTAssertEqual(sut.filteredFriends.first?.name, "Alice")
    }

    func test_refresh_usesCurrentScenario() {
        // Initial load
        let exp1 = expectation(description: "load 1")
        sut.onFriendsStateChanged = { s in if s == .loaded { exp1.fulfill() } }
        sut.loadData(scenario: .withInvitations)
        waitForExpectations(timeout: 1)
        
        // Refresh
        let exp2 = expectation(description: "load 2")
        sut.onFriendsStateChanged = { s in if s == .loaded { exp2.fulfill() } }
        sut.refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertEqual(mockFriendUseCase.executeCallCount, 2)
        XCTAssertEqual(mockFriendUseCase.lastScenario, .withInvitations)
    }

    func test_toggleInvitationExpanded() {
        XCTAssertFalse(sut.isInvitationExpanded)
        
        var updateCalled = false
        sut.onUpdate = { updateCalled = true }
        
        sut.toggleInvitationExpanded()
        
        XCTAssertTrue(sut.isInvitationExpanded)
        XCTAssertTrue(updateCalled)
    }
}
