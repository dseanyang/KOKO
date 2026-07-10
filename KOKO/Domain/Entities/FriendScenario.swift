import Foundation

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
