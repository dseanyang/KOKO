import Foundation

protocol GetFriendListUseCaseProtocol {
    func execute(scenario: FriendScenario) async throws -> FriendListResult
}

final class GetFriendListUseCase: GetFriendListUseCaseProtocol {

    private let friendRepository: FriendRepositoryProtocol
    private let merger: FriendMergerProtocol
    private let sorter: FriendSorterProtocol

    init(friendRepository: FriendRepositoryProtocol = FriendRepository(),
         merger: FriendMergerProtocol = FriendMerger(),
         sorter: FriendSorterProtocol = FriendSorter()) {
        self.friendRepository = friendRepository
        self.merger = merger
        self.sorter = sorter
    }


    func execute(scenario: FriendScenario) async throws -> FriendListResult {
        let rawFriends = try await fetchFriends(for: scenario)
        let deduped    = merger.merge(rawFriends)
        let invitations = deduped.filter { $0.isInvitation }
        let friends     = sorter.sort(deduped.filter { !$0.isInvitation })
        return FriendListResult(friends: friends, invitations: invitations)
    }


    private func fetchFriends(for scenario: FriendScenario) async throws -> [Friend] {
        switch scenario {
        case .noFriends:
            return try await friendRepository.fetchFriendList4()

        case .friendsOnly:
            async let list1 = friendRepository.fetchFriendList1()
            async let list2 = friendRepository.fetchFriendList2()
            return try await list1 + list2

        case .withInvitations:
            return try await friendRepository.fetchFriendList3()
        }
    }
}
