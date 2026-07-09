import Foundation

// MARK: - Scenario Enum
enum FriendScenario: Int, CaseIterable {
    case noFriends       = 0
    case friendsOnly     = 1
    case withInvitations = 2

    var title: String {
        switch self {
        case .noFriends:       return "情境 I：無好友畫面"
        case .friendsOnly:     return "情境 II：只有好友列表"
        case .withInvitations: return "情境 III：好友列表含邀請"
        }
    }

    var description: String {
        switch self {
        case .noFriends:       return "Request friend4.json"
        case .friendsOnly:     return "Request friend1.json + friend2.json (合併)"
        case .withInvitations: return "Request friend3.json"
        }
    }
}

// MARK: - FriendListViewModel
@MainActor
class FriendListViewModel {

    // MARK: - Outputs (Closure Bindings)
    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    var onUserLoadingChanged: ((Bool) -> Void)?

    // MARK: - State
    private(set) var user: User?
    private(set) var friends: [Friend] = []
    private(set) var invitations: [Friend] = []
    private(set) var filteredFriends: [Friend] = []
    private(set) var isInvitationExpanded: Bool = false
    private(set) var currentScenario: FriendScenario = .noFriends
    private(set) var isListLoading: Bool = false

    var searchText: String = "" {
        didSet { applyFilter() }
    }

    var hasInvitations: Bool { !invitations.isEmpty }
    var hasFriends: Bool { !friends.isEmpty }

    // MARK: - Dependencies
    private let useCase: GetFriendListUseCaseProtocol
    private let userRepository: UserRepositoryProtocol

    private var loadTask: Task<Void, Never>?
    private var userTask: Task<Void, Never>?

    init(useCase: GetFriendListUseCaseProtocol = GetFriendListUseCase(),
         userRepository: UserRepositoryProtocol = UserRepository()) {
        self.useCase = useCase
        self.userRepository = userRepository
    }

    // MARK: - Public API

    func loadData(scenario: FriendScenario, clearSearch: Bool = true) {
        loadTask?.cancel()
        userTask?.cancel()

        currentScenario = scenario
        if clearSearch { searchText = "" }

        onUserLoadingChanged?(true)
        userTask = Task { @MainActor in
            let result = await userRepository.fetchUser()
            guard !Task.isCancelled else { return }
            onUserLoadingChanged?(false)
            if case .success(let user) = result {
                self.user = user
                self.onUpdate?()
            }
        }

        isListLoading = true
        onLoadingChanged?(true)
        loadTask = Task { @MainActor in
            let result = await useCase.execute(scenario: scenario)
            guard !Task.isCancelled else { return }
            self.isListLoading = false
            onLoadingChanged?(false)
            switch result {
            case .success(let listResult):
                self.friends     = listResult.friends
                self.invitations = listResult.invitations
                applyFilter()
            case .failure(let error):
                onError?(error.localizedDescription)
            }
        }
    }

    func refresh() {
        loadData(scenario: currentScenario, clearSearch: false)
    }

    func toggleInvitationExpanded() {
        isInvitationExpanded.toggle()
        onUpdate?()
    }

    // MARK: - Private

    private func applyFilter() {
        filteredFriends = searchText.isEmpty
            ? friends
            : friends.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        onUpdate?()
    }
}
