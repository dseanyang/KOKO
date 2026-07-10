import Foundation

protocol FriendMergerProtocol {
    func merge(_ list: [Friend]) -> [Friend]
}

struct FriendMerger: FriendMergerProtocol {

    func merge(_ list: [Friend]) -> [Friend] {
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
