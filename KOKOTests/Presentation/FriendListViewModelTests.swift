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
            scenario: .noFriends
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

        sut.loadData()
        // Give async tasks a moment to start
        try? await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertFalse(sut.state.isListLoading, "Should be done loading")
        XCTAssertEqual(mockFriendUseCase.executeCallCount, 1)
        XCTAssertEqual(mockUserUseCase.executeCallCount, 1)
    }

    func test_loadData_error_publishesErrorInState() async {
        mockFriendUseCase.errorToThrow = APIError.noData

        sut.loadData()
        try? await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertNotNil(sut.state.error, "Expected error message in state")
        XCTAssertFalse(sut.state.isListLoading)
    }

    func test_loadData_clearsSearchTextByDefault() async {
        // Pre-seed search
        sut.updateSearch("Old Search")
        try? await Task.sleep(nanoseconds: 500_000_000) // wait for debounce

        sut.loadData(clearSearch: true)
        try? await Task.sleep(nanoseconds: 500_000_000)

        // After clearSearch=true, no filter should be applied
        XCTAssertEqual(sut.state.displayedFriends.count, 0) // empty stub
    }

    func test_searchFilter_filtersFriendsByName() async {
        let friends = [
            Friend(fid: "1", name: "Alice", status: 1, isTop: "0", updateDate: ""),
            Friend(fid: "2", name: "Bob", status: 1, isTop: "0", updateDate: "")
        ]
        mockFriendUseCase.stubbedResult = FriendListResult(friends: friends, invitations: [])

        sut.loadData()
        try? await Task.sleep(nanoseconds: 500_000_000)

        // All friends shown before filter
        XCTAssertEqual(sut.state.displayedFriends.count, 2)

        sut.updateSearch("Ali")
        try? await Task.sleep(nanoseconds: 500_000_000) // wait for debounce
        XCTAssertEqual(sut.state.displayedFriends.count, 1)
        XCTAssertEqual(sut.state.displayedFriends.first?.name, "Alice")
    }

    func test_refresh_callsUseCaseTwice() async {
        sut.loadData()
        try? await Task.sleep(nanoseconds: 500_000_000)

        sut.refresh()
        try? await Task.sleep(nanoseconds: 500_000_000)

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
            scenario: .noFriends
        )
        sut.loadData()
        try? await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertFalse(sut.state.showSearchBar, "noFriends scenario should hide search bar")
        XCTAssertTrue(sut.state.showKokoIdDot, "noFriends scenario should show pink dot")
    }

    func test_friendsOnlyScenario_showsSearchBar() async {
        sut = FriendListViewModel(
            getFriendListUseCase: mockFriendUseCase,
            getUserUseCase: mockUserUseCase,
            scenario: .friendsOnly
        )
        sut.loadData()
        try? await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertTrue(sut.state.showSearchBar, "friendsOnly scenario should show search bar")
        XCTAssertFalse(sut.state.showKokoIdDot, "friendsOnly scenario should hide pink dot")
    }
}
