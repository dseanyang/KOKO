import Foundation

protocol FriendSorterProtocol {
    func sort(_ friends: [Friend]) -> [Friend]
}

struct FriendSorter: FriendSorterProtocol {

    func sort(_ friends: [Friend]) -> [Friend] {
        friends.sorted { lhs, rhs in
            if lhs.friendStatus == .inviting && rhs.friendStatus != .inviting { return true }
            if lhs.friendStatus != .inviting && rhs.friendStatus == .inviting { return false }
            if lhs.hasStarBadge != rhs.hasStarBadge { return lhs.hasStarBadge }
            return lhs.name < rhs.name
        }
    }
}
