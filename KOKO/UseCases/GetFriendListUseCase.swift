import Foundation

// MARK: - GetFriendListUseCaseProtocol
protocol GetFriendListUseCaseProtocol {
    func execute(scenario: FriendScenario) async -> Result<FriendListResult, APIError>
}

// MARK: - GetFriendListUseCase
final class GetFriendListUseCase: GetFriendListUseCaseProtocol {

    private let friendRepository: FriendRepositoryProtocol

    init(friendRepository: FriendRepositoryProtocol = FriendRepository()) {
        self.friendRepository = friendRepository
    }

    func execute(scenario: FriendScenario) async -> Result<FriendListResult, APIError> {
        let friendResult = await friendRepository.fetchFriends(scenario: scenario)

        switch friendResult {
        case .success(let fetchedFriends):
            let deduped     = deduplicate(fetchedFriends)
            let invitations = deduped.filter { $0.isInvitation }
            let friends     = deduped
                .filter { !$0.isInvitation }
                .sorted { lhs, rhs in
                    if lhs.friendStatus == .inviting && rhs.friendStatus != .inviting { return true }
                    if lhs.friendStatus != .inviting && rhs.friendStatus == .inviting { return false }
                    if lhs.hasStarBadge != rhs.hasStarBadge { return lhs.hasStarBadge }
                    return lhs.name < rhs.name
                }
            return .success(FriendListResult(friends: friends, invitations: invitations))

        case .failure(let error):
            return .failure(error)
        }
    }

    // MARK: - Business Logic: Merge & Deduplicate
    func deduplicate(_ list: [Friend]) -> [Friend] {
        var dict: [String: Friend] = [:]
        var order: [String] = []
        for friend in list {
            if let existing = dict[friend.fid] {
                if DateParser.isNewer(friend.updateDate, than: existing.updateDate) {
                    dict[friend.fid] = friend
                }
            } else {
                dict[friend.fid] = friend
                order.append(friend.fid)
            }
        }
        return order.compactMap { dict[$0] }
    }
}
