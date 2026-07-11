import Foundation
import Combine

@MainActor
final class FriendListViewModel {

    // MARK: - Output (single published state — Combine binding)
    @Published private(set) var state: FriendListViewState = .initial

    // MARK: - Private raw data (never exposed to the View layer)
    private var user: User?
    private var friends: [Friend] = []
    private var invitations: [Friend] = []
    private var currentScenario: FriendScenario = .noFriends
    private var isInvitationExpanded: Bool = false
    private var isListLoading: Bool = false
    private var currentError: String? = nil

    @Published var searchText: String = ""
    private var debouncedSearchText: String = ""
    private var displayedFriends: [Friend] {
        debouncedSearchText.isEmpty
            ? friends
            : friends.filter { $0.name.localizedCaseInsensitiveContains(debouncedSearchText) }
    }

    // MARK: - Dependencies
    private let getFriendListUseCase: GetFriendListUseCaseProtocol
    private let getUserUseCase: GetUserUseCaseProtocol

    private var loadTask: Task<Void, Never>?
    
    // Combine cancellables
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init (full Dependency Injection)
    init(
        getFriendListUseCase: GetFriendListUseCaseProtocol,
        getUserUseCase: GetUserUseCaseProtocol,
        scenario: FriendScenario
    ) {
        self.getFriendListUseCase = getFriendListUseCase
        self.getUserUseCase = getUserUseCase
        self.currentScenario = scenario
        
        setupSearchDebounce()
    }
    
    private func setupSearchDebounce() {
        $searchText
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.debouncedSearchText = text
                self?.publishState()
            }
            .store(in: &cancellables)
    }

    // MARK: - Public API

    func loadData(clearSearch: Bool = true) {
        loadTask?.cancel()
        currentError = nil

        if clearSearch {
            searchText = ""
            debouncedSearchText = ""
        }
        
        isListLoading = true
        user = nil
        publishState()

        loadTask = Task {
            do {
                async let fetchUser = getUserUseCase.execute()
                async let fetchFriends = getFriendListUseCase.execute(scenario: currentScenario)
                
                let (userResult, friendsResult) = try await (fetchUser, fetchFriends)
                
                guard !Task.isCancelled else { return }
                
                self.user = userResult
                self.friends = friendsResult.friends
                self.invitations = friendsResult.invitations
                self.isListLoading = false
                self.publishState()
            } catch {
                guard !Task.isCancelled else { return }
                self.isListLoading = false
                self.currentError = error.localizedDescription
                self.publishState()
            }
        }
    }

    func refresh() {
        loadData(clearSearch: false)
    }

    func toggleInvitationExpanded() {
        isInvitationExpanded.toggle()
        publishState()
    }

    func updateSearch(_ text: String) {
        searchText = text
    }



    // MARK: - State computation

    private func publishState() {
        let hasFriends = !friends.isEmpty
        let hasInvites = !invitations.isEmpty

        let profileData: ProfileViewData? = user.map { u in
            ProfileViewData(
                name: u.name,
                kokoIdText: u.kokoid.isEmpty
                ? "設定 KOKO ID"
                : "KOKO ID : \(u.kokoid)"
            )
        }

        let invitationViewData = invitations.map { InvitationViewData(name: $0.name) }
        let friendCellVMs = displayedFriends.map {
            FriendCellViewModel(name: $0.name, isTop: $0.hasStarBadge, friendStatus: $0.friendStatus)
        }
        let invitingBadge = friends.filter { $0.friendStatus == .inviting }.count

        let showEmpty = !hasFriends && !hasInvites && !isListLoading
        let showSearchBar = hasFriends

        state = FriendListViewState(
            profile: profileData,
            invitations: invitationViewData,
            displayedFriends: friendCellVMs,
            invitingBadgeCount: invitingBadge,
            showEmptyView: showEmpty,
            showSearchBar: showSearchBar,
            isInvitationExpanded: isInvitationExpanded,
            isListLoading: isListLoading,
            showKokoIdDot: !hasFriends && !hasInvites,
            error: currentError
        )
    }
}
