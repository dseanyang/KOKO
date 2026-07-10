import Foundation

enum ViewState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}

@MainActor
class FriendListViewModel {

    var onUpdate: (() -> Void)?
    var onFriendsStateChanged: ((ViewState) -> Void)?
    var onUserStateChanged: ((ViewState) -> Void)?

    private(set) var user: User?
    private(set) var friends: [Friend] = []
    private(set) var invitations: [Friend] = []
    private(set) var filteredFriends: [Friend] = []
    private(set) var isInvitationExpanded: Bool = false
    private(set) var currentScenario: FriendScenario = .noFriends

    var searchText: String = "" {
        didSet { applyFilter() }
    }

    var hasInvitations: Bool { !invitations.isEmpty }
    var hasFriends: Bool { !friends.isEmpty }

    // (Kept for view controller's updateUI logic)
    var isListLoading: Bool = false

    private let getFriendListUseCase: GetFriendListUseCaseProtocol
    private let getUserUseCase: GetUserUseCaseProtocol

    private var loadTask: Task<Void, Never>?
    private var userTask: Task<Void, Never>?

    init(getFriendListUseCase: GetFriendListUseCaseProtocol = GetFriendListUseCase(),
         getUserUseCase: GetUserUseCaseProtocol = GetUserUseCase()) {
        self.getFriendListUseCase = getFriendListUseCase
        self.getUserUseCase = getUserUseCase
    }


    func loadData(scenario: FriendScenario, clearSearch: Bool = true) {
        loadTask?.cancel()
        userTask?.cancel()

        currentScenario = scenario
        if clearSearch { searchText = "" }

        userTask = Task { await loadUser() }
        loadTask = Task { await loadFriends(scenario: scenario) }
    }

    func refresh() {
        loadData(scenario: currentScenario, clearSearch: false)
    }

    func toggleInvitationExpanded() {
        isInvitationExpanded.toggle()
        onUpdate?()
    }


    private func loadUser() async {
        onUserStateChanged?(.loading)

        do {
            let fetchedUser = try await getUserUseCase.execute()
            guard !Task.isCancelled else { return }
            self.user = fetchedUser
            onUserStateChanged?(.loaded)
            onUpdate?()
        } catch {
            guard !Task.isCancelled else { return }
            onUserStateChanged?(.error(error.localizedDescription))
        }
    }


    private func loadFriends(scenario: FriendScenario) async {
        isListLoading = true
        onFriendsStateChanged?(.loading)

        do {
            let result = try await getFriendListUseCase.execute(scenario: scenario)
            guard !Task.isCancelled else {
                isListLoading = false
                onFriendsStateChanged?(.idle)
                return
            }
            self.friends     = result.friends
            self.invitations = result.invitations
            isListLoading = false
            onFriendsStateChanged?(.loaded)
            applyFilter()
        } catch {
            isListLoading = false
            guard !Task.isCancelled else { return }
            onFriendsStateChanged?(.error(error.localizedDescription))
        }
    }


    private func applyFilter() {
        filteredFriends = searchText.isEmpty
            ? friends
            : friends.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        onUpdate?()
    }
}
