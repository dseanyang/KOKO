import XCTest
import Combine
@testable import KOKO

@MainActor
final class FriendListViewModelTests: XCTestCase {

    var sut: FriendListViewModel!
    var mockFriendUseCase: MockGetFriendListUseCase!
    var mockUserUseCase: MockGetUserUseCase!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockFriendUseCase = MockGetFriendListUseCase()
        mockUserUseCase = MockGetUserUseCase()
        cancellables = []
        sut = FriendListViewModel(
            getFriendListUseCase: mockFriendUseCase,
            getUserUseCase: mockUserUseCase,
            scenario: .noFriends,
            searchDebounceDelay: .zero
        )
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        mockFriendUseCase = nil
        mockUserUseCase = nil
        super.tearDown()
    }

    func test_loadData_emitsLoadingThenLoaded() async {
        // Initially state should have isListLoading = false (initial state)
        XCTAssertFalse(sut.state.isListLoading)

        await loadDataAndWait()

        XCTAssertFalse(sut.state.isListLoading, "Should be done loading")
        XCTAssertEqual(mockFriendUseCase.executeCallCount, 1)
        XCTAssertEqual(mockUserUseCase.executeCallCount, 1)
    }

    func test_loadData_error_publishesErrorInState() async {
        mockFriendUseCase.errorToThrow = APIError.noData

        await loadDataAndWait()

        XCTAssertNotNil(sut.state.error, "Expected error message in state")
        XCTAssertFalse(sut.state.isListLoading)
    }

    func test_loadData_clearsSearchTextByDefault() async {
        let friends = [
            Friend(fid: "1", name: "Alice", status: 1, isTop: "0", updateDate: ""),
            Friend(fid: "2", name: "Bob", status: 1, isTop: "0", updateDate: "")
        ]
        mockFriendUseCase.stubbedResult = FriendListResult(friends: friends, invitations: [])
        await loadDataAndWait()
        await updateSearchAndWait("Alice", expectedFriendCount: 1)

        await loadDataAndWait(clearSearch: true)

        XCTAssertEqual(sut.state.displayedFriends.count, 2)
    }

    func test_searchFilter_filtersFriendsByName() async {
        let friends = [
            Friend(fid: "1", name: "Alice", status: 1, isTop: "0", updateDate: ""),
            Friend(fid: "2", name: "Bob", status: 1, isTop: "0", updateDate: "")
        ]
        mockFriendUseCase.stubbedResult = FriendListResult(friends: friends, invitations: [])

        await loadDataAndWait()

        // All friends shown before filter
        XCTAssertEqual(sut.state.displayedFriends.count, 2)

        await updateSearchAndWait("Ali", expectedFriendCount: 1)
        XCTAssertEqual(sut.state.displayedFriends.count, 1)
        XCTAssertEqual(sut.state.displayedFriends.first?.name, "Alice")
    }

    func test_refresh_callsUseCaseTwice() async {
        await loadDataAndWait()

        await refreshAndWait()

        XCTAssertEqual(mockFriendUseCase.executeCallCount, 2)
    }

    func test_toggleInvitationExpanded() {
        XCTAssertFalse(sut.state.isInvitationExpanded)

        sut.toggleInvitationExpanded()

        XCTAssertTrue(sut.state.isInvitationExpanded)
    }

    func test_profileViewData_hiddenWhileUserLoading() {
        // Before loadData is called, profile should be nil (initial state)
        XCTAssertNil(sut.state.profile)
    }

    func test_noFriendsScenario_hidesSearchBar() async {
        sut = FriendListViewModel(
            getFriendListUseCase: mockFriendUseCase,
            getUserUseCase: mockUserUseCase,
            scenario: .noFriends,
            searchDebounceDelay: .zero
        )
        await loadDataAndWait()

        XCTAssertFalse(sut.state.showSearchBar, "noFriends scenario should hide search bar")
        XCTAssertTrue(sut.state.showKokoIdDot, "noFriends scenario should show pink dot")
    }

    func test_friendsOnlyScenario_showsSearchBar() async {
        sut = FriendListViewModel(
            getFriendListUseCase: mockFriendUseCase,
            getUserUseCase: mockUserUseCase,
            scenario: .friendsOnly,
            searchDebounceDelay: .zero
        )
        await loadDataAndWait()

        XCTAssertTrue(sut.state.showSearchBar, "friendsOnly scenario should show search bar")
        XCTAssertFalse(sut.state.showKokoIdDot, "friendsOnly scenario should hide pink dot")
    }

    private func loadDataAndWait(clearSearch: Bool = true) async {
        let expectation = expectation(description: "friend list finishes loading")
        let cancellable = sut.$state.dropFirst().sink { state in
            if !state.isListLoading {
                expectation.fulfill()
            }
        }

        sut.loadData(clearSearch: clearSearch)
        await fulfillment(of: [expectation], timeout: 1)
        cancellable.cancel()
    }

    private func refreshAndWait() async {
        let expectation = expectation(description: "friend list refresh finishes")
        let cancellable = sut.$state.dropFirst().sink { state in
            if !state.isListLoading {
                expectation.fulfill()
            }
        }

        sut.refresh()
        await fulfillment(of: [expectation], timeout: 1)
        cancellable.cancel()
    }

    private func updateSearchAndWait(_ text: String, expectedFriendCount: Int) async {
        let expectation = expectation(description: "search result updates")
        let cancellable = sut.$state.dropFirst().sink { state in
            if state.displayedFriends.count == expectedFriendCount {
                expectation.fulfill()
            }
        }

        sut.updateSearch(text)
        await fulfillment(of: [expectation], timeout: 1)
        cancellable.cancel()
    }
}
